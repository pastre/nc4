//
//  Enemy.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Enemy: AbstractGameObject, Lifeable {
    var lifes: Int! = 0
    var lastContact: TimeInterval! = TimeInterval(2)
    var minContactThreshold = TimeInterval(0.2)

    func configure() {
        let currentNodeCount = self.scene.player.getLifeCount()
        
        self.lifes = .random(in: (currentNodeCount / 2)...(currentNodeCount  * 2))
        
        self.getTextureNode().texture = self.getRandomTexture()
        
    }
    
    override func update(_ deltaTime: TimeInterval) {
        self.lastContact += deltaTime
        
        self.getLabelNode().text = "\(self.lifes!)"
        self.minContactThreshold = TimeInterval(0.2 * self.scene.speedManager.getProgress())
    }
    
    func canCollide() -> Bool {
        self.lastContact > minContactThreshold
    }
    
    func onLifeTaken() {
        self.lifes -= 1
        self.animateCollisionParticle()
        self.animateCollision()
    }
    
    func animateCollision() {
        let scale = SKAction.scale(by: 1.2, duration: 0.05)
        
        self.getTextureNode().run(SKAction.sequence([scale, scale.reversed()]))
    }
    
    func animateCollisionParticle() {
        let particleNode = EnemyHitParticleLoader.getParticle()
        let actionDuration = self.scene.speedManager.getProgress()
        
        let action = EnemyHitParticleLoader.getAction(Double(actionDuration))
        
        self.node.addChild(particleNode)
        
        particleNode.run(action)
    }
    
    func onCollision() {
        if self.canCollide() {
            self.scene.player.onLifeTaken()
            self.onLifeTaken()
            self.lastContact = TimeInterval(0)
        }
    }
    
    func isDead() -> Bool { self.lifes <= 0 }
    
    func getWallNode() -> SKSpriteNode {
        return self.node.childNode(withName: "wall") as! SKSpriteNode
    }
    
    func getLabelNode() -> SKLabelNode {
        return self.node.childNode(withName: "point") as! SKLabelNode
    }
    
    func getTextureNode() -> SKSpriteNode {
        return self.node.childNode(withName: "texture") as! SKSpriteNode
    }
    
    func getRandomTexture() -> SKTexture {
        let textures = [ "school", "bank", "market"]
        
        return SKTexture(imageNamed: textures.randomElement()!)
    }
    
    
    
}


class EnemyHitParticleLoader {
    
    private static var particles: [SKSpriteNode]!
    
    static func load() {
        var textures = [SKTexture]()
        for i in 1...4 {
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
        
        node.scale(to: .init(width: 60, height: 60))
    }
    
    static func getParticle() -> SKSpriteNode {
        
        return self.particles.randomElement()!.copy() as! SKSpriteNode
    }
    
    static func getAction(_ durationMultiplier: Double) -> SKAction {
        
        let fade = SKAction.fadeAlpha(to: 0.5, duration: 0.5 * durationMultiplier)
        let rotate = SKAction.rotate(byAngle: .pi / 4 * ( Bool.random() ? 1 : -1), duration: 0.5 * durationMultiplier)
        let translate = SKAction.move(by: CGVector(dx: .random(in: 80...130) * ( Bool.random() ? 1 : -1), dy: .random(in: 50...80)), duration: 0.5 * durationMultiplier)
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([fade, rotate, translate])
        
        return SKAction.sequence([group, remove])
        
    }
}
