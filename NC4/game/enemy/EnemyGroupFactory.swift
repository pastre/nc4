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
        
        clonedNode.children.forEach { self.configurePhysics(on: $0 as! SKSpriteNode) }
        
        let enemies = clonedNode.children.filter( { $0.name == "enemy" } ).map { Enemy($0, self.scene)}
        
        enemies.forEach { $0.configure() }
        
        clonedNode.position = CGPoint(x: 0, y: self.scene.getBounds().height)
        
//        if let node = clonedNode.childNode(withName: "wall") as? SKSpriteNode {
//            self.configureWall(on: node)
//        }
        
        return EnemyGroup(enemies: enemies,clonedNode, self.scene)
    }
    
    func configurePhysics(on node: SKSpriteNode) {
        let body = self.getDefaultPhysicsBody(node)
        
        body.categoryBitMask = ContactMask.enemy.rawValue
        body.collisionBitMask = ContactMask.none.rawValue
        body.contactTestBitMask = ContactMask.player.rawValue
        body.mass = .infinity
        
        if let wallNode = node.childNode(withName: "wall") {

            let body = self.getDefaultPhysicsBody(node)
            
            body.categoryBitMask = ContactMask.wall.rawValue
            body.collisionBitMask = ContactMask.player.rawValue
            body.contactTestBitMask = ContactMask.none.rawValue
            
            
            wallNode.physicsBody = body
            print("Configured body")
        }
        
        node.physicsBody = body
    }
    
    func getDefaultPhysicsBody(_ node: SKSpriteNode) -> SKPhysicsBody {
        
        let body = SKPhysicsBody(rectangleOf: node.size )
        
        body.affectedByGravity = false
        body.allowsRotation = false
        body.pinned = false
        
        body.isDynamic = false

        
        return body
    }
    
    

}
