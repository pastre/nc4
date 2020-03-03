//
//  GameObject.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class AbstractGameObject {
    var node: SKNode!
    var scene: SKScene!
    
    init(_ node: SKNode, _ scene: SKScene) {
        self.node = node
        self.scene = scene
    }
    
    func update(_ deltaTime: TimeInterval) {
        
    }
}

