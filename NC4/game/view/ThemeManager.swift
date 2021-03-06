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
    var shouldMove: Bool = true
    
    init(_ scene: GameScene) {
        self.scene = scene
    }
    
    func update(_ deltaTime: TimeInterval) {
        let dY = self.shouldMove ?  CGFloat(deltaTime) * self.scene.speedManager.getCurrentSpeed() : 0
        
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
        
        if self.currentThemes.count == 0 {
            self.spawnNewTheme()
            return
        }
        
        guard let node = self.currentThemes.last else { return }
        
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
        let themeCount = 1
        let node = self.scene.childNode(withName: "theme\(Int.random(in: 1...themeCount))")!.copy() as! SKSpriteNode
        
        node.removeFromParent()
        node.zPosition = ZPosition.background.rawValue
        let size = self.scene.getBounds().width * 2
        node.scale(to: CGSize(width: size, height: size))
        
        return node
    }
    
    func configureStartTheme() {
        
        let nodeH = self.getRandomTheme().size.height
        let sceneH = self.scene.getBounds().height
        
        let baseY = sceneH - (nodeH / 2)
        
        
        for i in 0...2 {
            let y = baseY - CGFloat(i) * nodeH
            let node = self.getRandomTheme()
            
            node.position = CGPoint(
                x: 0,
                y: y
            )
            
            self.scene.addChild(node)
            self.currentThemes.append(node)
        }

    }
    
}


