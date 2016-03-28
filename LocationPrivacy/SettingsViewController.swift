//
//  SearchTableViewController.swift
//  UISearchController Xcode 7
//
//  Created by PJ Vea on 6/27/15.
//  Copyright © 2015 Vea Software. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class SettingsViewController: UITableViewController, UISearchResultsUpdating {
    var resultSearchController: UISearchController?
    var arrayObj =  [String]()
    var array: [[String : AnyObject]] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.definesPresentationContext = true

        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController!.searchResultsUpdater = self
        self.resultSearchController!.dimsBackgroundDuringPresentation = false
        self.resultSearchController!.searchBar.sizeToFit()
        self.resultSearchController!.searchBar.placeholder = "Search for locations to add as sensitive"
        self.resultSearchController!.searchBar.barTintColor = UIColor.appleRed()
        
        self.tableView.tableHeaderView = self.resultSearchController!.searchBar
        
        (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
        self.tableView.separatorStyle = .None
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.separatorStyle = .None
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.resultSearchController!.removeFromParentViewController()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.resultSearchController!.active){
            return self.arrayObj.count
        }
        else{
            // Do nothing
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if (self.resultSearchController!.active){
            cell!.textLabel?.text = self.arrayObj[indexPath.row]
            
            return cell!
        }
        else{
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        var item = self.array[indexPath.row]
        let place_id = item["place_id"]!
        let address = item["formatted_address"]!
        let lat = item["lat"]! as! Double
        let long = item["long"]! as! Double
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Choose distance", message: "Enter minimum metres of noise to have from this location. Default: 100", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "100"
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            textField.placeholder = "Minimum metres of noise to add."
            print("Text field: \(textField.text)")
            
            let sensitive = SensitiveLocations()
            
            sensitive.id = place_id as! String
            sensitive.formatted_address = address as! String
            sensitive.latitude = lat
            sensitive.longitude = long
            
            if(textField.text != nil){
                sensitive.minimumMetres = Double(textField.text!)!
            }
            else {
                sensitive.minimumMetres = 100
            }
            
            let realm = try! Realm()
            
            var alert: UIAlertController?
            let exists = realm.objectForPrimaryKey(SensitiveLocations.self, key: place_id)
            if (exists == nil) {
                print("Written sensitive location.")
                try! realm.write {
                    realm.add(sensitive)
                    print("\(sensitive)")
                    alert = UIAlertController(title: "Saved", message: "Location is now protected.", preferredStyle: UIAlertControllerStyle.Alert)
                }
            }
            else {
                print("This already exists!") // Throw some popup notification
                alert = UIAlertController(title: "Error", message: "Location already protected!", preferredStyle: UIAlertControllerStyle.Alert)

                
            }
            alert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert!, animated: true, completion: nil)
            tableView.reloadData()
            self.tableView.separatorStyle = .None
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)

        print(lat,long)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        if((searchController.searchBar.text!.characters.count) > 4){
            self.getPlaces(String(searchController.searchBar.text!))
            self.tableView.separatorStyle = .SingleLine
        }
    }
    
    func getPlaces(place: String) {
        
        // Note this does not use CLLocation method so could be fabricated!
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        self.array = [] // Storing results
        
        let parameters = [
            "address": place,
            "region" : countryCode,
            "key" : "AIzaSyDhx9NTuC7DBbVGKhrEuMLD5GJESIgzZjw"
            
        ]

        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json?region=GB", parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .Success(let data):
            
                    dispatch_async(dispatch_get_main_queue()){
                        
                        var arrayObj: [String] = []
                        
                        self.array = self.parseResponse(JSON(data)["results"])
                        
                        for object in self.array{
                            arrayObj.append(String(object["formatted_address"]!))
                            self.arrayObj = arrayObj
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
        
    }
    
    func parseResponse(json: JSON) -> [[String: AnyObject]]{
        var array: [[String : AnyObject]] = [] // Storing results
        
        for(var i = 0; i < json.count; i++){
            let lat = Double("\(json[i]["geometry"]["location"]["lat"])")
            let long = Double("\(json[i]["geometry"]["location"]["lng"])")
            
            array.append(["place_id": "\(json[i]["place_id"])", "formatted_address" : "\(json[i]["formatted_address"])", "types" : "\(json[i]["types"])", "lat" : lat!, "long" : long!])
        }
    
        return array
    }
}