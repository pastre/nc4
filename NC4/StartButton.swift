//
//  StartButton.swift
//  NC4
//
//  Created by Bruno Pastre on 09/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

class StartButtonNode: SKSpriteNode{
    
    
    func configureSubnodes() {
        let circleRadius: CGFloat = 20
        let baseNode = SKShapeNode(circleOfRadius: circleRadius)
        
        baseNode.fillColor = .black
        baseNode.strokeColor = .clear
        
        let maxW: Int = Int(self.size.width/2)
        let maxH = Int(self.size.height / 2)
        for i in -maxW...maxW {
            for j in -maxW...maxW {
                
            }
        }
    }
    
    
}
