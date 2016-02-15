//
//  Table.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import Foundation
import RealmSwift

enum TableType: Int {

    case Round = 0
    case Square = 1
    case Diamond = 2
    case Rect = 3

    var imageName: String {
        switch self {
        case .Round: return "Round"
        case .Rect: return "Rect"
        case .Diamond: return "Diamond"
        case .Square: return "Square"
        }
    }
}

class Table: Object {
    dynamic var type = 0
    dynamic var locationOnFloorX = 0.0
    dynamic var locationOnFloorY = 0.0
    dynamic var height = 0.0
    dynamic var width = 0.0
    let number = RealmOptional<Int>()
}