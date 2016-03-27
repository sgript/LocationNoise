//
//  ManageSensitiveLocations.swift
//  LocationPrivacy
//
//  Created by sgript on 15/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import RealmSwift

class ManageSensitiveLocations: UITableViewController {
    var sensitiveLocationName = [String]()
    var userSensitiveLocations = [[String: AnyObject]]()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        displaySensitiveLocations()
        //self.tableView.reloadData()
    }
    
    @IBAction func removeButtonClicked(sender: AnyObject) {
        
        let toBeDeleted = userSensitiveLocations[sender.tag]
        let deleteById = toBeDeleted["place_id"]! as! String
        
        //let sensitiveLocations = realm.objects(SensitiveLocations)
        let realmObjectToDelete = realm.objectForPrimaryKey(SensitiveLocations.self, key: "\(deleteById)")
        userSensitiveLocations.removeAtIndex(sender.tag)
        
        realm.beginWrite()
        realm.delete(realmObjectToDelete!)
        try! realm.commitWrite()
        
        self.tableView.reloadData()
        
    }
    
    func displaySensitiveLocations() {
        let realm = try! Realm()
        
        let sensitiveLocations = realm.objects(SensitiveLocations)
        
        for location in sensitiveLocations {
            self.sensitiveLocationName.append(location["formatted_address"] as! String)
            self.userSensitiveLocations.append(["place_id" : "\(location["id"]!)", "formatted_address" : "\(location["formatted_address"]!)"])
        }
        
        print(userSensitiveLocations)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSensitiveLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ManageLocationsCell") as! ManageLocationsCell
        
        var item = userSensitiveLocations[indexPath.row]
        let formatted_address = item["formatted_address"] as! String
        let split_address = formatted_address.characters.split{$0 == ","}.map(String.init)

        
        cell.sensitiveLocationText!.text = "\(split_address[0]),\(split_address[1])."
        
        cell.removeButton.tag = indexPath.row // Instead of sending indexPath row, send it the place_id!
        cell.removeButton.addTarget(self, action: "removeButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
}
