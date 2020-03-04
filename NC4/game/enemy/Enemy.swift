//
//  Enemy.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Enemy: AbstractGameObject, Lifeable {
    var lifes: Int! = 0
    var lastContact: TimeInterval! = TimeInterval(2)
    var minContactThreshold = TimeInterval(0.3)
    
    func configure() {
        self.lifes = .random(in: 5...10)
    }
    
    
    override func update(_ deltaTime: TimeInterval) {
        self.lastContact += deltaTime
        
        self.getLabelNode().text = "\(self.lifes!)"
    }
    
    func canCollide() -> Bool {
        self.lastContact > minContactThreshold
    }
    
    func onLifeTaken() {
         self.lifes -= 1
    }
    
    func onCollision() {
        if self.canCollide() {
            self.scene.player.onLifeTaken()
            self.onLifeTaken()
            self.lastContact = TimeInterval(0)
        }
    }
    
    func isDead() -> Bool { self.lifes <= 0 }
    
    func getWallNode() -> SKSpriteNode {
        return self.node.childNode(withName: "wall") as! SKSpriteNode
    }
    
    func getLabelNode() -> SKLabelNode {
        return self.node.childNode(withName: "point") as! SKLabelNode
    }
    
}
