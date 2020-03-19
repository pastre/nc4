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


class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADInterstitialDelegate {
    // MARK: - GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
        self.loadAd()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    

    var scene: GameScene?
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var topScoreLabel: UILabel!
    
    var shouldDisplayGameCenter: Bool = false
    var shouldDisplayWarning: Bool = true
    
    // MARK: -  UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scoreLabel.isHidden = true
        
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
        
        self.updateHighscoreLabel()
        self.updateSoundIcon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard self.shouldDisplayWarning else { return }
        if !StorageFacade.instance.hasDisplayedDisclaimer() {
            
            let alert = UIAlertController(title: "Warning!", message: "This is humorous content with no intention of disrespecting the real importance of fighting the real virus. We highly recommend you always consult apps and sources approved by WHO (World Health Organization).", preferredStyle: .alert )
            
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
        
        self.playButton.isHidden = true
        self.logoImageView.isHidden = true
        self.audioImage.isHidden = true
        self.leaderboardButton.isHidden = true
        self.scoreLabel.isHidden = true
        self.topScoreLabel.isHidden = true
        
    }
    func showUI () {
        
        self.playButton.isHidden = false
        self.logoImageView.isHidden = false
        self.audioImage.isHidden = false
        self.leaderboardButton.isHidden = false
        self.topScoreLabel.isHidden = false
    }
    
    func updateSoundIcon() {
        
        if StorageFacade.instance.isAudioDisabled() {
            
            self.audioImage.image = UIImage(systemName: "speaker.slash.fill")
        } else {
            self.audioImage.image = UIImage(systemName: "speaker.3.fill")
        }
    }
    
    func updateHighscoreLabel() {
        let highScore = StorageFacade.instance.getHighScore()
        
        self.topScoreLabel.text = "High score: \(highScore)"
    }
    
    // MARK: - Game methods
    
    func onGameStart() {
        
        self.loadAd()
    }
    
    func onGameOver() {
        guard let gameScore = self.scene?.score else { return }
        DispatchQueue.global().async {
            AudioManager.shared.play(soundEffect: .gameOver)
        }
        
        StorageFacade.instance.updateScoreIfNeeded(to: gameScore)
        GameCenterFacade.instance.onScore(gameScore)
        
        self.presentAd()
        self.loadScene()
        self.scene?.realPaused = true
        
        
        self.showUI()
        self.updateHighscoreLabel()
        
        self.scoreLabel.isHidden = false
        self.scoreLabel.text = "Last score: \(gameScore)"
        
    }
    
    // MARK: - Ad methods
    
    func loadAd() {
        
        print("Loading ad")
        // TEST AD
//        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        // READ AD
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-3760704996981292/8000561485")
        
        self.interstitial.delegate = self
        
        let request = GADRequest()
        interstitial.load(request)
        
        print("Loading ad")
    }
    
    func presentAd() {
        #if DEBUG
            return
        #endif
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            print("presenting ad")
        } else {
            print("Tried to present fucking ad, but it didnt load")
        }
    }
    
    func onAdCompleted() {
        
        
    }
    
    //MARK: - View helpers
    
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
    
    
    // MARK: - Button callbacks
    @IBAction func onPlay(_ sender: Any) {
        self.loadAd()
        self.scene?.realPaused = false
        self.hideUI()
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
