//
//  Tail.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Tail: AbstractGameObject {
    var player: Player!
    var index: CGFloat!
    
    init(_ player: Player, _ index: CGFloat, _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.index = index
        self.player = player
    }
    
    override func update(_ deltaTime: TimeInterval) {
        let playerPos = self.player.node.position
        let nodePos = self.node.position
        let speed = 1 / self.index * 0.75
        
        
        let distance = nodePos - playerPos
        let theta = atan(distance.y / distance.x) + (distance.x > 0 ? .pi / 2 : -.pi / 2 )
        
//        self.node.zRotation = theta
        self.node.position.x -= distance.x * CGFloat(speed)
    }
}
