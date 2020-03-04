//
//  CoinFactory.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class CoinFactory<T>: GameObjectFactory {
    func configurePhysics(on node: SKSpriteNode) {
        
        let body = SKPhysicsBody(rectangleOf: node.size )
        
        body.affectedByGravity = false
        body.allowsRotation = false
        body.pinned = false
        
        body.isDynamic = false
        body.categoryBitMask = ContactMask.coin.rawValue
        body.collisionBitMask = 0
        body.contactTestBitMask = ContactMask.player.rawValue
        
        node.physicsBody = body
    }
    
    
    var scene: GameScene!
    var baseNode: SKNode!
    
    internal init(scene: GameScene?) {
        self.scene = scene
    
        self.baseNode = self.loadBaseNode()
    }
    
    
    func loadBaseNode() -> SKNode {
        return self.scene.childNode(withName: "coin")!
    }
    
    func getGameObject() -> Coin {
        
        let clonedNode = self.baseNode.copy() as! SKSpriteNode
        
        self.configurePhysics(on: clonedNode)
        
        
        
        return Coin(clonedNode, self.scene)
    }
}
