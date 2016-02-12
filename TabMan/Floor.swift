//
//  Floor.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import Foundation
import RealmSwift

class Floor: Object {

    var tables = List<Table>()
    var size: CGSize?

    func canTableBeKeptOnFloorLocation(table: Table, location: CGPoint) -> Bool {
        return true
    }
}

// Helper functions

func getAllSavedFloors() -> Results<Floor> {
    let realm = try! Realm()
    let allFloors = realm.objects(Floor)
    return allFloors
}

func saveFloor(floor: Floor) {
    let realm = try! Realm()
    try! realm.write {
        realm.add(floor)
    }
}