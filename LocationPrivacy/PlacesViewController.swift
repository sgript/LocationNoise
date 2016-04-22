//
//  PlacesViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 03/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import  SwiftyJSON
import Alamofire
import CoreLocation

class PlacesViewController: UIViewController {
    @IBOutlet weak var empty: UILabel!
    
    var delegate: PlacesViewController? = nil
    var json: JSON = []
    var chosenType: [String] = []
    var arrayOfDictionary: [[String: AnyObject]] = []
    var actual: [Double] = [] // Real long/lat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In places view controller")
        arrayifyJSON()
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(true)
        empty.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("PlacesVC")
    }
    
    func arrayifyJSON(){
        
        var miles:[Double] = []
        var array: [JSON] = []
        for i in 0 ... self.json.count {
            array = Array(arrayLiteral: self.json[i]["types"].arrayValue)[0] // Reconsider refactoring for efficiency.
            let stringArray = array.map { $0.string!}
                        
            var previous = String()
            var current = String()
            for type in chosenType{
                if(stringArray.contains(type)){ // MAY REMOVE
                    
                    let lat = Double("\(json[i]["geometry"]["location"]["lat"])")
                    let long = Double("\(json[i]["geometry"]["location"]["lng"])")
                    let distance = distanceFromEveryLocation(long!, loclat: lat!)
                    
                    current = "\(json[i]["name"])"
                    
                    if (arrayOfDictionary.count > 0){
                        previous = "\(arrayOfDictionary[arrayOfDictionary.count-1]["name"] as! String)"
                    }
                    
                    if(current != previous){
                        arrayOfDictionary.append(["name": "\(json[i]["name"])", "rating" : "\(json[i]["rating"])", "icon" : "\(json[i]["icon"])", "vicinity" : "\(json[i]["vicinity"])", "type" : "\(type.capitalizedString)", "lat" : lat!, "long" : long!, "distance" : distance])
                        
                       miles.append(distance) // Only need to add miles once, we don't want to add miles again if the place exists already in below if statement as another type.
                   
                    }
                    if(current == previous){
                        let currentTypes = "\(arrayOfDictionary[arrayOfDictionary.count-1]["type"] as! String)"
                        let appendedType = "\(currentTypes), \(type)"
                        
                        arrayOfDictionary.removeAtIndex(arrayOfDictionary.count-1)
                        arrayOfDictionary.append(["name": "\(json[i]["name"])", "rating" : "\(json[i]["rating"])", "icon" : "\(json[i]["icon"])", "vicinity" : "\(json[i]["vicinity"])", "type" : "\(appendedType)", "lat" : lat!, "long" : long!, "distance" : distance])
                                                
                    }
                }
            }
        }
        
        var sortMiles = miles
        Quick().sort(&sortMiles, left: 0, right: miles.count-1)
        //print("miles sorted \(sortMiles)") // DEBUG
        
        // Reconstruct the array of dictionaries to be in sorted order using indexes.
        var copyArrayOfDictionary: [[String: AnyObject]] = []
        for sorted in sortMiles{
            let index:Int = miles.indexOf(sorted)!
            copyArrayOfDictionary.append(arrayOfDictionary[index])
            
            // Remove so the exact same value is not copied based on distance, as types will be different.
            miles.removeAtIndex(miles.indexOf(sorted)!)
            arrayOfDictionary.removeAtIndex(index)
            
        }
    
        arrayOfDictionary = copyArrayOfDictionary
    }

    func distanceFromEveryLocation(loclong: Double, loclat: Double) -> Double {
        let currentLocation = CLLocation(latitude: actual[0], longitude: actual[1])
        let placelocation = CLLocation(latitude: loclat, longitude: loclong)
        
        let distance = (currentLocation.distanceFromLocation(placelocation) / 1000) * 0.62137 // In miles
        
        return distance
    }
}

extension PlacesViewController: UITableViewDataSource {

    func makeAttributedString(title title: String, subtitle: String, subtitle2: String) -> NSAttributedString { // Taken from https://www.hackingwithswift.com/read/32/2/automatically-resizing-uitableviewcells-with-dynamic-type-and-ns
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.appleRed()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
        let placeCell = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let typeAndRatingTitle = NSMutableAttributedString(string: "\(subtitle)\n", attributes: subtitleAttributes)
        let distanceTitle = NSAttributedString(string: subtitle2, attributes: subtitleAttributes) // Newly added
        
        typeAndRatingTitle.appendAttributedString(distanceTitle) // Newly added
        placeCell.appendAttributedString(typeAndRatingTitle)
        
        return placeCell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // May change to multiple if searching for multiple types of location - e.g. Restaurant, Bar, Places of Interest etc..
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfDictionary.isEmpty {
            empty.hidden = false
            tableView.separatorStyle = .None
            let wait_period = (Int64(NSEC_PER_SEC) * 3)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, wait_period), dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        else {
            empty.hidden = true
            tableView.separatorStyle = .SingleLine
        }
        
        return arrayOfDictionary.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        var item = arrayOfDictionary[indexPath.row]
        let miles = String(format:"%.1f", item["distance"]! as! Float)
        var rating = item["rating"]!
        if item["rating"]! is NSNull {
            rating = "No rating available."
        }
        
        cell.textLabel?.attributedText = makeAttributedString(title: "\(item["name"]!)", subtitle: "\(item["type"]!). Rating: \(rating)/5", subtitle2: "Actual distance: \(miles) miles")
        cell.textLabel?.numberOfLines = 3;
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension        
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("giveDetails", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "giveDetails") {
            let detailsVC = segue.destinationViewController as! DetailsViewController
            
            detailsVC.placeDetails = self.arrayOfDictionary[sender.row]
        }
    }
    
}

