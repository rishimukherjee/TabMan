//
//  SavedTablesDataSource.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 13/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

class SavedTablesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var allSavedFloors = getAllSavedFloors()

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSavedFloors.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("floor", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Floor #: " + String(allSavedFloors[indexPath.row]["id"]!)
        return cell
    }

    func getRecentFloors() {
        allSavedFloors = getAllSavedFloors()
    }

}
