//
//  GameScene.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit
import GameplayKit

func clamp<T: Comparable>(_ value: T, _ floor: T, _ roof: T) -> T {
    return min(max(value, floor), roof)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerNode: SKSpriteNode!
    var player: Player!
    var currentEnemyGroup: EnemyGroup?
    var enemyFactory: EnemyGroupFactory<EnemyGroup>!
    
    
    var coinSpawner: CoinSpawner!
    
    
    var lastTouchPos: CGPoint?
    
    var vc: GameViewController?
    
    private var lastUpdate = TimeInterval()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.enemyFactory = EnemyGroupFactory(scene: self)
        self.coinSpawner = CoinSpawner(scene: self)
        
        self.playerNode = self.childNode(withName: "player") as! SKSpriteNode
        
        playerNode.physicsBody?.categoryBitMask = ContactMask.player.rawValue
        playerNode.physicsBody?.collisionBitMask = ContactMask.wall.rawValue
        playerNode.physicsBody?.contactTestBitMask = ContactMask.enemy.rawValue | ContactMask.coin.rawValue
        playerNode.physicsBody?.restitution = 0
        playerNode.physicsBody?.isDynamic = true
        
        self.player = Player(playerNode, self)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if self.player.isDead() {
            self.vc?.onGameOver()
        }
        
        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }
        
        let deltaTime = currentTime - self.lastUpdate
        self.lastUpdate = currentTime
        
        if deltaTime > 0.1 { return }
        
        self.getUpdateables().forEach { $0.update(deltaTime) }
        
        if let enemyGroup = self.currentEnemyGroup {
            enemyGroup.update(deltaTime)
            
            if enemyGroup.isOutOfScreen(self.getBounds()) {
                enemyGroup.despawn()
                self.currentEnemyGroup = nil
            }
        } else {
//            self.spawnEnemyGroup()
        }
    }
    
    func getUpdateables() -> [Updateable] {
        return [
            self.player,
            self.coinSpawner
        ]
    }
    
    func spawnEnemyGroup() {
        let newEnemyGroup = self.enemyFactory.getGameObject()
        
        self.addChild(newEnemyGroup.node)
        
        newEnemyGroup.node.position.y = self.getBounds().height
        
        self.currentEnemyGroup = newEnemyGroup
    }
    
    // MARK: - Collision methods
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        guard nodeA.name == "player" || nodeB.name == "player" else { return }
        
        
        if self.hasPickedCoin(nodeA) { return }
        if self.hasPickedCoin(nodeB) { return }
        
        
        guard contact.contactNormal.dx == 0 else {
            self.lastContact = contact
            return
        }
        
        if nodeA.name == "player" {
            self.playerCollision(playerNode: nodeA, other: nodeB)
        } else if nodeB.name == "player" {
            self.playerCollision(playerNode: nodeB, other: nodeA)
        }
        
    }
    
    var lastContact: SKPhysicsContact?
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        guard nodeA.name == "enemy" || nodeB.name == "enemy" else { return }
        
        
        self.lastContact = nil
        
        
    }
    
    func hasPickedCoin(_ node: SKNode) -> Bool {
        
        if let reward = self.coinSpawner.onCoinPicked(node) {
            self.player.onLifePicked(reward)
        }
        
        return node.name == "coin"
    }
    
    func playerCollision(playerNode: SKNode, other: SKNode) {
        if other.name!.contains("enemy")  {
            guard let group = self.currentEnemyGroup else { return }
            group.onContact(with: other as! SKSpriteNode)
        }
    }

    
    // MARK: - Touch callbacks
    
    func touchDown(atPoint pos : CGPoint) {
        self.lastTouchPos = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let lastTouch = self.lastTouchPos {
            
            let deltaX = pos.x - lastTouch.x

            self.player.applySpeed(direction: deltaX > 0)
            if let lastContact = self.lastContact, lastContact.bodyA.node?.name == "player" || lastContact.bodyB.node?.name == "player" {
                
                let distanceToPlayer = lastContact.contactPoint.x - self.playerNode.position.x
                
                if distanceToPlayer * deltaX >= 0 {
                    return
                }
                
//                let debug = SKShapeNode(circleOfRadius: 2)
//                debug.fillColor = .blue
//                debug.position = lastContact.contactPoint
//
//                self.addChild(debug)
            }
            
            self.playerNode.position.x += deltaX
            
            self.playerNode.position.x = clamp(self.playerNode.position.x, self.getBounds().origin.x, self.getBounds().width)
        }
        
        self.lastTouchPos = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        self.lastTouchPos = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    func getBounds() -> CGRect {
        return CGRect(x: -self.scene!.size.width / 2, y: -self.scene!.size.height / 2, width: self.scene!.size.width / 2, height: self.scene!.size.height / 2)
    }
    
}
