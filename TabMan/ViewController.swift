//
//  ViewController.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 10/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    /// View components
    @IBOutlet weak var saveFloorsTableView: UITableView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var floorView: UIView!

    /// Pickers
    @IBOutlet weak var diamondPicker: TableImageView!
    @IBOutlet weak var rectPicker: TableImageView!
    @IBOutlet weak var roundPicker: TableImageView!
    @IBOutlet weak var squarePicker: TableImageView!

    /// Butoons
    @IBOutlet weak var saveFloorButton: UIButton!
    @IBOutlet weak var showTablesButton: UIButton!
    @IBOutlet weak var savedFloorsButton: UIButton!

    /// dragDrop manager instance
    var dragDropManager: DragDropManager!

    /// Get all floors which have been saved
    var allSavedFloors = getAllSavedFloors()

    var groupManager: GroupManager!


    /// If a floor is currently getting edited, this variable stores it's id
    var currentFloorEditingId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Give type to the pickers
        self.diamondPicker.type = .Diamond
        self.diamondPicker.onFloor = false
        self.rectPicker.type = .Rect
        self.rectPicker.onFloor = false
        self.roundPicker.type = .Round
        self.roundPicker.onFloor = false
        self.squarePicker.type = .Square
        self.squarePicker.onFloor = false

        // Setup the dragDropManager
        dragDropManager = DragDropManager(floor: floorView, tableContainer: tableContainerView, pickers: [
            diamondPicker,
            rectPicker,
            roundPicker,
            squarePicker
            ])

        // Setup gestures
        let dragGesture = UIPanGestureRecognizer(target: dragDropManager, action: Selector("dragging:"))
        self.view.addGestureRecognizer(dragGesture)

        // Create the saved floors tableView
        saveFloorsTableView.hidden = true
        saveFloorsTableView.delegate = self
        saveFloorsTableView.dataSource = self

        groupManager = GroupManager(delegate: dragDropManager, controller: self)
        dragDropManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveFloorButtonPressed(sender: AnyObject) {
        // CHeck if tables with same id exist. If yes do not save and show an alert.
        for tableView1 in dragDropManager.tables {
            for tableView2 in dragDropManager.tables {
                if tableView1 != tableView2 {
                    if tableView1.id != nil && tableView2.id != nil && tableView1.id == tableView2.id {
                        let alert = UIAlertController(title: "Error", message: "Two tables have same ids. Please check.", preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(ok)
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                }
            }
        }

        /// If no tables are on the floor, do not let them save the floor.
        if self.dragDropManager.tables.count < 1 {
            let alert = UIAlertController(title: "Error", message: "At least one table to the floor.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        /// Save or update the current floor or new floor.
        let currentFloor = Floor()
        currentFloor.id = currentFloorEditingId ?? getFloorId(currentFloor)
        for tableView in dragDropManager.tables {
            let table = Table()
            table.locationOnFloorX = Double(tableView.frame.origin.x)
            table.locationOnFloorY = Double(tableView.frame.origin.y)
            table.height = Double(CGRectGetHeight(tableView.frame))
            table.width = Double(CGRectGetWidth(tableView.frame))
            table.type = tableView.type.rawValue
            table.number.value = tableView.id
            currentFloor.tables.append(table)
        }
        if currentFloorEditingId == nil {
            saveFloor(currentFloor)
        } else {
            saveFloor(currentFloor, update: true)
        }
        self.getRecentFloors()
        saveFloorsTableView.reloadData()

        /// Show alert that everything is saved and then clear the floor
        let alert = UIAlertController(title: "Floor Saved", message: "Floor saved and can be accessed from floors.",preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.dragDropManager.refresh()
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func showTableSelector() {
        saveFloorsTableView.hidden = true
        tableContainerView.hidden = false
    }

    func showSavedFloorTable() {
        self.saveFloorsTableView.hidden = false
        self.tableContainerView.hidden = true
    }

    @IBAction func showTablesButtonPressed(sender: AnyObject) {
        currentFloorEditingId = nil
        showTableSelector()
        self.dragDropManager.refresh()
    }

    func arrangeViewsAndButtonsToShowSavedFloorInterface() {
        showSavedFloorTable()
        dragDropManager.refresh()
    }

    func deleteUnsavedChangedAndMoveToSavedFloors() {
        let alert = UIAlertController(title: "Warning!", message: "Your unsaved changes will be deleted. Continue?", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Destructive) { (action) -> Void in
            self.arrangeViewsAndButtonsToShowSavedFloorInterface()
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func savedFloorsButtonPressed(sender: AnyObject) {
        // TODO: Ask user if he really wants to delete everything and move to floor selector
        if dragDropManager.tables.count > 0 && currentFloorEditingId == nil {
            deleteUnsavedChangedAndMoveToSavedFloors()
        } else {
            arrangeViewsAndButtonsToShowSavedFloorInterface()
        }

    }

    func getRecentFloors() {
        allSavedFloors = getAllSavedFloors()
    }

}


extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSavedFloors.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("floor", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Floor #: " + String(allSavedFloors[indexPath.row].id)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dragDropManager.refresh()
        let floorSelected = allSavedFloors[indexPath.row]
        currentFloorEditingId = floorSelected.id
        for table in floorSelected.tables {
            let frameOnFloor = CGRect(origin: CGPoint(x: table.locationOnFloorX, y: table.locationOnFloorY), size: CGSize(width: table.width, height: table.height))
            let type = TableType(rawValue: table.type)!
            let id: Int? = table.number.value
            var newTable: TableImageView
            switch type {
            case .Diamond:
                newTable = TableImageView(frame: frameOnFloor, type: .Diamond)
            case .Round:
                newTable = TableImageView(frame: frameOnFloor, type: .Round)
            case .Rect:
                newTable = TableImageView(frame: frameOnFloor, type: .Rect)
            case .Square:
                newTable = TableImageView(frame: frameOnFloor, type: .Square)
            }
            newTable.id = id
            floorView.addSubview(newTable)
            dragDropManager.tables.append(newTable)
        }
        showTableSelector()
    }
    
}


extension ViewController: DragDropManagerDelegate {

    func tableMoved(table: TableImageView) {
        for table in dragDropManager.tables {
            table.tapped = false
        }
        groupManager.removePath()
    }

    func tableAddedOnFloor(table: TableImageView) {
        let gesture = UITapGestureRecognizer(target: groupManager, action: Selector("tapped:"))
        table.addGestureRecognizer(gesture)
    }

}
