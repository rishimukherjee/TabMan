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
    var type: TableType?
    var locationOnFloor: CGPoint?
}