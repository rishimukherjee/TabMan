//
//  GroupManager.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 28/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

/// Class helps manage table groups
class GroupManager: NSObject {

    // drag drop manager
    var delegate: DragDropManager

    // Shapelayer for drawing the bezeirpath
    var shapeLayer: CAShapeLayer!

    // view controller which uses it
    var controller: UIViewController

    init(delegate: DragDropManager, controller: UIViewController) {
        self.delegate = delegate
        self.controller = controller
    }

    // Creates the border for the group
    func boxPath() {

        // Get the selected tables
        let tables = delegate.tables.filter({
            $0.tapped
        })

        // Add all merged rectangles
        let outlinePath = enclosingPathForViews(tables)

        // Remove layer if already added
        shapeLayer?.removeFromSuperlayer()

        // Configure the outline
        let outlineColor = UIColor.redColor()
        let outlineWidth: CGFloat = 1.0
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = delegate.floor.bounds
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = outlineColor.CGColor
        shapeLayer.lineWidth = outlineWidth
        shapeLayer.path = outlinePath.CGPath

        // Get all tables that are not tapped
        let tablesNotSelected = delegate.tables.filter({
            !$0.tapped
        })

        // Check if group is legal, ie, no disSelected table inside the polygon
        var illigalBoundary = false
        for tableNotSelected in tablesNotSelected {
            let leftTopCornerPoint = CGPoint(x: CGRectGetMinX(tableNotSelected.frame), y: CGRectGetMinY(tableNotSelected.frame))
            if outlinePath.containsPoint(leftTopCornerPoint) {
                illigalBoundary = true
            }
            let leftBottomCornerPoint = CGPoint(x: CGRectGetMinX(tableNotSelected.frame), y: CGRectGetMaxY(tableNotSelected.frame))
            if outlinePath.containsPoint(leftBottomCornerPoint) {
                illigalBoundary = true
            }
            let rightTopCornerPoint = CGPoint(x: CGRectGetMaxX(tableNotSelected.frame), y: CGRectGetMinY(tableNotSelected.frame))
            if outlinePath.containsPoint(rightTopCornerPoint) {
                illigalBoundary = true
            }
            let rightBottomCornerPoint = CGPoint(x: CGRectGetMaxX(tableNotSelected.frame), y: CGRectGetMaxY(tableNotSelected.frame))
            if outlinePath.containsPoint(rightBottomCornerPoint) {
                illigalBoundary = true
            }
        }

        if !illigalBoundary {
            delegate.floor.layer.insertSublayer(shapeLayer, atIndex: 0)
        } else {
            let alert = UIAlertController(title: "Error", message: "Illigal group. Please check.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(ok)
            controller.presentViewController(alert, animated: true, completion: nil)
        }
    }

    /**
     Draw a hull hugging the exteriar the selected views to make a group

     - Parameters:
     - views: The views selected
     - marging: How far the margin is from th views
    */
    func enclosingPathForViews(views:[UIView], margin:CGFloat = 3) -> UIBezierPath
    {
        let frames = views.map({
            $0.frame.insetBy(dx: -margin, dy: -margin)
        })

        if frames.count == 0 {
            return UIBezierPath()
        }

        let path = UIBezierPath()

        // top left and right corners of each view
        // sorted from left to right, top to bottom
        var topPoints:[CGPoint] = frames.reduce(  Array<CGPoint>(),
            combine: { $0 + [ CGPoint(x:$1.minX,y:$1.minY),
                CGPoint(x:$1.maxX,y:$1.minY) ] })
        topPoints = topPoints.sort({ $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x })
        // trace top line from left to right
        // moving up or down when appropriate
        var previousPoint = topPoints.first!
        path.moveToPoint(previousPoint)
        for point in topPoints
        {
            guard point.y == previousPoint.y
                || point.y < previousPoint.y
                && frames.contains({$0.minX == point.x && $0.minY < previousPoint.y })
                || point.y > previousPoint.y
                && !frames.contains({ $0.maxX > point.x && $0.minY < point.y })
                else  { continue }

            if point.y < previousPoint.y
            { path.addLineToPoint(CGPoint(x:point.x, y:previousPoint.y)) }
            if point.y > previousPoint.y
            { path.addLineToPoint(CGPoint(x:previousPoint.x, y:point.y)) }
            path.addLineToPoint(point)
            previousPoint = point
        }

        // right top and bottom corners of each view
        // sorted from top to bottom, left to right
        var rightPoints:[CGPoint] = frames.reduce(Array<CGPoint>(), combine: { $0 + [ CGPoint(x:$1.maxX,y:$1.minY),
            CGPoint(x:$1.maxX,y:$1.maxY) ] })
        rightPoints = rightPoints.sort({ $0.y == $1.y ? $0.x > $1.x : $0.y < $1.y })
        for point in rightPoints {
            guard point.x == previousPoint.x
                || point.x > previousPoint.x
                && frames.contains({ $0.minY == point.y && $0.maxX > previousPoint.x })
                || point.x < previousPoint.x
                && !frames.contains({ $0.maxY > point.y && $0.maxX > point.x })
                else { continue }
            if point.x < previousPoint.x
            { path.addLineToPoint(CGPoint(x:point.x, y:previousPoint.y)) }
            if point.x > previousPoint.x
            { path.addLineToPoint(CGPoint(x:previousPoint.x, y:point.y)) }
            path.addLineToPoint(point)
            previousPoint = point
        }

        // botom left and right corners of each view
        // sorted from right to left, bottom to top
        var bottomPoints:[CGPoint] = frames.reduce(  Array<CGPoint>(),
            combine: { $0 + [ CGPoint(x:$1.minX,y:$1.maxY),
                CGPoint(x:$1.maxX,y:$1.maxY) ] })
        bottomPoints = bottomPoints.sort({ $0.x == $1.x ? $0.y > $1.y : $0.x > $1.x })

        // trace bottom line from right to left
        // starting where top line left off (rightmost top corner)
        // moving up or down when appropriate
        for point in bottomPoints
        {
            guard point.y == previousPoint.y
                || point.y > previousPoint.y
                && frames.contains({ $0.maxX == point.x && $0.maxY > previousPoint.y })
                || point.y < previousPoint.y
                && !frames.contains({ $0.minX < point.x && $0.maxY > point.y })
                else  { continue }

            if point.y > previousPoint.y
            { path.addLineToPoint(CGPoint(x:point.x, y:previousPoint.y)) }
            if point.y < previousPoint.y
            { path.addLineToPoint(CGPoint(x:previousPoint.x, y:point.y)) }
            path.addLineToPoint(point)
            previousPoint = point
        }

        // left bottom and top corners of each view
        // sorted from bottom to top, left to right
        var leftPoints:[CGPoint] = frames.reduce(  Array<CGPoint>(),
            combine: { $0 + [ CGPoint(x:$1.minX,y:$1.minY),
                CGPoint(x:$1.minX,y:$1.maxY) ] })
        leftPoints = leftPoints.sort({ $0.y == $1.y ? $0.x < $1.x : $0.y > $1.y })


        // trace left line from bottom to top
        // starting from where bottom line left off
        // moving left or right when appropriate
        for point in leftPoints {
            guard point.x == previousPoint.x
                || point.x < previousPoint.x
                && frames.contains({ $0.maxY == point.y && $0.minY < previousPoint.y })
                || point.x > previousPoint.y
                && !frames.contains({ $0.minX < point.x && $0.minY < point.y })
                else  { continue }
            if point.x > previousPoint.x
            { path.addLineToPoint(CGPoint(x:point.x, y:previousPoint.y)) }
            if point.x < previousPoint.x
            { path.addLineToPoint(CGPoint(x:previousPoint.x, y:point.y)) }
            path.addLineToPoint(point)
            previousPoint = point
        }

        return path
    }

    func tapped(sender: UITapGestureRecognizer) {
        let tappedTable = sender.view as! TableImageView
        tappedTable.tapped = !tappedTable.tapped
        boxPath()
    }

    func removePath() {
        shapeLayer?.removeFromSuperlayer()
    }

}