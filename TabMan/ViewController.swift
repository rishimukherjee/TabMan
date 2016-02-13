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

    var savedTableSource: SavedTablesDataSource!

    var dragDropManager: DragDropManager!


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
        savedTableSource = SavedTablesDataSource()
        saveFloorsTableView.hidden = true
        saveFloorsTableView.delegate = savedTableSource
        saveFloorsTableView.dataSource = savedTableSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveFloorButtonPressed(sender: AnyObject) {
        // Get all the current tables in the floor and persist it
        let currentFloor = Floor()
        currentFloor.id = getFloorId(currentFloor)
        let tablesOnFloor = List<Table>()
        for tableView in dragDropManager.tables {
            let table = Table()
            table.locationOnFloor = tableView.center
            table.type = tableView.type
            table.number = 0
            tablesOnFloor.append(table)
        }
        saveFloor(currentFloor)
        savedTableSource.getRecentFloors()
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
    }

    @IBAction func savedFloorsButtonPressed(sender: AnyObject) {
        saveFloorsTableView.hidden = false
        tableContainerView.hidden = true
    }

}
