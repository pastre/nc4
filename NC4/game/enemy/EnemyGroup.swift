//
//  EnemyGroup.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class EnemyGroup: AbstractGameObject {
    
    var collidingEnemies: [Enemy] = [Enemy]()
    var enemies: [Enemy]!
    
    init(enemies: [Enemy], _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.enemies = enemies
    }
    
    override func update(_ deltaTime: TimeInterval) {
        
        
        if self.collidingEnemies.count > 0 {
            for collidingEnemy in self.collidingEnemies {

                collidingEnemy.onCollision()
                
                if collidingEnemy.isDead() {
                    collidingEnemy.node.removeFromParent()
                    self.enemies.removeAll { $0.lifes == 0}
                    self.collidingEnemies.removeAll { $0.lifes == 0}
                }
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
        guard let enemyInContact = self.enemies.filter({ (enemy) -> Bool in
            return enemy.node == node
        }).first else  { return }
        
        self.collidingEnemies.append(enemyInContact)
    }
    
    func onContactStopped(with node: SKSpriteNode) {
        self.collidingEnemies.removeAll { $0.node == node }
    }
    
}