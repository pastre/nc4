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
    
    private init() {
        
        // Fixes ads being initialized with false
        if !UserDefaults.standard.bool(forKey: "hasFlipped") {
            self.setAds(enabled: true)
            UserDefaults.standard.set(true, forKey: "hasFlipped")
        }
    }
    
    enum StorageKeys: String {
        case highScore
        case audioEnabled
        case vibrationEnabled
        case disclaimer
        case adsEnabled
        
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: StorageKeys.highScore.rawValue)
    }
    
    func hasDisplayedDisclaimer() -> Bool {
        
        UserDefaults.standard.bool(forKey: StorageKeys.disclaimer.rawValue)
    }
    
    func setDisclaimerDisplayed() {
        UserDefaults.standard.set(true, forKey: StorageKeys.disclaimer.rawValue)
    }
    
    private func setHighScore(to newVal: Int) {
        UserDefaults.standard.set(newVal, forKey: StorageKeys.highScore.rawValue)
    }
    
    
    func updateScoreIfNeeded(to newVal: Int) -> Bool {
        if newVal > self.getHighScore() {
            self.setHighScore(to: newVal)
        }
        
        return newVal > self.getHighScore()
    }
    
    
    func isAudioDisabled() -> Bool { UserDefaults.standard.bool(forKey: StorageKeys.audioEnabled.rawValue) }
    func setAudioDisabled(to newValue: Bool) { UserDefaults.standard.set(newValue, forKey: StorageKeys.audioEnabled.rawValue) }
    
    
    func isVibrationDisabled() -> Bool { UserDefaults.standard.bool(forKey: StorageKeys.vibrationEnabled.rawValue) }
    
    func setVibrationDisabled(to newValue: Bool) { UserDefaults.standard.set(newValue, forKey: StorageKeys.vibrationEnabled.rawValue) }
    
    
    func setAds(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: StorageKeys.adsEnabled.rawValue)
    }
    
    func canShowAds() -> Bool {
        UserDefaults.standard.bool(forKey: StorageKeys.adsEnabled.rawValue)
    }
}
