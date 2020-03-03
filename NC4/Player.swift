//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Player: AbstractGameObject {
    
    
}

class Enemy: AbstractGameObject {
    var points: Int! = 0
    
    func rollPoints() {
        self.points = .random(in: 5...10)
    }
    
}


class EnemyGroup: AbstractGameObject {
    
    var collidingEnemy: Enemy?
    var enemies: [Enemy]!
    
    init(enemies: [Enemy], _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.enemies = enemies
    }
    
    override func update(_ deltaTime: TimeInterval) {
        
        if let collidingEnemy = self.collidingEnemy {
            collidingEnemy.points -= 1
            
            if collidingEnemy.points <= 0 {
                collidingEnemy.node.removeFromParent()
                self.enemies.removeAll { $0.points == 0}
                self.collidingEnemy = nil
            }
        } else {
            // Goes down
            let deltaY = CGFloat(deltaTime) * 100
            self.node.position.y -= deltaY
        }
        
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
    
    func onContactStop() {
        self.collidingEnemy = nil
    }
    
}

class EnemyGroupFactory: SceneSupplicant {
    
    var scene: GameScene!
    var baseNode: SKNode!
    
    
    internal init(scene: GameScene?) {
        self.scene = scene
        
        let enemyRootNode = self.scene.childNode(withName: "enemyGroup")
        
        self.baseNode = enemyRootNode!
    }
    
    func getEnemyGroup() -> EnemyGroup {
        let clonedNode = self.baseNode.copy() as! SKNode
        
        clonedNode.children.forEach {
            self.configurePhysics(on: $0 as! SKSpriteNode)
        }
        let enemies = clonedNode.children.map { Enemy($0, self.scene)}
        
        enemies.forEach {
            $0.rollPoints()
        }
        
        print("------------------")
        
        enemies.forEach {
            print($0.points)
        }
        
        return EnemyGroup(enemies: enemies,clonedNode, self.scene)
    }
    

    func configurePhysics(on node: SKSpriteNode) {
        let body = SKPhysicsBody(rectangleOf: node.size )
        
        body.affectedByGravity = false
        body.allowsRotation = false
        body.pinned = false
        
        body.isDynamic = false
        body.categoryBitMask = ContactMask.enemy.rawValue
        body.collisionBitMask = 0
        body.contactTestBitMask = ContactMask.player.rawValue
        
        node.physicsBody = body
    }
}
