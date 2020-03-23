//
//  EnemyGroup.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class EnemyGroup: AbstractGameObject {
    
    var collidingEnemies: [Enemy] = [Enemy]()
    var enemies: [Enemy]!
    
        let textures = [
            "school",
            "bank",
            "market",
            "cafe",
            "gas",
            "hospital",
            "hotel",
            "police"
        ]
        
    
    init(enemies: [Enemy], _ node: SKNode, _ scene: GameScene) {
        super.init(node, scene)
        self.enemies = enemies
        
        self.balanceEnemies()
        self.unzeroEnemies()
        self.balanceSkins()
        self.balanceBackgroundTipColor()
    }
    
    func balanceSkins() {
        var skins = [String]()
        var possibleSkins = self.textures.map { $0 }
        
        for _ in self.enemies {
            guard let newSkin = possibleSkins.randomElement() else { continue }
            
            skins.append(newSkin)
            possibleSkins.removeAll { $0 == newSkin }
        }
        
        for (i, enemy) in enemies.enumerated() {
            let node = enemy.getTextureNode()
            
            let newTexture = SKTexture(imageNamed: skins[i])
            
            let ratio: CGFloat =  CGFloat(newTexture.cgImage().width) / CGFloat(newTexture.cgImage().height)
            
//            print("Ratio, ", ratio)
            
            node.texture = newTexture
//            node.scale(to: CGSize(width: node.size.width, height: node.size.height * ratio))
        }
//        print("------------")
        
    }
    
    
    // Changes the backgorund of the square that indicates the amount of points a player has
    func balanceBackgroundTipColor() {
        let colors: [UIColor] = [
            #colorLiteral(red: 0.5254901961, green: 0.7333333333, blue: 0.8470588235, alpha: 1),
            #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.6745098039, alpha: 1),
            #colorLiteral(red: 0.2549019608, green: 0.3960784314, blue: 0.5411764706, alpha: 1),
            #colorLiteral(red: 0.2549019608, green: 0.2509803922, blue: 0.4509803922, alpha: 1),
            #colorLiteral(red: 0.137254902, green: 0.04705882353, blue: 0.2, alpha: 1),
            ].map { $0.withAlphaComponent(0.75) }
        var processedLifes: [Int] = []
        var processedNodes: [SKSpriteNode] = []
        var sorted: [Int] = self.enemies.map { $0.lifes }
        
        sorted.sort { (i1, i2) -> Bool in
            i1 < i2
        }
        
        for enemy in enemies {
            guard let lifeIndex = sorted.firstIndex(of: enemy.lifes) else { continue }
            let bgNode = enemy.getTipNode()
//            let colorNode = SKShapeNode(rect: CGRect(origin: .zero, size: bgNode.size), cornerRadius: 8)
            
//            colorNode.fillColor = colors[lifeIndex]
//            colorNode.strokeColor = .clear
//            colorNode.yScale = 1 / bgNode.yScale
//            colorNode.xScale = 1 / bgNode.xScale
//            colorNode.position = .zero
            
            bgNode.color = colors[lifeIndex]
            
//            bgNode.addChild(colorNode)
        }
        
//        for (i, life) in sorted.enumerated()  {
//            let bgNode = enemies[i]
//
//
//            if let replica = processedLifes.firstIndex(of: life) {
//                let node = processedNodes[replica]
//                bgNode.color = node.color
//                continue
//            }
//
//
//
//            processedLifes.append(life)
//            processedNodes.append(bgNode)
//        }
//
        
    }
    
    func unzeroEnemies() {
        self.enemies.forEach {
            if $0.lifes == 0 {
                $0.lifes += 1
            }
        }
    }
    
    func balanceEnemies() {
        let pLifes = self.scene.player.getLifeCount()
        
        
        for enemy in enemies {
            if enemy.lifes <= pLifes { return }
        }
        
        print("Rebalanced enemies!")
        
        enemies.randomElement()!.lifes =  pLifes == 0 ? 1 : pLifes
    }
    
    override func update(_ deltaTime: TimeInterval) {
        
        
        if self.collidingEnemies.count > 0 {
            for collidingEnemy in self.collidingEnemies {

                collidingEnemy.onCollision()
                
                if collidingEnemy.isDead() {
                    collidingEnemy.node.removeFromParent()
                    self.enemies.removeAll { $0.lifes == 0}
                    self.collidingEnemies.removeAll { $0.lifes == 0}
                }
            }
            

        } else {
            // Goes down
            let deltaY = CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed()
            self.node.position.y -= deltaY
        }
        
        self.enemies.forEach { $0.update(deltaTime)}
    }
    
    
    func isOutOfScreen(_ bounds: CGRect) -> Bool {
        return self.node.position.y < bounds.minY
    }
    
    func despawn() {
        self.node.removeFromParent()
    }
    
    func onContact(with node: SKSpriteNode ) {
        guard let enemyInContact = self.enemies.filter({ (enemy) -> Bool in
            return enemy.node == node
        }).first else  { return }
        
        self.collidingEnemies.append(enemyInContact)
    }
    
    func onContactStopped(with node: SKSpriteNode) {
        self.collidingEnemies.removeAll { $0.node == node }
    }
    
    func isInContact() -> Bool {
        return self.collidingEnemies.count > 0
    }
    
    func getEnemyArea() -> SKSpriteNode {
        return self.node.childNode(withName: "enemyArea") as! SKSpriteNode
    }
    
}
