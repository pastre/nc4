//
//  EnemyGroup.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class EnemyGroup: AbstractGameObject {
    
    var collidingEnemy: Enemy?
    var enemies: [Enemy]!
    
    init(enemies: [Enemy], _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.enemies = enemies
    }
    
    override func update(_ deltaTime: TimeInterval) {
        
        
        if let collidingEnemy = self.collidingEnemy {
            collidingEnemy.onCollision()
            
            if collidingEnemy.isDead() {
                collidingEnemy.node.removeFromParent()
                self.enemies.removeAll { $0.lifes == 0}
                self.collidingEnemy = nil
            }
        } else {
            // Goes down
            let deltaY = CGFloat(deltaTime) * 100
            self.node.position.y -= deltaY
        }
        
        self.enemies.forEach { $0.update(deltaTime)}
    }
    
    
    func isOutOfScreen(_ bounds: CGRect) -> Bool {
        return self.node.position.y < bounds.minY
    }
    
    func despawn() {
        self.node.removeFromParent()
    }
    
    func onContact(with node: SKSpriteNode ) {
        self.collidingEnemy = self.enemies.filter { $0.node == node }.first
       
    }
    
}
