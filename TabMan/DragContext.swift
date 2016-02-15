//
//  DragContext.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class DragContext {
    var draggedView: TableImageView
    var draggedFrom: UIView
    var dragOriginalPosition: CGPoint
    var draggedFromType: TableOn

    init(draggedView: TableImageView, draggedFromType: TableOn) {
        self.draggedView = draggedView
        self.draggedFrom = draggedView.superview!
        self.dragOriginalPosition = draggedView.frame.origin
        self.draggedFromType = draggedFromType
    }

    func moveToOriginalPosition() {
        UIView.animateWithDuration(0.3, animations: {
            let originalPointInSuperView = self.draggedView.superview!.convertPoint(self.dragOriginalPosition, fromView: self.draggedFrom)
            self.draggedView.frame = CGRect(
                x: originalPointInSuperView.x,
                y: originalPointInSuperView.y,
                width: CGRectGetWidth(self.draggedView.frame),
                height: CGRectGetHeight(self.draggedView.frame
                )
            )
            }, completion: {
                finished in
                self.draggedView.frame = CGRect(
                    x: self.dragOriginalPosition.x,
                    y: self.dragOriginalPosition.y,
                    width: CGRectGetWidth(self.draggedView.frame),
                    height: CGRectGetHeight(self.draggedView.frame)
                )
                self.draggedView.removeFromSuperview()
                if self.draggedFromType == .Floor {
                    self.draggedFrom.addSubview(self.draggedView)
                }
        })
    }
}
