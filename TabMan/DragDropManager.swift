//
//  DragDropManager.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

protocol DragDropManagerDelegate {
    func tableAddedOnFloor(table: TableImageView)
    func tableMoved(table: TableImageView)
}

/// Manages drag and drop of tables
class DragDropManager: NSObject {

    /// Information about current object being dragged
    var dragContext: DragContext?

    /// The floor view where tables are arranged. In a restaurant this is the place where tables are kept and you sit on one of them and are served.
    var floor: UIView

    /// This stores the table pickers. In a restaurant this is the place where tables are stored and you are not allowed to enter.
    var tableContainer: UIView

    /// Current tables which are on the floor
    var tables: [TableImageView] = []

    /// These are the pickers which are kept in `tableContainer`
    var pickers: [TableImageView]


    /// Drag drop manager delegate
    var delegate: DragDropManagerDelegate?

    /**
     Initializes a dragDropManager
     
     - Parameters:
        - floor: The floor view
        - tableContainer: The tableContainer view
        - pickers: Pickers are the views which are storage of different shapes of tables
    */
    init(floor: UIView, tableContainer: UIView, pickers: [TableImageView]) {
        self.pickers = pickers
        self.floor = floor
        self.tableContainer = tableContainer
        super.init()
    }

    /**
     Adds the table to the floor if dragging happened from PickerContainer and is added to the floor
     
     - Parameters:
        - table: The table that is going to be added
    */
    func addTableToFloor(table: TableImageView) {
        if let context = self.dragContext {
            if context.draggedFromType == .PickerContainer {
                tables.append(table)
            }
        }
    }

    /**
     Deletes a table if the dragged table is from the floor. Deletion occurs when 
     a the dragged table is released outside the bounds of the floor.

     - Parameters:
        - table: The table that is going to be deleted
     */
    func removeTableFromFloor(table: TableImageView) {
        if let context = self.dragContext {
            // Only tables from floor can be removed
            if context.draggedFromType == .Floor {
                if let tableAtFloorIndex = tables.indexOf(table) {
                    table.removeFromSuperview()
                    tables.removeAtIndex(tableAtFloorIndex)
                }
            }
        }
    }


    /**
     Utility function which helps to move the context view according to touch.

     - Parameters:
        - sender: The UIPanGestureRecognizer
    */
    func dragTableWithGesture(sender: UIPanGestureRecognizer) {
        if let context = self.dragContext {
            let pointOnView = sender.locationInView(sender.view)
            context.draggedView.center = pointOnView
        }
    }

    /**
     Utility function which helps determine if a table is on the floor or outside the floor.

     - Parameters:
        - table: The tableview
        - position: The position of the tableview on floor
     
     - Returns: Returns `true` if the the table is on the floor else `false`
     */
    func isTableOnFloor(table: TableImageView, position: CGPoint) -> Bool {
        let viewBeingDraggedWidth = CGRectGetWidth(table.frame)
        let viewBeingDraggedHeight = CGRectGetHeight(table.frame)

        var leftCornerInDropView = position
        leftCornerInDropView.x -= viewBeingDraggedWidth / 2.0

        var rightCornerInDropView = position
        rightCornerInDropView.x += viewBeingDraggedWidth / 2.0

        var topCornerInDropView = position
        topCornerInDropView.y -= viewBeingDraggedHeight / 2.0

        var bottomCornerInDropView = position
        bottomCornerInDropView.y += viewBeingDraggedHeight / 2.0

        if floor.pointInside(leftCornerInDropView, withEvent: nil)
            && floor.pointInside(rightCornerInDropView, withEvent: nil)
            && floor.pointInside(topCornerInDropView, withEvent: nil)
            && floor.pointInside(bottomCornerInDropView, withEvent: nil)
        {
            return true
        }
        return false
    }


    /**
     Utility function which helps determine if a table intersects with another table.

     - Parameters:
     - table: The tableview

     - Returns: Returns `true` if the the table intersects with another table on floor else `false`
     */
    func isTablePositionValidOnFloor(table: TableImageView) -> Bool {

        for otherTable in tables {
            if otherTable != table {
                // Convert to table's coordinate
                let rectInMainView = table.superview!.convertRect(otherTable.frame, fromView: otherTable.superview)
                if CGRectIntersectsRect(table.frame, rectInMainView) {
                    print("Intersection happened!")
                    return false
                }
            }
        }

        return true
    }

    /**
     Called when UIPanGestureRecognizer detects a pan gesture
     
     - Parameters:
        - sender: The gesture recognizer
    */
    func dragging(sender: UIPanGestureRecognizer) {
        print("Dragging..")
        switch sender.state {
        case .Began:
            for table in tables + pickers {
                let pointInSubjectsView = sender.locationInView(table)
                let pointInsideDraggableObject = table.pointInside(pointInSubjectsView, withEvent: nil)
                let tableOn: TableOn

                if table.superview! == floor {
                    tableOn = .Floor
                } else {
                    tableOn = .PickerContainer
                }

                if pointInsideDraggableObject {
                    switch tableOn {
                    case .Floor:
                        // simple dragging
                        print("Dragging from floor!")
                        self.dragContext = DragContext(draggedView: table, draggedFromType: .Floor)
                        self.delegate?.tableMoved(table)
                        table.removeFromSuperview()
                        sender.view?.addSubview(table)
                        self.dragTableWithGesture(sender)
                    case .PickerContainer:
                        print("Dragging from picker container!")
                        // Create a new table which can be kept on the floor and drag that instead of dragging the picker
                        switch table.type {
                        case .Diamond:
                            let newTable = TableImageView(frame: table.frame, type: .Diamond)
                            self.delegate?.tableMoved(newTable)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        case .Rect:
                            let newTable = TableImageView(frame: table.frame, type: .Rect)
                            self.delegate?.tableMoved(newTable)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        case .Round:
                            let newTable = TableImageView(frame: table.frame, type: .Round)
                            self.delegate?.tableMoved(newTable)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        default:
                            let newTable = TableImageView(frame: table.frame, type: .Square)
                            self.delegate?.tableMoved(newTable)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        }
                    }
                } else {
                    print("Started drag outside tables")
                }
            }
        case .Changed:
            self.dragTableWithGesture(sender)
        case .Ended:
            if let context = self.dragContext {
                let viewBeingDragged = context.draggedView
                var droppedViewInFloor = false
                let pointInDropView = sender.locationInView(floor)
                var viewInFloorButIntersectsWithOtherTable = false

                if isTableOnFloor(viewBeingDragged, position: pointInDropView) {
                    if isTablePositionValidOnFloor(viewBeingDragged) {
                        droppedViewInFloor = true
                        viewBeingDragged.removeFromSuperview()
                        floor.addSubview(viewBeingDragged)
                        viewBeingDragged.frame = CGRect(
                            x: pointInDropView.x - (CGRectGetWidth(viewBeingDragged.frame) / 2),
                            y: pointInDropView.y - (CGRectGetHeight(viewBeingDragged.frame) / 2),
                            width: CGRectGetWidth(viewBeingDragged.frame),
                            height: CGRectGetHeight(viewBeingDragged.frame)
                        )
                        self.addTableToFloor(viewBeingDragged)
                        delegate?.tableAddedOnFloor(viewBeingDragged)
                    } else {
                        viewInFloorButIntersectsWithOtherTable = true
                    }

                }
                if !droppedViewInFloor {
                    // If moved from floor to pickerContainer, delete that table from floor
                    if context.draggedFromType == .Floor {
                        if viewInFloorButIntersectsWithOtherTable {
                            context.moveToOriginalPosition()
                        } else {
                            self.removeTableFromFloor(context.draggedView)
                        }
                    } else {
                        context.moveToOriginalPosition()
                    }
                }
                self.dragContext = nil

                print("Current items in tables: \(tables)")
            }
        default:
            print("Nothing was done!")
        }
    }

    /**
     Function to clear the tables and remove them from the floor
     */
    func refresh() {
        for tableView in self.tables {
            tableView.removeFromSuperview()
        }
        tables = []
        dragContext = nil
        
    }

}
