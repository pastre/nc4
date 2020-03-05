//
//  GameEventListener.swift
//  NC4
//
//  Created by Bruno Pastre on 05/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import Foundation

enum GameEvent: String {
    case gameStart
    case gameOver
    
    func asNotificationName() -> Notification.Name {
        return Notification.Name.init(self.rawValue)
    }
}

@objc protocol GameEventListener {
    
    @objc func onGameStart()
    @objc func onGameOver()
    
}

class GameEventBinder {
    
    static let center = NotificationCenter.default
    
    static func bind(_ toBind: GameEventListener, to event: GameEvent) {
        switch event {
        case .gameOver:
            self.center.addObserver(toBind, selector: #selector(toBind.onGameOver), name: event.asNotificationName(), object: nil)
        case .gameStart:
            self.center.addObserver(toBind, selector: #selector(toBind.onGameStart), name: event.asNotificationName(), object: nil)
        }
    }
    
}
