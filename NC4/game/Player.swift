//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


class Player: AbstractGameObject, Lifeable {
    var lifes: Int! = 10
    
    override init(_ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        
        for _ in 1...self.lifes {
            self.increaseTail()
        }
    }
    
    func onLifeTaken() {
        self.lifes -= 1
        self.decreaseTail()
    }
    
    func onLifePicked(_ amount: Int) {
        self.lifes += amount
        for _ in 1...amount {
            print("Increased tail!")
            self.increaseTail()
        }
    }
    
    func getPointsNode() -> SKLabelNode {
        return self.node.childNode(withName: "point") as! SKLabelNode
    }
    
    override func update(_ deltaTime: TimeInterval) {
        self.getPointsNode().text = "\(self.lifes!)"
    }
    
    func isDead() -> Bool {
        return self.lifes < 0
    }
    
    func increaseTail() {
        let node = self.getTailNode()
        
        node.position = CGPoint(x: 0, y: -20 * self.node.children.count)
        
        self.node.addChild(node)
    }
    
    func decreaseTail() {
        self.getTailNodes().last?.removeFromParent()
    }
    
    func getTailNodes() -> [SKNode] {
        return self.node.children.filter { $0.name == "tail" }
    }
    
    func getTailNode() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: 10)
        
        let body = SKPhysicsBody(circleOfRadius: 10)
        
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 1
        body.isDynamic = true
        
        node.fillColor = .systemPink
        node.physicsBody = body
        node.name = "tail"
        
        return node
    }
}




