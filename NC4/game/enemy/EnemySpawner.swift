//
//  EnemySpawner.swift
//  NC4
//
//  Created by Bruno Pastre on 10/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class EnemySpawner: Updateable, SceneSupplicant {
    
    var scene: GameScene!
    var enemyFactory: EnemyGroupFactory<EnemyGroup>!
    
    var currentEnemyGroup: EnemyGroup?
    
    
    internal init(scene: GameScene?) {
        self.scene = scene
        
        self.enemyFactory = EnemyGroupFactory(scene: self.scene)
    }
    
    func update(_ deltaTime: TimeInterval) {
        if let enemyGroup = self.currentEnemyGroup {
            
            enemyGroup.update(deltaTime)
            
            self.scene.coinSpawner.shouldMoveCoins = !enemyGroup.isInContact()
            self.scene.themeManager.shouldMove = !enemyGroup.isInContact()
            
            if enemyGroup.isOutOfScreen(self.scene.getBounds()) {
                enemyGroup.despawn()
                self.currentEnemyGroup = nil
            }
        } else {
            self.spawnEnemyGroup()
        }
    }
    
    func spawnEnemyGroup() {
        let newEnemyGroup = self.enemyFactory.getGameObject()
        
        self.scene.addChild(newEnemyGroup.node)
        
        newEnemyGroup.node.position.y = self.scene.getBounds().height
        
        self.currentEnemyGroup = newEnemyGroup
    }
    
}
