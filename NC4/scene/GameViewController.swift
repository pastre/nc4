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

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADInterstitialDelegate, GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Recvd ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed to load banner!", error)
    }

    
    var scene: GameScene!
    var interstitial: GADInterstitial!
    
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
    
    var shouldDisplayGameCenter: Bool = false
    var shouldDisplayWarning: Bool = true
    var isConfigOpened = false
    var isPlaying: Bool {
        self.startGamePanGesture == nil
    }
    
    var gameStartedTimestamp: TimeInterval?
    var startGamePanGesture: UIPanGestureRecognizer?
    
    // MARK: -  UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scoreLabel.isHidden = true
        
        self.bannerView.adUnitID = "ca-app-pub-3760704996981292/9199739307"
        
        #if DEBUG
         self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #endif
        
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
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
        
        self.updateHighscoreLabel()
        self.updateSoundIcon()
        self.updateVibrationIcon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard self.shouldDisplayWarning else { return }
        if !StorageFacade.instance.hasDisplayedDisclaimer() {
            
            let alert = UIAlertController(title: "Warning!", message: "This is completely fictional content, totally unrelated to any real situation, person or organization.", preferredStyle: .alert )
            
            alert.addAction(UIAlertAction(title: "Never show this again", style: .destructive, handler: { (_) in
                StorageFacade.instance.setDisclaimerDisplayed()
            }))
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.shouldDisplayWarning = false
            }))
            
//            self.present(alert, animated: true, completion: nil)
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
        
        self.loadAd()
        self.configureGameRunning()
    }
    
    
    func updateGameStats() {
        
        guard let gameScore = self.scene?.score else { return }
        
        let timestamp = Date().timeIntervalSince1970
        if let startTs = self.gameStartedTimestamp {
            let duration = timestamp - startTs
            
            Analytics.logEvent(AnalyticsEventLevelEnd, parameters: ["duration" : duration])
        }
        
        StorageFacade.instance.updateScoreIfNeeded(to: gameScore)
        GameCenterFacade.instance.onScore(gameScore)
    }
    
    func onGameOverDismissed() {
        
        self.configureGameIdle()
        self.loadScene()
        self.scene?.realPaused = true
        
        self.showUI()
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
    
    // MARK: - Ad methods
    
    func loadAd() {
        
        // TEST AD
//        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        // REAL AD
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3760704996981292/8000561485")
        
        self.interstitial.delegate = self
        
        let request = GADRequest()
        interstitial.load(request)
        
    }
    
    func presentAd() {
        #if DEBUG
            return
        #endif
        Analytics.logEvent("showAd", parameters: nil)
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            print("presenting ad")
        } else {
            print("Tried to present fucking ad, but it didnt load")
        }
    }
    
    func onAdCompleted() {
        
        
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
    
    // MARK: - GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
        
        Analytics.logEvent("completedAdPresentation", parameters: nil)
        self.loadAd()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
        Crashlytics.crashlytics().record(error: error)
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
        
        self.loadAd()
        self.scene?.realPaused = false
        self.hideUI()
        self.onGameStart()
        self.gameStartedTimestamp = Date().timeIntervalSince1970
        Analytics.logEvent(AnalyticsEventLevelStart, parameters: nil)
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
        self.showComingSoonLabel()
    }
    
    @IBAction func onRemoveAds(_ sender: Any) {
        // TODO
        self.showComingSoonLabel()
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
    
}
