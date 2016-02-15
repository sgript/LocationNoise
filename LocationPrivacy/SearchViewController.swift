//
//  SearchViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 03/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Alamofire
import SwiftyJSON
import Darwin
import QuartzCore
import RealmSwift

class SearchViewController: UIViewController {
    @IBOutlet weak var typeOfLocation: CustomTextField!
    @IBOutlet weak var noiseValue: UILabel!
    @IBOutlet weak var searchButton: UIButton!

    var locationManager:CLLocationManager!
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    internal var artiflongitude: Double = 0.0
    internal var artiflatitude: Double = 0.0
    var mapRadius = 1000;
    var json: JSON = []
    var noiseLevel: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typeOfLocation.delegate = self;

        locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        
        typeOfLocation.delegate = self
        typeOfLocation.layer.borderWidth = 1.0
        typeOfLocation.layer.borderColor = UIColor.seaShell().CGColor
        searchButton.setTitleColor(UIColor.appleRed(), forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("SearchVC")
    }
    
    @IBAction func noiseAction(sender: UISlider) { // Note to self, sliders suck, change to something else.
        let currentVal = Int(sender.value)
        noiseValue.text = "\(currentVal)m"
        noiseLevel = Double(currentVal)
    }
    
    @IBAction func searchLocation(sender: AnyObject) {

        var longlat: [Double] = getCurrentLocation()
        (longitude, latitude) = (longlat[0], longlat[1])
        print(latitude, longitude)
        
        //print(longitude, latitude)
        
        // If statement needed to ensure input for type of location + noise is given
        
        var noise: [Double] = addNoise(noiseLevel)
        (artiflongitude, artiflatitude) = (noise[0], noise[1])
        (artificial.longitude, artificial.latitude) = (noise[0], noise[1])
        
        sensitiveLocations(latitude, long: longitude)
        
        let parameters : [String : AnyObject] = [
            "location" : "\(artiflatitude),\(artiflongitude)",
            // "location" : "51.4836193155864, -3.16298625178967", // Fixed location for debugging
            "radius" : mapRadius,
            "types" : typeOfLocation.text!,
            "sensor" : "true",
            "key" : "AIzaSyDhx9NTuC7DBbVGKhrEuMLD5GJESIgzZjw"

        ]

        Alamofire.request(.GET, "https:maps.googleapis.com/maps/api/place/nearbysearch/json?", parameters: parameters)
            .validate()
            .responseJSON { response in
            switch response.result {
                
            case .Success(let data):
                self.json = JSON(data)["results"]
                
                dispatch_async(dispatch_get_main_queue()){
                    self.performSegueWithIdentifier("showPlaceList", sender: nil) // NOTE TO SELF: Hooked up segue from searchViewController to PlacesViewController, rather than Search button
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
    
        }
        
    }
    
    
    func getCurrentLocation() -> [Double] {
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                
                currentLocation = locationManager.location
        }
        
        if (currentLocation != nil){
            return [currentLocation.coordinate.longitude, currentLocation.coordinate.latitude]
        }
        return [Double(0)]
    }
    
    func addNoise(metres: Double) -> [Double] {
        var artifLong: Double
        var artifLat: Double
        let earthRadius: Double = 6371.0
        let angle = Double(arc4random_uniform(360) + 1) // General random angle 0-360
        print("Angle: " + String(angle))
        let distance:Double = metres/1000.0
        let diam: Double = 180.0
        
        let angularDistance = (distance / earthRadius)
        
        // Conversion to Radians
        let angleRad = angle / diam * M_PI
        let longRad = longitude / diam * M_PI
        let latRad = latitude / diam * M_PI
        
        // Fake locations - Based on given angularDistance and Angle relative to North
        let artifLatRad = asin(sin(latRad) * cos(angularDistance) + cos(latRad) * sin(angularDistance) * cos(angleRad))
        let artifLongRad = longRad + atan2(sin(angleRad) * sin(angularDistance) * cos(latRad), cos(angularDistance) - sin(latRad) * sin(artifLatRad))
        
        // Back to decimals
        artifLong = artifLongRad * diam / M_PI
        artifLat = artifLatRad * diam / M_PI
        
        print("      Real Longitude: " + String(longitude))
        print("Artificial Longitude: " + String(artifLong) + "\n")
        
        print("      Real Latitude: " + String(latitude))
        print("Artificial Latitude: " + String(artifLat))
        
        return [artifLong, artifLat]
    }
    
    func sensitiveLocations(lat: Double, long: Double) -> Bool {
        let realm = try! Realm()
        
        let filterResults = realm.objects(SensitiveLocations).filter("latitude > \(Int(lat))").filter("latitude < \(Int(lat)+1)")
        
        let usersLocation = CLLocation(latitude: lat, longitude: long)
        for i in 0..<filterResults.count{
            print(filterResults[i]["latitude"])
            
            let protectedLocation = CLLocation(latitude: filterResults[i]["latitude"]! as! Double, longitude: filterResults[i]["longitude"]! as! Double)
            
            let distance = usersLocation.distanceFromLocation(protectedLocation) / 1000
            if distance < 1 {
                print("Needs extra noise..") // Once returned true, will need to add a percentage of extra noise for extra protection of the user's location, if and only if the number of metres chosen are insufficient.
                return true
            }
        }
        return false
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showPlaceList") {
            let placesVC = segue.destinationViewController as! PlacesViewController
            
            placesVC.json = self.json
            
            let inputAsArray:Array = (self.typeOfLocation.text!.stringByReplacingOccurrencesOfString(" ", withString: "")).componentsSeparatedByString(",")
            placesVC.chosenType = inputAsArray //self.typeOfLocation.text! // Check for crashes when no location given!!
            placesVC.actual = [latitude, longitude]
        }
    }
    
    override internal func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == typeOfLocation {
            searchLocation(textField)
        }
        return true
    }
}
