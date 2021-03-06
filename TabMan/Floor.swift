//
//  Floor.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import Foundation
import RealmSwift

/// Floor model
class Floor: Object {
    let tables = List<Table>()
    dynamic var id = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

// Helper functions

/// Get all saved floors
func getAllSavedFloors() -> Results<Floor> {
    let realm = try! Realm()
    let allFloors = realm.objects(Floor)
    return allFloors
}

/// Get floor id of given floor
func getFloorId(floor: Floor) -> Int {
    let allFloors = getAllSavedFloors()
    for savedFloor in allFloors {
        if savedFloor == floor {
            return floor.id
        }
    }
    return allFloors.count + 1
}

/// Save a floor. Update if saved floor.
func saveFloor(floor: Floor, update: Bool = false) {
    let realm = try! Realm()
    try! realm.write {
        realm.add(floor, update: update)
    }
}