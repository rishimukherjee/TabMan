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

    private var _type: TableType!

    var type: TableType {
        set {
            self.image = UIImage(named: newValue.imageName)
            _type = newValue
        }
        get {
            return self._type
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
    }

    convenience init(frame: CGRect, type: TableType) {
        self.init(frame: frame)
        self.type = type
    }

}