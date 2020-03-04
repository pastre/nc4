//
//  Player.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit


class Player: AbstractGameObject, Lifeable {
    var lifes: Int!
    
    func onLifeTaken() {
        self.lifes -= 1
    }
    
    func onLifePicked(_ amount: Int) {
        self.lifes += amount
    }
}




