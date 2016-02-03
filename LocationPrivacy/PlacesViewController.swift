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
import AlamofireImage


class PlacesViewController: UIViewController {
    var delegate: PlacesViewController? = nil
    var json: JSON = []
    var chosenType: String = ""
    var arrayOfDictionary: [[String: AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In places view controller")
        
        arrayifyJSON()
        
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
                arrayOfDictionary.append(["id": "\(json[i]["place_id"])", "name": "\(json[i]["name"])", "rating" : "\(json[i]["rating"])", "icon" : "\(json[i]["icon"])"])
            }
        }
        
        print(String(arrayOfDictionary))
    }

}


extension PlacesViewController: UITableViewDataSource {
    
    func makeAttributedString(title title: String, subtitle: String) -> NSAttributedString { // Taken from https://www.hackingwithswift.com/read/32/2/automatically-resizing-uitableviewcells-with-dynamic-type-and-ns
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.purpleColor()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var name: [AnyObject] = []
        var rating: [AnyObject] = []
        var icon: [AnyObject] = []
        for places in arrayOfDictionary {
            name.append(places["name"]!)
            rating.append(places["rating"]!)
            icon.append(places["icon"]!) // Need to check how to do later
        }
        cell.textLabel?.numberOfLines = 2;
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        cell.textLabel?.attributedText = makeAttributedString(title: "\(name[indexPath.row])", subtitle: "\(rating[indexPath.row])")
    
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
        
    }
}
