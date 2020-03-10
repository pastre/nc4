//
//  GameScene.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerNode: SKSpriteNode!
    var scoreNode: SKLabelNode!
    
    var backgroundSpawner: BackgroundSpawner!
    var player: Player!
    var currentEnemyGroup: EnemyGroup?
    var enemyFactory: EnemyGroupFactory<EnemyGroup>!
    var coinSpawner: CoinSpawner!

    var vc: GameViewController?
    var speedManager = SpeedManager()
    
    private var lastUpdate = TimeInterval()
    private var lastTouchPos: CGPoint?
    private var currentDeltaTime: TimeInterval!
    var lastContact: SKPhysicsContact?
    var lastContactTimestamp: TimeInterval?
    
    var score: Int!
    
    
    var realPaused: Bool = false {
        didSet {
            self.configureScoreLabel()
            self.isPaused = realPaused
        }
    }
    
    override var isPaused: Bool {
        didSet {
            if (self.isPaused == false && self.realPaused == true) {
                self.isPaused = true
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.score = 0
        self.physicsWorld.contactDelegate = self
        
        self.enemyFactory = EnemyGroupFactory(scene: self)
        self.coinSpawner = CoinSpawner(scene: self)
        
        self.playerNode = self.childNode(withName: "player") as! SKSpriteNode
        self.scoreNode = self.childNode(withName: "score") as! SKLabelNode
        
        playerNode.physicsBody?.categoryBitMask = ContactMask.player.rawValue
        playerNode.physicsBody?.collisionBitMask = ContactMask.wall.rawValue
        playerNode.physicsBody?.contactTestBitMask = ContactMask.enemy.rawValue | ContactMask.coin.rawValue
        
        self.player = Player(playerNode, self)
        self.backgroundSpawner = BackgroundSpawner(scene: self)
        
        self.configureBg()
    }
    
    func configureBg() {
        let texture = SKTexture(radialGradientWithColors: [.init(white: 0.4, alpha: 1), .init(white: 0.2, alpha: 1)], locations: [0, 1], size: self.size )
        let bgNode = SKSpriteNode(texture: texture)
        
        bgNode.zPosition = -100
        
        self.addChild(bgNode)
    }
    
    
    override func didSimulatePhysics() {
        
        self.playerNode.position.x = clamp(self.playerNode.position.x, self.getBounds().minX, self.getBounds().width)
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
        
        self.currentDeltaTime = deltaTime
        
        
        self.getUpdateables().forEach { $0.update(deltaTime) }
        
        if let enemyGroup = self.currentEnemyGroup {
            
            enemyGroup.update(deltaTime)

            self.coinSpawner.shouldMoveCoins = !enemyGroup.isInContact()
            self.backgroundSpawner.shouldRun = !enemyGroup.isInContact()
            
            
            if enemyGroup.isOutOfScreen(self.getBounds()) {
                enemyGroup.despawn()
                self.currentEnemyGroup = nil
            }
        } else {
            self.spawnEnemyGroup()
        }
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
        
        
        guard contact.contactNormal.dx <= 0.01 else {
            self.lastContact = contact
            return
        }
        
        if nodeA.name == "player" {
            self.playerCollisionStarted(playerNode: nodeA, other: nodeB)
        } else if nodeB.name == "player" {
            self.playerCollisionStarted(playerNode: nodeB, other: nodeA)
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        guard nodeA.name == "player" || nodeB.name == "player" else { return }
        
        if nodeA.name == "player" {
            self.playerCollisionCompleted(playerNode: nodeA, other: nodeB)
        } else if nodeB.name == "player" {
            self.playerCollisionCompleted(playerNode: nodeB, other: nodeA)
        }
        
    }
    
    func hasPickedCoin(_ node: SKNode) -> Bool {
        
        if let reward = self.coinSpawner.onCoinPicked(node) {
            self.player.onLifePicked(reward)
        }
        
        return node.name == "coin"
    }
    
    func playerCollisionStarted(playerNode: SKNode, other: SKNode) {
        if other.name!.contains("enemy")  {
            guard let group = self.currentEnemyGroup else { return }
            group.onContact(with: other as! SKSpriteNode)
        }
        
    }
    
    func playerCollisionCompleted(playerNode: SKNode, other: SKNode) {
        self.currentEnemyGroup?.onContactStopped(with: other as! SKSpriteNode)
        
    }

    
    // MARK:  Player helper function
    
    func playerDidScore() {
        self.score += 1
        self.scoreNode.text = "Score: \(self.score!)"
    }
    
    func movePlayer(_ dx: CGFloat) {

        let vx = (abs(dx) > 1 ? dx : 0) / CGFloat(self.currentDeltaTime)
        
        self.playerNode.physicsBody?.velocity = CGVector(dx: vx, dy: 0)
        
        self.playerNode.position.x = clamp(self.playerNode.position.x, (self.getBounds().origin.x + self.playerNode.size.width / 2), (self.getBounds().width - self.playerNode.size.width / 2))
    }
    
    // MARK: - Touch callbacks
    
    func touchDown(atPoint pos : CGPoint) {
        self.lastTouchPos = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let lastTouch = self.lastTouchPos {
            self.movePlayer(pos.x - lastTouch.x)
        }
        
        self.lastTouchPos = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        self.playerNode.physicsBody?.velocity = .zero
        
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
        return CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width / 2, height: self.size.height / 2)
    }
    
    func getUpdateables() -> [Updateable] {
        return [
            self.player,
            self.coinSpawner,
            self.backgroundSpawner,
            self.speedManager
        ]
    }
    
    func configureScoreLabel() {
        if self.realPaused {
            self.setHighscoreLabel()
            return
        }
        
        self.setScoreLabel()
        
    }
    
    func setHighscoreLabel() {
        let score = StorageFacade.instance.getHighScore()
        self.scoreNode.text = "High score: \(score)"
    }
    
    func setScoreLabel() {
        self.scoreNode.text = "Score: 0"
    }
}
