//
//  ShopItem.swift
//  NC4
//
//  Created by Bruno Pastre on 31/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit

class ShopItem: Codable {
    var imageName: String
    var isUnlocked: Bool
    var price: Int
    
    func getDisplayImage() -> UIImage {
        if self.isUnlocked {
            return UIImage(named: self.imageName)!
        }
        return UIImage(named: self.imageName + "locked")!
    }
}

class ShopItemManager {
    
    static let instance = ShopItemManager()
    
    var items: [ShopItem]!
    
    
    private init() {
        self.items = [ShopItem]()
    }

    
    func item(at indexPath: IndexPath)  -> ShopItem {
        return self.items[indexPath.item]
    }
}
