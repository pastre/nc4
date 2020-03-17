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
    
        let textures = [
            "school",
            "bank",
            "market",
            "cafe",
            "gas",
            "hospital",
            "hotel",
            "police"
        ]
        
    
    init(enemies: [Enemy], _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.enemies = enemies
        
        self.balanceEnemies()
        self.unzeroEnemies()
        self.balanceSkins()
    }
    
    func balanceSkins() {
        var skins = [String]()
        var possibleSkins = self.textures.map { $0 }
        
        for _ in self.enemies {
            guard let newSkin = possibleSkins.randomElement() else { continue }
            
            skins.append(newSkin)
            possibleSkins.removeAll { $0 == newSkin }
        }
        
        for (i, enemy) in enemies.enumerated() {
            let node = enemy.getTextureNode()
            
            let newTexture = SKTexture(imageNamed: skins[i])
            
            let ratio: CGFloat =  CGFloat(newTexture.cgImage().width) / CGFloat(newTexture.cgImage().height)
            
            print("Ratio, ", ratio)
            
            node.texture = newTexture
//            node.scale(to: CGSize(width: node.size.width, height: node.size.height * ratio))
        }
        print("------------")
        
    }
    
    func unzeroEnemies() {
        self.enemies.forEach {
            if $0.lifes == 0 {
                $0.lifes += 1
            }
        }
    }
    
    func balanceEnemies() {
        let pLifes = self.scene.player.getLifeCount()
        for enemy in enemies {
            if enemy.lifes <= pLifes { return }
        }
        
        print("Rebalanced enemies!")
        
        enemies.randomElement()!.lifes =  pLifes == 0 ? 1 : pLifes
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
            let deltaY = CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed()
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
    
    func isInContact() -> Bool {
        return self.collidingEnemies.count > 0
    }
    
    func getEnemyArea() -> SKSpriteNode {
        return self.node.childNode(withName: "enemyArea") as! SKSpriteNode
    }
}
