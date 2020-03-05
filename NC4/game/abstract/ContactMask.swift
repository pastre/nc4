//
//  ContactMask.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import Foundation

enum ContactMask: UInt32 {
    case player = 0b000001
    case enemy =  0b000010
    case coin =   0b000100
    case wall =   0b001000
    
    case none = 0b00000000000000000000000000000000
}
