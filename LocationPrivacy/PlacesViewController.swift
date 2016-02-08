//
//  PlacesViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 03/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

class PlacesViewController: UIViewController {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("PlacesVC")
    }
    
    func arrayifyJSON(){

        var miles:[Double] = []
        var array: [JSON] = []
        for(var i = 0; i < self.json.count; i++){
            array = Array(arrayLiteral: self.json[i]["types"].arrayValue)[0] // Reconsider refactoring for efficiency.
            let stringArray = array.map { $0.string!}
            
            //for(var j = 0; j < chosenType.count; j++){//
    
            
            var previous = ""
            var current = " "
            for type in chosenType{
                if(stringArray.contains(type)){ // MAY REMOVE

                    let lat = Double("\(json[i]["geometry"]["location"]["lat"])")
                    let long = Double("\(json[i]["geometry"]["location"]["lng"])")
                    let distance = distanceFromEveryLocation(long!, loclat: lat!)
                    //miles.append(distance)
                    
                    current = "\(json[i]["name"])"
                    
                    if (arrayOfDictionary.count > 0){
                        //previous = "\(arrayOfDictionary[arrayOfDictionary.count-2]["name"] as! String)"
                        previous = "\(arrayOfDictionary[arrayOfDictionary.count-1]["name"] as! String)"
                        print("\(previous), \(current)")
                        print("\(arrayOfDictionary[arrayOfDictionary.count-1])\n")
                    }
                    
                    if(current != previous){
                        arrayOfDictionary.append(["name": "\(json[i]["name"])", "rating" : "\(json[i]["rating"])", "icon" : "\(json[i]["icon"])", "vicinity" : "\(json[i]["vicinity"])", "type" : "\(type.capitalizedString)", "lat" : lat!, "long" : long!, "distance" : distance]) // Possibly not use "!" and just use as string, later convert safely as long lat doubles.
                       miles.append(distance)
                   
                    }
                    if(current == previous){
                        var currentTypes = "\(arrayOfDictionary[arrayOfDictionary.count-1]["type"] as! String)"
                        var appendedType = "\(currentTypes), \(type)"
                        
                        arrayOfDictionary.removeAtIndex(arrayOfDictionary.count-1)
                        arrayOfDictionary.append(["name": "\(json[i]["name"])", "rating" : "\(json[i]["rating"])", "icon" : "\(json[i]["icon"])", "vicinity" : "\(json[i]["vicinity"])", "type" : "\(appendedType)", "lat" : lat!, "long" : long!, "distance" : distance])
                                                
                    }
                    

                }
                
            }
            print("miles: \(miles.count)")
            print("arrdict: \(arrayOfDictionary.count)")
        }
        print("out")
        //print(arrayOfDictionary)
        
        //print(String(arrayOfDictionary)) // DEBUG
        //print(arrayOfDictionary.count) // DEBUG
        //print("miles \(miles)") // DEBUG
        var sortMiles = miles
        quickSort(&sortMiles, left: 0, right: miles.count-1)
        //print("miles sorted \(sortMiles)") // DEBUG
        
        // Reconstruct the array of dictionaries to be in sorted order using indexes.
        var copyArrayOfDictionary: [[String: AnyObject]] = []
        for sorted in sortMiles{
            var index:Int = miles.indexOf(sorted)!
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
        
        var distance = (currentLocation.distanceFromLocation(placelocation) / 1000) * 0.62137 // In miles
        
        //1. TODO - Will calculate distance from each location and real location of user and make an array of distances in metres for each location as-is for arrayOfDictionary
        //2. Copy of this array will be made
        //3. This copy will be sorted
        //4. Once sorted, each distance in metres will be indexed to original array (point 1.) to index into arrayOfDictionary for closest to furthest locations
        //5. A new arrayOfDictionaryCopy will be used which basically contains the sorted version of arrayOfDictionary, and will be used henceforth in the cell output.
        
        return distance
    }
    
    func partition(inout dataList: [Double], low: Int, high: Int) -> Int { // https://gist.github.com/fjcaetano/b0c00a889dc2a17efad9#gistcomment-1338271
        var pivotPos = low
        var pivot = dataList[low]
        
        for var i = low + 1; i <= high; i++ {
            if dataList[i] < pivot && ++pivotPos != i {
                (dataList[pivotPos], dataList[i]) = (dataList[i], dataList[pivotPos])
            }
        }
        (dataList[low], dataList[pivotPos]) = (dataList[pivotPos], dataList[low])
        return pivotPos
    }
    
    func quickSort(inout dataList: [Double], left: Int, right: Int) {
        if left < right {
            var pivotPos = partition(&dataList, low: left, high: right)
            quickSort(&dataList, left: left, right: pivotPos - 1)
            quickSort(&dataList, left: pivotPos + 1, right: right)
        }
    }
}

extension PlacesViewController: UITableViewDataSource {
    // Newly added subtitle2
    func makeAttributedString(title title: String, subtitle: String, subtitle2: String) -> NSAttributedString { // Taken from https://www.hackingwithswift.com/read/32/2/automatically-resizing-uitableviewcells-with-dynamic-type-and-ns
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.appleRed()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSMutableAttributedString(string: "\(subtitle)\n", attributes: subtitleAttributes)
        //let subtitleString = NSAttributedString(string: "\(subtitle)\n", attributes: subtitleAttributes) OLD
        
        let subtitleString2 = NSAttributedString(string: subtitle2, attributes: subtitleAttributes) // Newly added
        
        subtitleString.appendAttributedString(subtitleString2) // Newly added
        titleString.appendAttributedString(subtitleString)
        
        return titleString
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // May change to multiple if searching for multiple types of location - e.g. Restaurant, Bar, Places of Interest etc..
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDictionary.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let cell = UITableViewCell()
        var item = arrayOfDictionary[indexPath.row]
        var miles = String(format:"%.1f", item["distance"]! as! Float)
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
//        let indexPath = tableView.indexPathForSelectedRow
//        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
        
        performSegueWithIdentifier("giveDetails", sender: indexPath)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "giveDetails") {
            let detailsVC = segue.destinationViewController as! DetailsViewController
            

            print(sender.row)
            detailsVC.placeDetails = self.arrayOfDictionary[sender.row]
        }
    }
    
}

