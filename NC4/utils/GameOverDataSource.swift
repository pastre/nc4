//
//  GameOverDataSource.swift
//  NC4
//
//  Created by Bruno Pastre on 01/04/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import Foundation

protocol GameOverDataSource {
    
    func getScore() -> Int
    func getHeadCount() -> Int
    
    func onGameOverDismissed()
    func onRevive()
}
