//
//  GameViewController.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GoogleMobileAds
import Firebase

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GameOverDataSource, GADBannerViewDelegate {
    
    // MARK: - GameOverDataSource
    func getScore() -> Int {
        return self.scene.score
    }
    
    func getHeadCount() -> Int {
        return self.scene.headCount
    }
    
    func onRevive() {
        self.scene.playerDidRevive()
        self.hasRevived = true
    }
    
    var scene: GameScene!
    
    @IBOutlet weak var vibrationButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var comingSoonLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var hudStackView: UIStackView!
    @IBOutlet weak var configStackView: UIStackView!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var topScoreLabel: UILabel!
    
    var hasRevived: Bool! = false
    var shouldDisplayGameCenter: Bool = false
    var shouldDisplayWarning: Bool = true
    var isConfigOpened = false
    var isPlaying: Bool {
        self.startGamePanGesture == nil
    }
    
    var gameStartedTimestamp: TimeInterval?
    var startGamePanGesture: UIPanGestureRecognizer?
    
    func configureBanner() {
        
        self.bannerView.isAutoloadEnabled = false
        
        guard StorageFacade.instance.canShowAds() else {
            self.bannerView.isHidden = true
            self.bannerView.isAutoloadEnabled = false
            self.bannerView.adUnitID = ""
            
            return
        }
        
        self.bannerView.adUnitID = "ca-app-pub-6710438178084678/6470677762"
//
        #if DEBUG
        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #endif
        
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
    }
    
    // MARK: -  UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUserRemovedAds), name: kON_ADS_REMOVED, object: nil)

        self.scoreLabel.isHidden = true
        
        
        self.configureBanner()
        self.loadScene()
        self.scene?.realPaused = true
        
        self.skView.ignoresSiblingOrder = true
//        self.skView.showsFPS = true
//        self.skView.showsNodeCount = true
//        self.skView.showsPhysics = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthSuccess), name: kAuthSuccess, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLeaderboardsButton()
        self.configureGameIdle()
        
        self.updatePlayerSkin()
        self.updateHighscoreLabel()
        self.updateSoundIcon()
        self.updateVibrationIcon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updatePlayerSkin()
        guard self.shouldDisplayWarning else { return }
        if !StorageFacade.instance.hasDisplayedDisclaimer() {
            
            let alert = UIAlertController(title: "Warning!", message: "This is completely fictional content, totally unrelated to any real situation, person or organization.", preferredStyle: .alert )
            
            alert.addAction(UIAlertAction(title: "Never show this again", style: .destructive, handler: { (_) in
                StorageFacade.instance.setDisclaimerDisplayed()
            }))
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.shouldDisplayWarning = false
            }))
            
        }
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI & HUD methods
    func hideUI() {
        
        self.hudStackView.isHidden = true
        self.configStackView.isHidden = true
        self.leaderboardButton.isHidden = true
        self.scoreLabel.isHidden = true
        self.topScoreLabel.isHidden = true
        
    }
    
    func showUI () {
        
        self.hudStackView.isHidden = false
        self.leaderboardButton.isHidden = false
        self.topScoreLabel.isHidden = false
    }
    
    
    func updateHighscoreLabel() {
        let highScore = StorageFacade.instance.getHighScore()
        
        self.topScoreLabel.text = "High score: \(highScore)"
    }
    
    // MARK: - Game methods
    
    func onGameStart() {
        
        self.configureGameRunning()
//        self.scene.player.lifes = -1
    }
    
    
    func updateGameStats() {
        
        let gameScore = self.scene!.score!
        let gameHeads = self.scene!.headCount
        let timestamp = Date().timeIntervalSince1970
        
        if let startTs = self.gameStartedTimestamp {
            let duration = timestamp - startTs
            
            Analytics.logEvent(AnalyticsEventLevelEnd, parameters: ["duration" : duration])
        }
        
        StorageFacade.instance.addHead(amount: gameHeads)
        
        StorageFacade.instance.updateScoreIfNeeded(to: gameScore)
        GameCenterFacade.instance.onScore(gameScore)
    }
    
    func onGameOverDismissed() {
        
        self.configureGameIdle()
        self.loadScene()
        self.scene?.realPaused = true
        
        self.hasRevived = false
        self.showUI()
        
        print("Dismissed!")
//        self.updateHighscoreLabel()
        
    }
    
    
    
    func onGameOver() {
        
        DispatchQueue.global().async {
            AudioManager.shared.play(soundEffect: .gameOver)
        }
        
        self.scene?.realPaused = true
        self.updateGameStats()
        self.performSegue(withIdentifier: "gameOver", sender: nil)
//        self.presentAd()
        
//        self.scoreLabel.isHidden = false
//        self.scoreLabel.text = "Last score: \(gameScore)"
    }
    
    
    // MARK: - BannerAd Delegate

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Recvd ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to load banner!", error)
        
        self.bannerView.load(GADRequest())
    }

    //MARK: - View methods
    
    func loadScene() {
        // Load the SKScene from 'GameScene.sks'

        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
           
            scene.size = view.bounds.size
            scene.scaleMode = .aspectFit
            scene.vc = self
            self.scene = scene
            // Present the scene
            self.skView.presentScene(scene)
        }
    }
    
    func presentGameCenter() {
        guard let vc = GameCenterFacade.instance.getGameCenterVc() else { return }
        
        self.shouldDisplayGameCenter = false
        
        vc.gameCenterDelegate = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func configureLeaderboardsButton() {
        if GameCenterFacade.instance.isAuthenticated() {
            self.leaderboardButton.layer.removeAllAnimations()
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.leaderboardButton.transform = self.leaderboardButton.transform .scaledBy(x: 1.2, y: 1.2)
            self.leaderboardButton.tintColor = .orange
        }, completion: nil)
        
    }
    
    
    
    // MARK: - GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    

    
    // MARK: - Config methods
    func updateConfig() {
        self.hudStackView.isHidden = self.isConfigOpened
        self.configStackView.isHidden = !self.isConfigOpened
    }

    
    func configureGameStartIndicator() {
        
        let handImageView = UIImageView(image: UIImage(named: "hand"))
        handImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let dx: CGFloat = self.view.frame.width * 0.2
        
        
        Timer.scheduledTimer(withTimeInterval: 3.1, repeats: true) { (timer) in
            guard !self.isPlaying else {
                timer.invalidate()
                return
            }
            

            self.view.addSubview(handImageView)
            handImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            handImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            handImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1).isActive = true
//            handImageView.heightAnchor.constraint(equalTo: handImageView.widthAnchor,multiplier: 1 / 0.5500575374).isActive = true
            
            handImageView.heightAnchor.constraint(equalTo: handImageView.widthAnchor,multiplier: 1 ).isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [.curveEaseOut], animations: {
                handImageView.transform = handImageView.transform.translatedBy(x: -dx, y: 0)
            }) { (_) in
                UIView.animate(withDuration: 0.6, delay: 0.3, options: [.curveEaseOut], animations: {
                    handImageView.transform = handImageView.transform.translatedBy(x: 2 * dx, y: 0)
                }) { (_) in
                    UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseOut], animations: {
                        handImageView.alpha = 0
//                        handImageView.transform = handImageView.transform.translatedBy(x: -dx, y: 0)
                    }) { (_) in
                        handImageView.transform = .identity
                        handImageView.alpha = 1
                        handImageView.removeFromSuperview()
                    }
                }
            }
            
        }
    }
    
    func configureGameIdle() {
        guard self.startGamePanGesture == nil else{ return }
        
        let startGamePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onPlay(_:)))
        self.view.addGestureRecognizer(startGamePanGesture)
        self.startGamePanGesture = startGamePanGesture
        
        
        self.configureGameStartIndicator()
        
    }
    
    func configureGameRunning() {
        guard let gesture = self.startGamePanGesture else { return }
        
        self.view.removeGestureRecognizer(gesture)
        
        self.startGamePanGesture = nil
    }
    
    func updateSoundIcon() {
        let newIcon = UIImage(named: StorageFacade.instance.isAudioDisabled() ?
            "mute" : "sound"
        )

        self.soundButton.setImage(newIcon, for: .normal)

    }
    
    func updatePlayerSkin() {
        let currentSkin = ShopItemManager.instance.equippedItem.getSkin()
        self.scene.setSkin(to: currentSkin)
        self.loadScene()
        self.scene?.realPaused = true
    }
    
    func updateVibrationIcon() {
        
        let newIcon = UIImage(named: StorageFacade.instance.isVibrationDisabled() ?
            "vibOff" : "vibrate"
        )

        self.vibrationButton.setImage(newIcon, for: .normal)

    }
    
    func showComingSoonLabel() {
        self.comingSoonLabel.alpha = 1
        
        UIView.animate(withDuration: 3, animations: {
            self.comingSoonLabel.alpha = 0
        }, completion: nil)
    }

    // MARK: - Button callbacks
    @objc func onPlay(_ sender: Any) {
        guard !self.isPlaying else  { return }
        
        self.hideUI()
        self.onGameStart()
        self.gameStartedTimestamp = Date().timeIntervalSince1970
        Analytics.logEvent(AnalyticsEventLevelStart, parameters: nil)
        
        self.scene.postConfig()
        self.scene?.realPaused = false
        
    }
    
    @IBAction func onLeaderboard(_ sender: Any) {
        if let authVc = GameCenterFacade.instance.authVc {
            self.present(authVc, animated: true, completion: nil)
            self.shouldDisplayGameCenter = true
            return
        }
        
        self.presentGameCenter()
    }
    
    @IBAction func onSound(_ sender: Any) {
        
        StorageFacade.instance.setAudioDisabled(to: !StorageFacade.instance.isAudioDisabled())
        self.updateSoundIcon()
        AudioManager.shared.update()
        
        Analytics.logEvent("soundButton", parameters: ["isActive" : !StorageFacade.instance.isAudioDisabled()])
    }
    
    @IBAction func onVibrate(_ sender: Any) {
        StorageFacade.instance.setVibrationDisabled(to: !StorageFacade.instance.isVibrationDisabled())
        
        self.updateVibrationIcon()
    }
    
    @IBAction func onSkinShop(_ sender: Any) {
        // TODO
        Analytics.logEvent("skinShopClicked", parameters: nil)
        self.performSegue(withIdentifier: "shop", sender: nil)
    }
    
    @IBAction func onRemoveAds(_ sender: Any) {
        // TODO
//        self.showComingSoonLabel()
        StoreManager.instance.buy(product: .removeAds)
        Analytics.logEvent("removeAdsClicked", parameters: nil)
    }
    
    @IBAction func onCloseConfig(_ sender: Any) {
        self.isConfigOpened = false
        self.updateConfig()
    }
    
    @IBAction func onOpenConfig(_ sender: Any) {
        self.isConfigOpened = true
        self.updateConfig()
    }
    
    
    @objc func onAuthSuccess() {
        self.leaderboardButton.layer.removeAllAnimations()
        self.leaderboardButton.transform = .identity
        
        if self.shouldDisplayGameCenter {
            self.presentGameCenter()
        }
        
        
        GameCenterFacade.instance.loadFromGamecenter()
    }
    
    @objc func onUserRemovedAds() {
        self.configureBanner()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? GameOverViewController {
            dest.dataSource = self
            dest.canAdRevive = !self.hasRevived
            
        } else if let dest = segue.destination as? ShopViewController {
            dest.delegate = self
        }
    }
}
