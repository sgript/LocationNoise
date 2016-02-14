//
//  SensitiveLocations.swift
//  LocationPrivacy
//
//  Created by sgript on 13/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import Foundation
import RealmSwift

class SensitiveLocations: Object {
    dynamic var id = ""
    dynamic var formatted_address = ""
    dynamic var latitude:Double = 0.0
    dynamic var longitude:Double = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}