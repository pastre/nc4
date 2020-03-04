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
    
    func onLifeTaken() {
        self.lifes -= 1
    }
    
    func onLifePicked(_ amount: Int) {
        self.lifes += amount
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
    
}




