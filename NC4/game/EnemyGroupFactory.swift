//
//  EnemyGroupFactory.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

protocol GameObjectFactory: SceneSupplicant  {
    
    associatedtype T
    
    var baseNode: SKNode! { get set }
    
    func configurePhysics(on node: SKSpriteNode)
    func loadBaseNode() -> SKNode
    func getGameObject() -> T
}

class EnemyGroupFactory<T>: GameObjectFactory {
    
    var scene: GameScene!
    var baseNode: SKNode!
    
    internal init(scene: GameScene?) {
        self.scene = scene
    
        self.baseNode = self.loadBaseNode()
    }
    
    func loadBaseNode() -> SKNode {
        return self.scene.childNode(withName: "enemyGroup")!
    }
    
    func getGameObject() -> EnemyGroup {
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
