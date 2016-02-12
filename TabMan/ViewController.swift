//
//  ViewController.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 10/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func saveFloorButtonPressed(sender: AnyObject) {

    }

    @IBAction func showTablesButtonPressed(sender: AnyObject) {
    }

    @IBAction func savedFloorsButtonPressed(sender: AnyObject) {
    }

}

