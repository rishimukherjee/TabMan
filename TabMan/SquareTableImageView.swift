//
//  SquareTableImageView.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class SquareTableImageView: TableImageView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        type = TableType.Square
        image = UIImage(named: TableType.Square.imageName)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        type = TableType.Square
        image = UIImage(named: TableType.Square.imageName)
        userInteractionEnabled = true
    }
    
}