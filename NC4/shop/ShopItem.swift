//
//  ShopItem.swift
//  NC4
//
//  Created by Bruno Pastre on 31/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit

class ShopItem: Codable, Equatable {
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        lhs.imageName == rhs.imageName
    }
    
    
    internal init(imageName: String, isUnlocked: Bool, price: Int) {
        
        self.imageName = imageName
        self.isUnlocked = isUnlocked
        self.price = price
    }
    
    var imageName: String
    var isUnlocked: Bool
    var price: Int
    
    
    func getBaseImage() -> UIImage { UIImage(named: self.imageName)! }
    
    func getBaseDisplayImage() -> UIImage  { self.getBaseImage().rotate(radians: -(.pi + .pi/4))! }
    
    func getDisplayImage() -> UIImage {
        let base = self.getBaseDisplayImage()
        
        if self.isUnlocked {
            return base
        }
        
        return base.tinted(with: .gray)!
        
    }
}

class FirstShopItem: ShopItem {
    init() {
        super.init(imageName: "player", isUnlocked: true, price: 0)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func getBaseImage() -> UIImage {
        super.getBaseImage().rotate(radians: .pi)!
    }
}

class ShopItemManager {
    
    static let instance = ShopItemManager()
    
    var items: [ShopItem]!
    var equippedItem: ShopItem!
    
    private init() {
        if let loaded = StorageFacade.instance.getShopItems() {
            print("Properly deserialized items")
            self.items = loaded
        } else {
            self.createBlankShop()
        }
        
        if let loaded = StorageFacade.instance.getEquippedItem() {
            print("Properly deserialized items")
            self.equippedItem = loaded
        } else {
            self.equipBasicItem()
        }
        
    }
    
    func equipBasicItem() {
        self.equippedItem = self.items.first!
        
        StorageFacade.instance.setEquippedItem(to: self.equippedItem)
    }
    
    private func createBlankShop() {
        
        self.items = [ShopItem]()
        self.items.append(FirstShopItem())
        for i in 1...22 {
            let newItem = ShopItem(imageName: "weapon\(i)", isUnlocked: false, price: 1000)
            self.items.append(newItem)
        }
        
        StorageFacade.instance.setShopItems(to: self.items)
    }
    
    func getDefaultItem() -> ShopItem { self.items.first! }
    
    func item(at indexPath: IndexPath)  -> ShopItem {
        return self.items[indexPath.item]
    }
}
