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
    var id = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}

// Helper functions

func getAllSavedFloors() -> Results<Floor> {
    let realm = try! Realm()
    let allFloors = realm.objects(Floor)
    return allFloors
}

func getFloorId(floor: Floor) -> Int {
    let allFloors = getAllSavedFloors()
    for savedFloor in allFloors {
        if savedFloor == floor {
            return floor.id
        }
    }
    return allFloors.count + 1
}

func saveFloor(floor: Floor) {
    let realm = try! Realm()
    try! realm.write {
        realm.add(floor)
    }
}