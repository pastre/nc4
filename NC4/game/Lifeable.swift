//
//  Lifeable.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import Foundation

protocol Lifeable {
    var lifes: Int! { get set }
    
    func isDead() -> Bool
    func onLifeTaken()
    func onLifePicked(_ amount: Int)
}

extension Lifeable {
    
    func isDead() -> Bool { return self.lifes <= 0 }
    func onLifePicked(_ amount: Int) {
        
    }
}
