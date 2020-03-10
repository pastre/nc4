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

    var scene: GameScene?
    
    
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
        self.scene?.realPaused = true
        
        self.skView.ignoresSiblingOrder = true
        self.skView.showsFPS = true
        self.skView.showsNodeCount = true
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func onGameOver() {
        
        StorageFacade.instance.updateScoreIfNeeded(to: self.scene!.score)
        
        self.loadScene()
        self.scene?.realPaused = true
        self.playButton.isHidden = false
    }
    
    @IBAction func onPlay(_ sender: Any) {
        self.scene?.realPaused = false
        
        self.playButton.isHidden = true
    }
    
}
