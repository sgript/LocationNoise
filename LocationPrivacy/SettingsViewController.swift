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

class SettingsViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var footer: UIView!
    
    var resultSearchController: UISearchController?
    var arrayObj =  [String]()
    var array: [[String : AnyObject]] = []
    var hasPassword: Bool?
    @IBOutlet weak var passwordButton: UIButton!
    
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
        
    
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag; // !

    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.separatorStyle = .None
        
        let realm = try! Realm()
        let password = realm.objects(SensitiveLocationsPassword)
        
        if password.isEmpty {
            hasPassword = false
        }
        else {
            hasPassword = true
            passwordButton.setTitle("Change password", forState: .Normal)
        }
        
        print(password)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.resultSearchController!.removeFromParentViewController()
    }
    
    @IBAction func goToSettings(sender: AnyObject) {
        if hasPassword! {
            let alert = UIAlertController(title: "Enter your password", message: "Enter your password to access your stored sensitive locations.", preferredStyle: .Alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.secureTextEntry = true
            })
            
            //3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                textField.placeholder = "Enter a password."
                print("Text field: \(textField.text)")
                
                let realm = try! Realm()
                let password = realm.objects(SensitiveLocationsPassword)
                let sensitive = SensitiveLocationsPassword()
                let currentPassword = password[0]["password"]
                
                var inneralert: UIAlertController?
                if(textField.text != nil && textField.text!.characters.count > 0){
                    
                    if password[0]["password"]! as! String == textField.text! {
                        
                        let attempts = password[0]["numberOfAttempts"] as! Int
                        if (attempts > 0 && attempts < 5) {
                            realm.beginWrite()
                            realm.delete(password)
                            try! realm.commitWrite()
                            
                            sensitive.password = currentPassword as! String
                            sensitive.numberOfAttempts = 0
                            
                            try! realm.write {
                                realm.add(sensitive)
                            }
                            
                            inneralert = UIAlertController(title: "Notice!", message: "\nPrevious incorrect attempts reset.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        if password[0]["dataDestroyed"] as! Bool == true {
                            realm.beginWrite()
                            realm.delete(password)
                            try! realm.commitWrite()
                            
                            sensitive.password = currentPassword as! String
                            sensitive.numberOfAttempts = 0
                            sensitive.dataDestroyed = false
                            
                            try! realm.write {
                                realm.add(sensitive)
                            }
                        
                            inneralert = UIAlertController(title: "Notice!", message: "Your data was wiped due to break-ins.\nPrevious incorrect attempts reset.\nPlease re-add sensitive data, if any.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        self.performSegueWithIdentifier("goToManage", sender: self)
                        print("debug1")
                    }
                    else {
                        inneralert = UIAlertController(title: "Incorrect!", message: "Your current password does not match!", preferredStyle: UIAlertControllerStyle.Alert)
                        let attempts = (password[0]["numberOfAttempts"]! as! Int) + 1
                    
                        
                        if attempts >= 5 {
                            
                            let sensitive_locations = realm.objects(SensitiveLocations)
                            
                            realm.beginWrite()
                            realm.delete(sensitive_locations)
                            realm.delete(password)
                            try! realm.commitWrite()

                            sensitive.dataDestroyed = true
                            
                            inneralert = UIAlertController(title: "Incorrect!", message: "Your current password does not match!\n5 out of 5 attempts made. Data destroyed!", preferredStyle: UIAlertControllerStyle.Alert)
                            
                        }
                        else {
                            realm.beginWrite()
                            realm.delete(password)
                            try! realm.commitWrite()
                            
                            sensitive.dataDestroyed = false
                            
                            inneralert = UIAlertController(title: "Incorrect!", message: "Your current password does not match!\n\(attempts) out of 5 attempts made.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        sensitive.numberOfAttempts = attempts
                        sensitive.password = currentPassword as! String
                        
                        try! realm.write {
                            realm.add(sensitive)
                        }
                    
                    
                    }
                    
                }
                else {
                    inneralert = UIAlertController(title: "Error!", message: "You did not enter anything!", preferredStyle: UIAlertControllerStyle.Alert)
                }
                
                if(inneralert != nil){
                    inneralert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(inneralert!, animated: true, completion: nil)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
            }))
            
            // 4. Present the alert.
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.performSegueWithIdentifier("goToManage", sender: self)
        }
    
    }
    
    @IBAction func setPassword(sender: AnyObject) {
        
        if !hasPassword! {
            let alert = UIAlertController(title: "Choose password", message: "Enter a password in order to view your sensitive locations.", preferredStyle: .Alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.secureTextEntry = true
            })
            
            //3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                textField.placeholder = "Enter a password."
                print("Text field: \(textField.text)")
                
                let sensitive = SensitiveLocationsPassword()
                
                var alert: UIAlertController?
                if(textField.text != nil && textField.text!.characters.count > 0){
                
                        let realm = try! Realm()
                    
                        let password = realm.objects(SensitiveLocationsPassword)
                    
                        if !password.isEmpty {
                            realm.beginWrite()
                            realm.delete(sensitive)
                            try! realm.commitWrite()
                        }
                    
                        sensitive.password = textField.text!
                    
                        try! realm.write {
                            realm.add(sensitive)
                            print("\(sensitive)")
                            alert = UIAlertController(title: "Saved", message: "Your sensitive data is password protected.", preferredStyle: UIAlertControllerStyle.Alert)
                            self.passwordButton.setTitle("Change password", forState: .Normal)
                            self.hasPassword = true
                        }
                }
                else {
                    alert = UIAlertController(title: "Not saved!", message: "You did not enter anything!", preferredStyle: UIAlertControllerStyle.Alert)
                }
                
                
                alert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert!, animated: true, completion: nil)
                self.tableView.reloadData()
                self.tableView.separatorStyle = .None
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
            }))
            
            // 4. Present the alert.
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            verifyPassword()
        }
        
    }
    
    func verifyPassword(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Password change", message: "Enter your current password and your desired new password.", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.secureTextEntry = true
            textField.placeholder = "Type current password here."
        })
        
        alert.addTextFieldWithConfigurationHandler({ (textField2) -> Void in
            textField2.secureTextEntry = true
            textField2.placeholder = "Type new password here."
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            let textField2 = alert.textFields![1] as UITextField
            print("Text field 1: \(textField.text)")
            print("Text field 2: \(textField2.text)")
            
            
            var alert: UIAlertController?
            if(textField.text != nil && textField.text!.characters.count != 0){
                
                if(textField2.text != nil && textField2.text!.characters.count != 0){
                    let sensitive = SensitiveLocationsPassword()
                    
                    let realm = try! Realm()
                    let password = realm.objects(SensitiveLocationsPassword)
                    let currentPassword = password[0]["password"]
                    
                    if password[0]["password"]! as! String == textField.text! {
                        
                        realm.beginWrite()
                        realm.delete(password)
                        try! realm.commitWrite()
                        
                        sensitive.password = textField2.text!
                        
                        let realm = try! Realm()
                        
                        
                        try! realm.write {
                            realm.add(sensitive)
                            print("\(sensitive)")
                            alert = UIAlertController(title: "Saved", message: "Your sensitive data is password protected.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        print(password)
                    }
                    else {
                        let attempts = (password[0]["numberOfAttempts"]! as! Int) + 1
                        
                        
                        if attempts >= 5 {
                            
                            let sensitive_locations = realm.objects(SensitiveLocations)
                            
                            realm.beginWrite()
                            realm.delete(sensitive_locations)
                            realm.delete(password)
                            try! realm.commitWrite()
                            
                            sensitive.dataDestroyed = true
                            
                            alert = UIAlertController(title: "Incorrect!", message: "Your current password does not match!\n5 out of 5 attempts made. Data destroyed!", preferredStyle: UIAlertControllerStyle.Alert)
                            
                        }
                        else {
                            realm.beginWrite()
                            realm.delete(password)
                            try! realm.commitWrite()
                            
                            sensitive.dataDestroyed = false
                            
                            alert = UIAlertController(title: "Incorrect!", message: "Your current password does not match!\n\(attempts) out of 5 attempts made.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                        
                        sensitive.numberOfAttempts = attempts
                        sensitive.password = currentPassword as! String
                        
                        try! realm.write {
                            realm.add(sensitive)
                        }
                    }
                }
                else {
                    alert = UIAlertController(title: "Not saved", message: "Enter your new password!", preferredStyle: UIAlertControllerStyle.Alert)
                }

            }
            else {
                alert = UIAlertController(title: "Not saved", message: "Enter your current password!", preferredStyle: UIAlertControllerStyle.Alert)
            }
            alert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert!, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
        

    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.resultSearchController!.active){
            return self.arrayObj.count
        }
        else{
            // Do nothing
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if (self.resultSearchController!.active){
            cell!.textLabel?.text = self.arrayObj[indexPath.row]
            
            return cell!
        }
        else{
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
                
                var alert: UIAlertController?
            
                if(textField.text!.characters.count != 0){
                    if let intCheck = Int(textField.text!){
                        if (intCheck <= 1000 && intCheck >= 100){
                        
                            let sensitive = SensitiveLocations()
                            
                            sensitive.id = place_id as! String
                            sensitive.formatted_address = address as! String
                            sensitive.latitude = lat
                            sensitive.longitude = long
                            
                            sensitive.minimumMetres = Double(textField.text!)!
                            
                            let realm = try! Realm()
                            
                        
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
                        }
                        else {
                           alert = UIAlertController(title: "Error", message: "Please enter values 100-1000 metres only.", preferredStyle: UIAlertControllerStyle.Alert)
                        }
                    }
                    else {
                        alert = UIAlertController(title: "Error", message: "Enter integers only!", preferredStyle: UIAlertControllerStyle.Alert)
                    }
                }
                else {
                    alert = UIAlertController(title: "Error", message: "You did not enter anything.", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        
        if searchController.active{
            print("active")
            searchController.searchBar.enablesReturnKeyAutomatically = false
            self.footer.hidden = true
        }
        if !searchController.active{
            print("inactive")
            searchController.searchBar.enablesReturnKeyAutomatically = true
            self.footer.hidden = false
            self.tableView.reloadData()
            self.tableView.separatorStyle = .None
        }
    }
    
    func getPlaces(place: String) {
        
        // Note this does not use CLLocation method so could be fabricated!
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        self.array = [] // Storing results
        
        let parameters = [
            "address": place,
            "region" : countryCode,
            "key" : api.key
            
        ]

        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json?", parameters: parameters)
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
        
        for i in 0 ..< json.count {
        
            let lat = Double("\(json[i]["geometry"]["location"]["lat"])")
            let long = Double("\(json[i]["geometry"]["location"]["lng"])")
            
            array.append(["place_id": "\(json[i]["place_id"])", "formatted_address" : "\(json[i]["formatted_address"])", "types" : "\(json[i]["types"])", "lat" : lat!, "long" : long!])
        }
    
        return array
    }

    
}