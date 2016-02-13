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
    
    @IBOutlet weak var diamondPicker: DiamondTableImageView!
    @IBOutlet weak var rectPicker: RectTableImageView!
    @IBOutlet weak var roundPicker: RoundTableImageView!
    @IBOutlet weak var squarePicker: SquareTableImageView!


    @IBOutlet weak var saveFloorButton: UIButton!
    @IBOutlet weak var showTablesButton: UIButton!
    @IBOutlet weak var savedFloorsButton: UIButton!

    var dragDropManager: DragDropManager!
    var allSavedFloors = getAllSavedFloors()

    var savedTablesViewingArray: [TableImageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

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
        let currentFloor = Floor()
        currentFloor.id = getFloorId(currentFloor)
        for tableView in dragDropManager.tables {
            let table = Table()
            table.locationOnFloorX = Double(tableView.center.x)
            table.locationOnFloorY = Double(tableView.center.y)
            table.height = Double(CGRectGetHeight(tableView.frame))
            table.width = Double(CGRectGetWidth(tableView.frame))
            table.type = tableView.type!.rawValue
            table.number = 0
            currentFloor.tables.append(table)
        }
        saveFloor(currentFloor)
        self.getRecentFloors()
        saveFloorsTableView.reloadData()

        let alert = UIAlertController(title: "Floor Saved", message: "Floor saved and can be accessed from floors.", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            self.dragDropManager.refresh()
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func showTablesButtonPressed(sender: AnyObject) {
        saveFloorsTableView.hidden = true
        tableContainerView.hidden = false
        floorView.userInteractionEnabled = true
        removeTablesAddedToFloorForViewingSavedFloor()
        saveFloorButton.enabled = true
    }

    func arrangeViewsAndButtonsToShowSavedFloorInterface() {
        self.saveFloorsTableView.hidden = false
        self.tableContainerView.hidden = true
        self.saveFloorButton.enabled = false
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

    func removeTablesAddedToFloorForViewingSavedFloor() {
        for savedTable in savedTablesViewingArray {
            savedTable.removeFromSuperview()
        }
        savedTablesViewingArray = []
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
        removeTablesAddedToFloorForViewingSavedFloor()
        let floorSelected = allSavedFloors[indexPath.row]
        for table in floorSelected.tables {
            let frameOnFloor = CGRect(origin: CGPoint(x: table.locationOnFloorX, y: table.locationOnFloorY), size: CGSize(width: table.width, height: table.height))
            let type = TableType(rawValue: table.type)!

            var newTable: TableImageView
            switch type {
            case .Diamond:
                newTable = DiamondTableImageView(frame: frameOnFloor)
            case .Round:
                newTable = RoundTableImageView(frame: frameOnFloor)
            case .Rect:
                newTable = RectTableImageView(frame: frameOnFloor)
            case .Square:
                newTable = SquareTableImageView(frame: frameOnFloor)
            }
            floorView.addSubview(newTable)
            savedTablesViewingArray.append(newTable)
        }
        floorView.userInteractionEnabled = false
    }
    
}
