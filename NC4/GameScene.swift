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

class GameScene: SKScene {
    
    var playerNode: SKSpriteNode!
    var lastTouchPos: CGPoint?
    
    override func didMove(to view: SKView) {
        self.playerNode = self.childNode(withName: "player") as! SKSpriteNode
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        self.lastTouchPos = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let lastTouch = self.lastTouchPos {
            let deltaX = pos.x - lastTouch.x
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
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func getBounds() -> CGRect {
        return CGRect(x: -self.scene!.size.width / 2, y: -self.scene!.size.height / 2, width: self.scene!.size.width / 2, height: self.scene!.size.height / 2)
    }
    
}
