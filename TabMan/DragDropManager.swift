//
//  DragDropManager.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class DragDropManager: NSObject {

    var dragContext: DragContext?
    var floor: UIView
    var tableContainer: UIView
    var tables: [TableImageView] = []
    var pickers: [TableImageView]

    init(floor: UIView, tableContainer: UIView, pickers: [TableImageView]) {
        self.pickers = pickers
        self.floor = floor
        self.tableContainer = tableContainer
    }

    func addTableToFloor(table: TableImageView) {
        if let context = self.dragContext {
            if context.draggedFromType == .PickerContainer {
                tables.append(table)
            }
        }
    }

    func removeTableFromFloor(table: TableImageView) {
        if let context = self.dragContext {
            if context.draggedFromType == .Floor {
                if let tableAtFloorIndex = tables.indexOf(table) {
                    table.removeFromSuperview()
                    tables.removeAtIndex(tableAtFloorIndex)
                }
            }
        }
    }

    func dragTableWithGesture(sender: UIPanGestureRecognizer) {
        if let context = self.dragContext {
            let pointOnView = sender.locationInView(sender.view)
            context.draggedView.center = pointOnView
        }
    }

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
                        table.removeFromSuperview()
                        sender.view?.addSubview(table)
                        self.dragTableWithGesture(sender)
                    case .PickerContainer:
                        print("Dragging from picket container!")
                        // Create a new table which can be kept on the floor and drag that instead of dragging the picker
                        guard let draggedTableType = table.type else {
                            return
                        }
                        switch draggedTableType {
                        case .Diamond:
                            let newTable = DiamondTableImageView(frame: table.frame)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        case .Rect:
                            let newTable = RectTableImageView(frame: table.frame)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        case .Round:
                            let newTable = RoundTableImageView(frame: table.frame)
                            tableContainer.addSubview(newTable)
                            self.dragContext = DragContext(draggedView: newTable, draggedFromType: .PickerContainer)
                            sender.view?.addSubview(newTable)
                            self.dragTableWithGesture(sender)
                        default:
                            let newTable = SquareTableImageView(frame: table.frame)
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

                if floor.pointInside(pointInDropView, withEvent: nil) {
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
                }
                if !droppedViewInFloor {
                    // If moved from floor to pickerContainer, delete that table from floor
                    if context.draggedFromType == .Floor {
                        self.removeTableFromFloor(context.draggedView)
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

}
