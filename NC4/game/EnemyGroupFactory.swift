//
//  EnemyGroupFactory.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


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
