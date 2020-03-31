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
        case revives
        case shopItems
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
    
    
    func setReviveCount(to newValue: Int) {
        UserDefaults.standard.set(newValue, forKey: StorageKeys.revives.rawValue)
    }
    
    func getReviveCount() -> Int { UserDefaults.standard.integer(forKey: StorageKeys.revives.rawValue) }
    
    func addRevives(_ amount: Int) {
        let newAmount = self.getReviveCount() + amount
        self.setReviveCount(to: newAmount)
    }
    func onReviveUsed() {
        let newAmount = self.getReviveCount() - 1
        self.setReviveCount(to: newAmount)
    }
    
    
    func setShopItems(to newItems: [ShopItem]) {
        if let serialized = try? JSONEncoder().encode(newItems) {
            UserDefaults.standard.set(serialized, forKey: StorageKeys.shopItems.rawValue)
        } else {
            print("Falha ao serializar! PLS REPORTA")
        }
    }
    
    func getShopItems() -> [ShopItem]? {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.shopItems.rawValue) {
            
            return try? JSONDecoder().decode([ShopItem].self, from: data)
        }
        
        return nil
    }
    
}
