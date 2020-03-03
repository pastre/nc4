//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class Player: AbstractGameObject {
    
    override func update(_ deltaTime: TimeInterval) {
        
    }
    
    
}


class EnemyGroup: AbstractGameObject {
    
    override func update(_ deltaTime: TimeInterval) {
        let deltaY = CGFloat(deltaTime) * 100
        
        self.node.position.y -= deltaY
        
    }
    
    func isOutOfScreen(_ bounds: CGRect) -> Bool {
        return self.node.position.y < bounds.minY
    }
    
    func despawn() {
        self.node.removeFromParent()
    }
    
    
}

class EnemyGroupFactory: SceneSupplicant {
    
    var scene: GameScene!
    var baseNode: SKNode!
    
    internal init(scene: GameScene?) {
        self.scene = scene
        
        let enemyRootNode = self.scene.childNode(withName: "enemyGroup")
        
        self.baseNode = enemyRootNode!
    }
    
    func getEnemyGroup() -> EnemyGroup {
        let clonedNode = self.baseNode.copy() as! SKNode
        return EnemyGroup(clonedNode, self.scene)
    }
}
