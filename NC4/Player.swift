//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Player: AbstractGameObject {
    
    override func update(_ deltaTime: TimeInterval) {
        
    }
    
    
}


class Enemy: AbstractGameObject {
    
    override func update(_ deltaTime: TimeInterval) {
        let deltaY = deltaTime * 0.1
        
//        self.node.position.y -= deltaY
    }
    
    
}
