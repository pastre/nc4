//
//  Utils.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static func -(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
    }
}


func clamp<T: Comparable>(_ value: T, _ floor: T, _ roof: T) -> T {
    return min(max(value, floor), roof)
}
