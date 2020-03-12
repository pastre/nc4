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

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    

    var scene: GameScene?
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skView: SKView!
    
    var shouldDisplayGameCenter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadScene()
        self.scene?.realPaused = true
        
        self.skView.ignoresSiblingOrder = true
        self.skView.showsFPS = true
        self.skView.showsNodeCount = true
//        self.skView.showsPhysics = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAuthSuccess), name: kAuthSuccess, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureLeaderboardsButton()
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func onGameOver() {
        
        StorageFacade.instance.updateScoreIfNeeded(to: self.scene!.score)
        
        self.loadScene()
        self.scene?.realPaused = true
        self.showUI()
    }
    
    @IBAction func onPlay(_ sender: Any) {
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
    
    func hideUI() {
        
        self.playButton.isHidden = true
        self.logoImageView.isHidden = true
        self.settingsButton.isHidden = true
        self.leaderboardButton.isHidden = true
    }
    
    func showUI () {
        
        self.playButton.isHidden = false
        self.logoImageView.isHidden = false
        self.settingsButton.isHidden = false
        self.leaderboardButton.isHidden = false
    }
    
    
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
    
    @objc func onAuthSuccess() {
        self.leaderboardButton.layer.removeAllAnimations()
        self.leaderboardButton.transform = .identity
        
        if self.shouldDisplayGameCenter {
            self.presentGameCenter()
        }
    }
    
    func presentGameCenter() {
        guard let vc = GameCenterFacade.instance.getGameCenterVc() else { return }
        
        self.shouldDisplayGameCenter = false
        
        vc.gameCenterDelegate = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
