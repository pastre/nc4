//
//  GameObject.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

protocol Updateable {
    
    func update(_ deltaTime: TimeInterval)
}

protocol SceneSupplicant {
    var scene: GameScene! { get set }
}

class AbstractGameObject: Updateable, SceneSupplicant {
    var node: SKNode!
    var scene: GameScene!
    
    init(_ node: SKNode, _ scene: GameScene) {
        self.node = node
        self.scene = scene
    }
    
    func update(_ deltaTime: TimeInterval) {
        
    }
}

