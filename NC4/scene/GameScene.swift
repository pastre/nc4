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
    var zombieHeadIcon: SKSpriteNode!
    var tailNode: SKSpriteNode!

    var vc: GameViewController?
    
    var sickPeopleManager: SickPeopleManager!
    var themeManager: ThemeManager!
    var enemySpawner: EnemySpawner!
    var player: Player!
    var coinSpawner: CoinSpawner!
    var speedManager = SpeedManager()
    
    private var lastUpdate = TimeInterval()
    private var lastTouchPos: CGPoint?
    private var currentDeltaTime: TimeInterval!
    var lastContact: SKPhysicsContact?
    var lastContactTimestamp: TimeInterval?
    
    var score: Int!
    var headCount: Int = 0
    
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
    
    // MARK: Scene Configuration
    override func didMove(to view: SKView) {
        self.changeFonts()
        
        self.score = 0
        self.physicsWorld.contactDelegate = self
        
        
        self.playerNode = (self.childNode(withName: "player") as! SKSpriteNode)
        self.tailNode = (self.childNode(withName: "tail") as! SKSpriteNode)
        self.scoreNode = (self.childNode(withName: "score") as! SKLabelNode)
        self.zombieHeadIcon = self.childNode(withName: "zombieHeadIcon") as! SKSpriteNode
              
        
        playerNode.physicsBody?.categoryBitMask = ContactMask.player.rawValue
        playerNode.physicsBody?.collisionBitMask = ContactMask.wall.rawValue
        playerNode.physicsBody?.contactTestBitMask = ContactMask.enemy.rawValue | ContactMask.coin.rawValue

        self.setSkin(to: ShopItemManager.instance.equippedItem.getSkin())
        
        
        self.player = Player(playerNode, self)
        self.sickPeopleManager = SickPeopleManager(scene: self)
        self.coinSpawner = CoinSpawner(scene: self)
        self.themeManager = ThemeManager(self)
        self.enemySpawner = EnemySpawner(scene: self)
        
        self.configureBg()
        
        self.themeManager.configureStartTheme()
        AudioManager.shared.update()
        
        
    }
    
    func configureBg() {
        
        let bgNode = SKSpriteNode(color: .init(hue: 166.360, saturation: 0.21, brightness: 0.8, alpha: 1), size: self.size)
        
        bgNode.zPosition = -100
        
        self.addChild(bgNode)
    }
    
    func setSkin(to image: UIImage) {
        
        print("Setting skin " )
        let texture = SKTexture(image: image)
        let ratio = image.size.height / image.size.width
        
        texture.usesMipmaps = true
        
        self.playerNode.texture = texture
        playerNode.scale(to: .init(width: 40, height: min(40 * ratio, 80)))
        
        self.tailNode.texture = texture
        
    }
    
    // MARK: - Scene overrides
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

    }
    
    
    // MARK: - Collision methods
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        guard nodeA.name == "player" || nodeB.name == "player" else { return }
        
        if self.hasPickedCoin(nodeA) { return }
        if self.hasPickedCoin(nodeB) { return }
        
        if self.hasPickedHead(nodeA) { return }
        if self.hasPickedHead(nodeB) { return }
        
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
        
        guard nodeA.name == "enemy" || nodeB.name == "enemy" else { return }
        
        
        if nodeA.name == "player" {
            self.playerCollisionCompleted(playerNode: nodeA, other: nodeB)
        } else if nodeB.name == "player" {
            self.playerCollisionCompleted(playerNode: nodeB, other: nodeA)
        }
        
    }
    
    func hasPickedHead(_ node: SKNode) -> Bool {
        guard node.name == "head", node.parent != nil else { return false}
        
        self.headCount += 1
        self.playerDidScore()
        
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = ContactMask.none.rawValue
        node.physicsBody?.contactTestBitMask = ContactMask.none.rawValue
        
        let duration: TimeInterval = 1
        
        let transformAction = SKAction.move(to: self.zombieHeadIcon.position, duration: duration)
        let rotateAction = SKAction.rotate(byAngle: 2 * .pi, duration: duration)
//        let repeatAction = SKAction.repeatForever(rotateAction)
        let group = SKAction.group([rotateAction, transformAction])
        let resultAction = SKAction.sequence([ group , SKAction.removeFromParent() ])
        
        node.run(resultAction)
        
        return true
    }
    
    func hasPickedCoin(_ node: SKNode) -> Bool {
        
        if let reward = self.coinSpawner.onCoinPicked(node) {
            self.player.onLifePicked(reward)
        }
        
        return node.name == "coin"
    }
    
    func playerCollisionStarted(playerNode: SKNode, other: SKNode) {
        if other.name!.contains("enemy")  {
            guard let group = self.enemySpawner.currentEnemyGroup else { return }
            group.onContact(with: other as! SKSpriteNode)
        }
        
    }
    
    func playerCollisionCompleted(playerNode: SKNode, other: SKNode) {
        self.enemySpawner.currentEnemyGroup?.onContactStopped(with: other as! SKSpriteNode)
        
    }
    
    
    // MARK: - Player helper function
    
    func playerDidRevive() {
        self.enemySpawner.forceDespawnEnemyGroup()
        
        while self.player.lifes != 10 {
            self.player.onLifePicked(1)
        }
        
        self.realPaused = false

    }
    
    func playerDidScore() {
        self.score += 1
        self.scoreNode.text = String(format: "%03d", self.headCount)
    }
    
    func movePlayer(_ dx: CGFloat) {

        if self.currentDeltaTime == nil { return }
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
    
    // MARK: - Helpers
    
    func getBounds() -> CGRect {
        return CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width / 2, height: self.size.height / 2)
    }
    
    func getUpdateables() -> [Updateable] {
        return [
            self.player,
            self.coinSpawner,
            self.themeManager,
//            self.backgroundSpawner,
            self.speedManager,
            self.enemySpawner,
            self.sickPeopleManager
        ]
    }
    
    // MARK: - ScoreLabel methods
    
    func configureScoreLabel() {
        defer { self.positionLabel() }
        self.scoreNode.fontSize = 40
        if self.realPaused {
            self.scoreNode.isHidden = true
            self.zombieHeadIcon.isHidden = true
            return
        }

        self.scoreNode.isHidden = false
        self.zombieHeadIcon.isHidden = false
        self.setScoreLabel()
    }
    
    func positionLabel() {
        let scoreX = self.getBounds().origin.x + (self.scoreNode.frame.width / 2) + 20
        self.scoreNode.position = CGPoint(
            x: scoreX,
            y: self.getBounds().height - (self.scoreNode.frame.height) - 60)
        self.scoreNode.color = UIColor(rgb: 0x002B5B)
        
        let icon = self.zombieHeadIcon!
        
        let ratio = icon.size.width / icon.size.height
        let size = self.scoreNode.frame.height
        icon.scale(to: CGSize(width: ratio * size, height: size))
        
        icon.position = CGPoint(x:
            scoreX + scoreNode.frame.width / 2 + icon.size.width / 2 + 5,
                                y: self.scoreNode.position.y + icon.size.height / 2 )
    }
    
    
    private func setHighscoreLabel() {
        let score = StorageFacade.instance.getHighScore()
        self.scoreNode.text = "High score: \(score)"
    }
    
    private func setScoreLabel() {
        self.scoreNode.text = "000"
    }
    
    
    func changeFonts() {
        visit { (node) -> () in
            if let label = node as? SKLabelNode {
//                label.fontName = "NCT Torin"
//                label.fontName = "HoeflerText-Black"
//                label.addStroke(color: .black, width: 4)
//                label.fontSize = 20
            }
        }
    }
    
    
}


extension SKNode {
    func visit(logic: (_ node:SKNode) -> ()) {
        logic(self)
        children.forEach { $0.visit(logic: logic) }
    }
}
