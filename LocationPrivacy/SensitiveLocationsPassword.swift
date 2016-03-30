//
//  SensitiveLocationsPassword.swift
//  LocationPrivacy
//
//  Created by sgript on 30/03/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import Foundation
import RealmSwift

class SensitiveLocationsPassword: Object {
    dynamic var password = ""
    dynamic var numberOfAttempts: Int = 0
    dynamic var dataDestroyed: Bool = false

}