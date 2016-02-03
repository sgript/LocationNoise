//
//  PlacesViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 03/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import SwiftyJSON


class PlacesViewController: UIViewController {
    var delegate: PlacesViewController? = nil
    var json: JSON = []
    var chosenType: String = ""
    var arrayOfDictionary: [[String: AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In places view controller")
        
        if (json.isEmpty == false){
            print(json)
            arrayifyJSON()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func arrayifyJSON(){
        for(var i = 0; i < self.json.count; i++){
            let array = Array(arrayLiteral: self.json[i]["types"].arrayValue)[0]
            if(array.contains(JSON(chosenType)) && chosenType.characters.count > 0){ // Perhaps look at splitting for better, more meaningful else statements!
                //self.retrievedPlaces.append(String(self.json[i]["place_id"]))
                arrayOfDictionary.append(["id": "\(json[i]["place_id"])", "name": "\(json[i]["name"])"])
            }
        }
        
        print(String(arrayOfDictionary))
    }

}


extension PlacesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // May change to multiple if searching for multiple types of location - e.g. Restaurant, Bar, Places of Interest etc..
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Places near you"
    }
    
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
