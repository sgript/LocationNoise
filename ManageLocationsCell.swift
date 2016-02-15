//
//  ManageLocationsCell.swift
//  LocationPrivacy
//
//  Created by sgript on 15/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit

public protocol ManageLocationsCellDelegate: class {
    func removeSensitiveLocation(manageLocationsCell: ManageLocationsCell)
}

public class ManageLocationsCell: UITableViewCell {
    
    public weak var delegate: ManageLocationsCellDelegate?
    @IBOutlet weak var sensitiveLocationText: UILabel!
    @IBOutlet weak var removeButton: UIButton!

    @IBAction func removeButtonPressed(sender: AnyObject) {
        print("buttonIsClicked")
        delegate?.removeSensitiveLocation(self)
    
    }
    
}