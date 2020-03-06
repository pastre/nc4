
//
//  BackgroundSpawner.swift
//  NC4
//
//  Created by Bruno Pastre on 06/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


class BackgroundSpawner: SceneSupplicant, Updateable {
    internal init(scene: GameScene?) {
        self.scene = scene
    }
    
    var scene: GameScene!
    var nodes: [Background]! = [Background]()
    var shouldRun: Bool! = true
    
    func update(_ deltaTime: TimeInterval) {
        
        if Int.random(in: 0...100) <= 1 && self.shouldRun {
            self.spawn()
        }
        
        self.nodes.forEach { $0.update(deltaTime) }
        self.nodes.forEach { $0.shouldGoDown = self.shouldRun}
    }
    
    func spawn() {
        let newNode = self.getBgNode()
        let newBg = Background(newNode, self.scene)
        
        self.scene.addChild(newNode)
        self.nodes.append(newBg)
        
        let fadeIn = SKAction.fadeIn(withDuration: .random(in: 1...3))
        
        let fadeOut = SKAction.fadeOut(withDuration: .random(in: 10...30))
        
        newNode.run(SKAction.sequence([fadeIn, fadeOut, .removeFromParent()]))
    }
    
    func getBgNode() -> SKShapeNode {
//        let path = randomBezierPath(50, height: 50)
        let radius: CGFloat = .random(in:  5...20)
        
        let node = SKShapeNode(circleOfRadius: radius)
        
        node.fillColor = UIColor.black.withAlphaComponent(0.5)
        node.strokeColor = .clear
        
        node.position.y = self.scene.getBounds().height
        node.position.x = .random(in: self.scene.getBounds().minX...self.scene.getBounds().width)
    
        return node
    }
    
    
    
}
