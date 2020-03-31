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
    
    func getBaseDisplayImage() -> UIImage  {

        let img = UIImage(named: self.imageName)!
        
        return img.withHorizontallyFlippedOrientation()
    }
    
    func getDisplayImage() -> UIImage {
        let base = self.getBaseDisplayImage()
        if self.isUnlocked {
            return base
        }
        return UIImage(named: self.imageName + "locked")!
    }
}

class ShopItemManager {
    
    static let instance = ShopItemManager()
    
    var items: [ShopItem]!
    
    
    private init() {
        self.items = [ShopItem]()
        for i in 1...22 {
            let newItem = ShopItem(imageName: "weapon\(i)", isUnlocked: true, price: 100)
            self.items.append(newItem)
        }
    }
    
    func item(at indexPath: IndexPath)  -> ShopItem {
        return self.items[indexPath.item]
    }
}
