//
//  DragContext.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

/// Stores information about the current view being dragged
class DragContext {

    /// The view being dragged
    var draggedView: TableImageView

    /// The superview of the view being dragged
    var draggedFrom: UIView

    /// The position of the view when it started getting dragged
    var dragOriginalPosition: CGPoint

    /// The superview type
    var draggedFromType: TableOn

    /**
     Initializer for the class variables
     
     - Parameters:
        - draggedView: The view being dragged
        - draggedFromType: The type of the superview of the draggedView
    */
    init(draggedView: TableImageView, draggedFromType: TableOn) {
        self.draggedView = draggedView
        self.draggedFrom = draggedView.superview!
        self.dragOriginalPosition = draggedView.frame.origin
        self.draggedFromType = draggedFromType
    }

    /**
     Function takes the draggedView back to its original position from where it was dagged.
    */
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
