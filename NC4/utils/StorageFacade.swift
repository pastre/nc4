//
//  StorageFacade.swift
//  NC4
//
//  Created by Bruno Pastre on 10/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import Foundation



class StorageFacade {
    
    static let instance = StorageFacade()
    private init() {}
    
    enum StorageKeys: String {
        case highScore
        case audioEnabled
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: StorageKeys.highScore.rawValue)
    }
    
    
    private func setHighScore(to newVal: Int) {
        UserDefaults.standard.set(newVal, forKey: StorageKeys.highScore.rawValue)
    }
    
    func updateScoreIfNeeded(to newVal: Int) {
        if newVal > self.getHighScore() {
            self.setHighScore(to: newVal)
        }
    }
    
    func isAudioDisabled() -> Bool { UserDefaults.standard.bool(forKey: StorageKeys.audioEnabled.rawValue) }
    func setAudioDisabled(to newValue: Bool) { UserDefaults.standard.set(newValue, forKey: StorageKeys.audioEnabled.rawValue) }
    
}
