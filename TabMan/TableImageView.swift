//
//  TableImageView.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

enum TableOn: Int {
    case Floor = 0
    case PickerContainer = 1
}

class TableImageView: UIImageView {

    var type: TableType?

}