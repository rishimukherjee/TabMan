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

    @IBOutlet weak var saveFloorsTableView: UITableView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var floorView: UIView!
    
    @IBOutlet weak var diamondPicker: TableImageView!
    @IBOutlet weak var rectPicker: TableImageView!
    @IBOutlet weak var roundPicker: TableImageView!
    @IBOutlet weak var squarePicker: TableImageView!


    @IBOutlet weak var saveFloorButton: UIButton!
    @IBOutlet weak var showTablesButton: UIButton!
    @IBOutlet weak var savedFloorsButton: UIButton!

    var dragDropManager: DragDropManager!
    var allSavedFloors = getAllSavedFloors()


    var currentFloorEditingId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Give type to the pickers
        self.diamondPicker.type = .Diamond
        self.rectPicker.type = .Rect
        self.roundPicker.type = .Round
        self.squarePicker.type = .Square

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveFloorButtonPressed(sender: AnyObject) {
        // Get all the current tables in the floor and persist it
        if self.dragDropManager.tables.count < 1 {
            let alert = UIAlertController(title: "Error", message: "At at least one table to the floor.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let currentFloor = Floor()
        currentFloor.id = currentFloorEditingId ?? getFloorId(currentFloor)
        for tableView in dragDropManager.tables {
            let table = Table()
            table.locationOnFloorX = Double(tableView.frame.origin.x)
            table.locationOnFloorY = Double(tableView.frame.origin.y)
            table.height = Double(CGRectGetHeight(tableView.frame))
            table.width = Double(CGRectGetWidth(tableView.frame))
            table.type = tableView.type.rawValue
            table.number = 0
            currentFloor.tables.append(table)
        }
        if currentFloorEditingId == nil {
            saveFloor(currentFloor)
        } else {
            saveFloor(currentFloor, update: true)
        }
        self.getRecentFloors()
        saveFloorsTableView.reloadData()

        if currentFloorEditingId == nil {
            let alert = UIAlertController(title: "Floor Saved", message: "Floor saved and can be accessed from floors.", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
                self.dragDropManager.refresh()
            }
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func showTablesButtonPressed(sender: AnyObject) {
        currentFloorEditingId = nil
        saveFloorsTableView.hidden = true
        tableContainerView.hidden = false
        self.dragDropManager.refresh()
    }

    func arrangeViewsAndButtonsToShowSavedFloorInterface() {
        self.saveFloorsTableView.hidden = false
        self.tableContainerView.hidden = true
        self.dragDropManager.refresh()
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
        if dragDropManager.tables.count > 0 {
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

            var newTable: TableImageView
            switch type {
            case .Diamond:
                newTable = TableImageView(frame: frameOnFloor, type: .Diamond)
            case .Round:
                newTable = TableImageView(frame: frameOnFloor, type: .Rect)
            case .Rect:
                newTable = TableImageView(frame: frameOnFloor, type: .Rect)
            case .Square:
                newTable = TableImageView(frame: frameOnFloor, type: .Square)
            }
            floorView.addSubview(newTable)
            dragDropManager.tables.append(newTable)
        }
    }
    
}
