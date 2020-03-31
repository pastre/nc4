//
//  ShopItem.swift
//  NC4
//
//  Created by Bruno Pastre on 31/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit

class ShopItem: Codable {
    
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

class ShopItemManager {
    
    static let instance = ShopItemManager()
    
    var items: [ShopItem]!
    
    
    private init() {
        self.items = [ShopItem]()
        for i in 1...22 {
            let newItem = ShopItem(imageName: "weapon\(i)", isUnlocked: .random(), price: 100)
            self.items.append(newItem)
        }
    }
    
    func item(at indexPath: IndexPath)  -> ShopItem {
        return self.items[indexPath.item]
    }
}
