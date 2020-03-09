//
//  Coin.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Coin: AbstractGameObject, Lifeable {
    var lifes: Int!
    
    func onLifeTaken() {
        
    }
    
    override init(_ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        
        self.lifes = .random(in: 1...5)
        
        node.position = CGPoint(x:
            .random(in: (
                scene.getBounds().minX + 10)...(scene.getBounds().width - 10)), y:
            scene.getBounds().height)
        
        self.getLabelNode().text = "\(self.lifes!)"
    }
    
    
    override func update(_ deltaTime: TimeInterval) {

        let deltaY = CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed()
        
        self.node.position.y -= deltaY
    }
    
    func getLabelNode() -> SKLabelNode {
        return self.node.childNode(withName: "points") as! SKLabelNode
    }
}
