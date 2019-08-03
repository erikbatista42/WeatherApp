//
//  Item.swift
//  WeatherApp
//
//  Created by luxury on 8/2/19.
//  Copyright © 2019 luxury. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var itemId: String = UUID().uuidString
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var body: String = ""
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
    
}

class WeatherData: Object {
    @objc dynamic var zipcode: String = ""
    @objc dynamic var cityName: String = ""
}
