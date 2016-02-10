//
//  File.swift
//  LocationPrivacy
//
//  Created by sgript on 04/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import Foundation

extension SequenceType {
    var minimalDescrption: String {
        return map { String($0) }.joinWithSeparator(", ")
    }
}