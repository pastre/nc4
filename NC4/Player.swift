//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

protocol Lifeable {
    var lifes: Int! { get set }
    
    func isDead() -> Bool
    func onLifeTaken()
    func onLifePicked(_ amount: Int)
}

extension Lifeable {
    
    func isDead() -> Bool { return self.lifes <= 0 }
    func onLifePicked(_ amount: Int) {
        
    }
}

class Player: AbstractGameObject, Lifeable {
    var lifes: Int!
    
    func onLifeTaken() {
        self.lifes -= 1
    }
    
    func onLifePicked(_ amount: Int) {
        self.lifes += amount
    }
}

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

class EnemyGroupFactory: SceneSupplicant {
    
    var scene: GameScene!
    var baseNode: SKNode!
    
    
    internal init(scene: GameScene?) {
        self.scene = scene
        
        let enemyRootNode = self.scene.childNode(withName: "enemyGroup")
        
        for child in enemyRootNode!.children {
            guard child.name == "wall", let node = child as? SKSpriteNode else { continue }
            
            let body = SKPhysicsBody(rectangleOf: node.size )
            
            body.affectedByGravity = false
            body.allowsRotation = false
            body.pinned = true
            
            body.isDynamic = false
            body.categoryBitMask = ContactMask.wall.rawValue
            body.collisionBitMask = ContactMask.player.rawValue
            body.contactTestBitMask = ContactMask.none.rawValue
            
            node.physicsBody = body
            
        }
        
        self.baseNode = enemyRootNode!
    }
    
    func getEnemyGroup() -> EnemyGroup {
        let clonedNode = self.baseNode.copy() as! SKNode
        
        clonedNode.children.forEach {
            self.configurePhysics(on: $0 as! SKSpriteNode)
        }
        let enemies = clonedNode.children.map { Enemy($0, self.scene)}
        
        enemies.forEach {
            $0.configure()
        }
//        
//        print("------------------")
//        
//        enemies.forEach {
//            print($0.points)
//        }
        
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
