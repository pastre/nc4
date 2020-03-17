//
//  EnemyHitParticleLoader.swift
//  NC4
//
//  Created by Bruno Pastre on 17/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class EnemyHitParticleLoader {
    
    private static var particles: [SKSpriteNode]!
    
    static func load() {
        var textures = [SKTexture]()
        for i in 1...16 {
            let newTexture = SKTexture(imageNamed: "impact\(i)")
            textures.append(newTexture)
        }
        
        self.particles = textures.compactMap { SKSpriteNode(texture: $0) }
        
        self.particles.forEach {
            self.configure($0)
        }
    }
    
    static func configure(_ node: SKSpriteNode) {
        // TODO: Configure node on completion
        
        node.scale(to: .init(width: 50, height: 60))
    }
    
    static func getParticle() -> SKSpriteNode {
        
        return self.particles.randomElement()!.copy() as! SKSpriteNode
    }
    
//    static func getPhysicalParticle() -> SKSpriteNode {
//        let baseParticle = self.getParticle()
//
//        let body = SKPhysicsBody(texture: baseParticle.texture!, size: baseParticle.texture!.size())
//
//        body.pinned = false
//        body.affectedByGravity = true
//        body.
//
//        return baseParticle
//    }
//
    static func getAction(_ durationMultiplier: Double) -> SKAction {
        
        
        let rotate = SKAction.rotate(byAngle: .pi / 4 * ( Bool.random() ? 1 : -1), duration: 0.5 * durationMultiplier)
        let translate = SKAction.move(
            by: CGVector(
                dx: .random(in: 60...150) * ( Bool.random() ? 1 : -1),
                dy: .random(in: 30...100)),
            duration: 0.5 * durationMultiplier
        )
        
        let group = SKAction.group([
//            fade,
            rotate,
            translate
        ])
        return group
//        return SKAction.sequence([group, remove])
        
    }
}
