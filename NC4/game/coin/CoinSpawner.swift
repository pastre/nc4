//
//  CoinSpawner.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class CoinSpawner: SceneSupplicant, Updateable {
    
    var coinFactory: CoinFactory<Coin>!
    var scene: GameScene!
    var coins: [Coin]!
    
    let spawnThreshold = TimeInterval(2)
    
    var currentSpawnTimer = TimeInterval(4)
    var shouldMoveCoins: Bool = true
    
    
    internal init(scene: GameScene) {
        self.scene = scene

        self.coinFactory = CoinFactory<Coin>(scene: self.scene)
        self.coins = [Coin]()
    }
    
    func update(_ deltaTime: TimeInterval) {
        self.currentSpawnTimer += deltaTime
        
        if self.shouldMoveCoins {
            self.coins.forEach { $0.update(deltaTime)  }
        }
        
        if currentSpawnTimer > self.spawnThreshold {
            self.spawn()
            self.currentSpawnTimer -=  self.spawnThreshold
        }
        
        self.clearNodes()
        
    }
    
    func clearNodes() {
        for (i, coin)  in self.coins.enumerated()  {
            if coin.isDead() {
                self.coins.remove(at: i)
                coin.node.removeFromParent()
            }
        }
    }
    
    
    func spawn() {
        let newCoin = self.coinFactory.getGameObject()
        self.coins.append(newCoin)
        self.scene.addChild(newCoin.node)
    }
    
    func onCoinPicked(_ node: SKNode) -> Int? {
        
        for (i, coin) in self.coins.enumerated() {
            if coin.node == node {
                coin.node.removeFromParent()
                self.coins.remove(at: i)
                return coin.lifes
            }
        }
        
        return nil
    }
    
    
    func onCollisionStarted() {
        self.shouldMoveCoins = false
    }
    
    func onCollisionEnded() {
        self.shouldMoveCoins = true
    }
    
    
}

