//
//  GameViewController.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene: SKScene?
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skView: SKView!
    
    fileprivate func loadScene() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadScene()
        self.scene?.isPaused = true
        
        self.skView.ignoresSiblingOrder = true
        
        self.skView.showsFPS = true
        self.skView.showsNodeCount = true
//        self.skView.showsPhysics = true
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func onGameOver() {
        self.loadScene()
        self.scene?.isPaused = true
        self.playButton.isHidden = false
        
    }
    
    @IBAction func onPlay(_ sender: Any) {
        self.scene?.isPaused = false
        
        self.playButton.isHidden = true
    }
    
}
