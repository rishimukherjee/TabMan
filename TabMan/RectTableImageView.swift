//
//  RectTableImageView.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class RectTableImageView: TableImageView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        type = TableType.Rect
        image = UIImage(named: TableType.Rect.imageName)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        type = TableType.Rect
        image = UIImage(named: TableType.Rect.imageName)
        userInteractionEnabled = true
    }
    
}
