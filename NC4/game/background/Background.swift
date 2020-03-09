//
//  Background.swift
//  NC4
//
//  Created by Bruno Pastre on 06/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Background: AbstractGameObject {
    var shouldGoDown: Bool = true
    
    override func update(_ deltaTime: TimeInterval) {
        self.wiggle(deltaTime)
        if shouldGoDown {
            self.node.position.y -= CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed() / 4
        }
        
    }
    
    func wiggle(_ deltaTime: TimeInterval) {
        
    }
}

