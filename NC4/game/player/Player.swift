//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


class Player: AbstractGameObject, Lifeable {
    
    var lifes: Int! = 1000
    var tail: [Tail]
    let generator =  UIImpactFeedbackGenerator(style: .heavy)
//    let generator =  UIImpactFeedbackGenerator(style: .soft)
    
    override init(_ node: SKNode, _ scene: GameScene) {
        self.tail = [Tail]()
        super.init(node, scene)
        
        for _ in 1...self.lifes {
            self.increaseTail()
        }
        
        
        
    }
    
    func onLifeTaken() {
        self.lifes -= 1
        self.decreaseTail()
        self.scene.playerDidScore()

        generator.impactOccurred()
    }
    
    func onLifePicked(_ amount: Int) {
        self.lifes += amount
        for _ in 1...amount {
            self.increaseTail()
        }
    }
    
    func getPointsNode() -> SKLabelNode {
        return self.node.childNode(withName: "point") as! SKLabelNode
    }
    
    override func update(_ deltaTime: TimeInterval) {
        self.getPointsNode().text = "\(self.lifes!)"
        
        self.tail.forEach { $0.update(deltaTime) }
    }
    
    func isDead() -> Bool {
        return self.lifes < 0
    }
    
    
    
    func increaseTail() {
        let node = self.getTailNode()
        let tail = Tail(self, CGFloat(self.tail.count + 1), node, self.scene)
        
        self.tail.append(tail)
        
        node.position = CGPoint(x: self.tail.last?.node.position.x ?? self.node.position.x, y: self.node.position.y + CGFloat( -35 * self.tail.count))
                
        self.scene.addChild(node)
    }
    
    
    
    func decreaseTail() {
        if let last = self.tail.last {
            last.node.removeFromParent()
            self.tail.removeLast()
        }
        
    }
    
    
    
    func getTailNode() -> SKSpriteNode {
        let node = self.scene.childNode(withName: "tail")!.copy() as! SKSpriteNode
        
        node.removeFromParent()
        node.name = "tail"

        return node
    }
}





