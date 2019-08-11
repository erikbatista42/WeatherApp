//
//  ItemLog.swift
//  WeatherApp
//
//  Created by luxury on 8/10/19.
//  Copyright © 2019 luxury. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class LogsInventory: Object {
    @objc dynamic var name: String = "logBook"
    let logList = List<WeatherLogItem>()
}

class WeatherLogItem: Object {
    @objc dynamic var itemId: String = UUID().uuidString
    @objc dynamic var userLog: String = ""
    @objc dynamic var timestamp: Date = Date()
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
}
