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
        
        particleNode.position = self.node.position.translated(by: .init(dx: 0, dy: 20))
        
        self.scene.sickPeopleManager.managePerson(node: particleNode)
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
