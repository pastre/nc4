//
//  SickPeopleManager.swift
//  NC4
//
//  Created by Bruno Pastre on 11/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class SickPeopleManager: Updateable, SceneSupplicant {
    
    var sickPeopleNodes = [SKSpriteNode]()
    var shouldMove: Bool = true
    var scene: GameScene!
    
    internal init(scene: GameScene?) {
        self.scene = scene
    }
    
    func update(_ deltaTime: TimeInterval) {
        let dy = self.shouldMove ? CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed() : 0
        
        sickPeopleNodes.forEach { node in
            node.position.y -= dy
        }
        
        self.clearUnusedNodes()
    }
    

    func clearUnusedNodes() {
        let threshold = self.scene.getBounds().height
        for node in self.sickPeopleNodes {
            if node.position.y < -threshold {
                node.removeFromParent()
            }
        }
        
        self.sickPeopleNodes = self.sickPeopleNodes.filter { $0.parent != nil }
    }
    
    func managePerson(node: SKSpriteNode) {
        
        self.scene.addChild(node)
        self.sickPeopleNodes.append(node)
    }
    
    
}
