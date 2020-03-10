//
//  ThemeManager.swift
//  NC4
//
//  Created by Bruno Pastre on 10/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


class ThemeManager: Updateable, SceneSupplicant {
    
    var scene: GameScene!
    var currentThemes =  [SKSpriteNode]()
    
    init(_ scene: GameScene) {
        self.scene = scene
    }
    
    func update(_ deltaTime: TimeInterval) {
        let dY = CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed()
        
        self.currentThemes.forEach { node in
            node.position.y -= dY
        }
        
        self.clearThemes()
        self.spawnIfPossible()
    }
    
    func clearThemes() {
        self.currentThemes.forEach { self.removeNodeIfPossible($0) }
        self.currentThemes = self.currentThemes.filter { $0.parent != nil }
    }
    
    
    func removeNodeIfPossible(_ node: SKSpriteNode) {
        
        if node.position.y + node.size.height / 2 < self.scene.getBounds().minY {
            node.removeFromParent()
        }
    }
    
    func spawnIfPossible() {
        if self.currentThemes.count >= 2 { return }
        if self.currentThemes.count == 0 {
            self.spawnNewTheme()
            return
        }
        
        guard let node = self.currentThemes.first else { return }
        
        if self.scene.getBounds().height - node.position.y > node.size.height / 2 {
            self.spawnNewTheme()
        }
    }
    
    func spawnNewTheme() {
        let node = self.getRandomTheme()
        
        node.position = CGPoint(
            x: 0,
            y: self.scene.getBounds().height + node.size.height / 2
        )
        
        self.scene.addChild(node)
        
        self.currentThemes.append(node)
    }

    func getRandomTheme() -> SKSpriteNode {
        let node = self.scene.childNode(withName: "theme\(Int.random(in: 1...1))")!.copy() as! SKSpriteNode
        
        node.removeFromParent()
        node.zPosition = ZPosition.background.rawValue
        
        return node
    }
}


