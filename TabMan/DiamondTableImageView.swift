//
//  DiamondTableImageView.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class DiamondTableImageView: TableImageView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        type = TableType.Diamond
        image = UIImage(named: TableType.Diamond.imageName)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        type = TableType.Diamond
        image = UIImage(named: TableType.Diamond.imageName)
        userInteractionEnabled = true
    }
    
}
