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
    @IBOutlet weak var discretizeSwitch: UISwitch!
    
    var locationManager:CLLocationManager!
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    internal var artiflongitude: Double = 0.0
    internal var artiflatitude: Double = 0.0
    var mapRadius = 1000;
    var json: JSON = []
    var noiseLevel = UInt32()
    var discretizePoint = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typeOfLocation.delegate = self;
        
        locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        typeOfLocation.delegate = self
        typeOfLocation.layer.borderWidth = 1.0
        typeOfLocation.layer.borderColor = UIColor.seaShell().CGColor
        searchButton.setTitleColor(UIColor.appleRed(), forState: UIControlState.Normal)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        self.noiseLevel = UInt32(noiseValue.text!)!
        
    }
    
    @IBAction func switched(sender: AnyObject) {
        if discretizeSwitch.on {
            discretizePoint = true
        } else {
            discretizePoint = false
        }
        
    }
    
    @IBAction func noiseAction(sender: UISlider) {
        let currentVal = Int(sender.value)
        noiseValue.text = "\(currentVal)"
        noiseLevel = UInt32(currentVal)             // Remember to do 0 between chosen metres here.
        
    }
    
    
    
    @IBAction func searchLocation(sender: AnyObject) {
        var alert: UIAlertController?
        
        let decimals = NSCharacterSet.decimalDigitCharacterSet()
        let intCheck = typeOfLocation.text!.rangeOfCharacterFromSet(decimals, options: NSStringCompareOptions(), range: nil)
        
        if (!typeOfLocation.text!.isEmpty){
            if intCheck == nil {
                typeOfLocation.text = typeOfLocation.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
                verifiedNoise()
            }
            else {
                alert = UIAlertController(title: "Please enter words only\n(separated by commas).", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            }
            
        }
        else {
            alert = UIAlertController(title: "Please enter data", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        if alert != nil{
            alert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert!, animated: true, completion: nil)
        }
    }
    
    func verifiedNoise() {
        switched(discretizeSwitch)
        
        var longlat: [Double] = getCurrentLocation()
        (longitude, latitude) = (longlat[0], longlat[1])
        
        sensitiveLocations(latitude, long: longitude, noise: noiseLevel)
        var noise: [Double] = addNoise(noiseLevel)
        (artiflongitude, artiflatitude) = (noise[0], noise[1])
        (artificial.longitude, artificial.latitude) = (noise[0], noise[1])
        
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(artiflatitude),\(artiflongitude)")
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .Success(let data):
                    
                    if(JSON(data)["status"] == "OK" ){
                        var all_types = [String]()
                        let json = JSON(data)["results"]
                        for(var i = 0; i < json.count; i++){
                            var array = [String]()
                            array = (Array(arrayLiteral: json[i]["types"].arrayValue)[0]).map { $0.string! }
                            all_types.appendContentsOf(array)
                        }
                        
                        if all_types.contains("natural_feature"){
                            print("Natural feature detected, re-trying noise.")
                            self.verifiedNoise()
                        }
                        else{
                            if !self.discretizePoint {
                                self.nearbyPlaces(self.artiflatitude, long: self.artiflongitude, type: self.typeOfLocation.text!)
                            }
                            else {
                                self.nearbyPlaces(self.artiflatitude, long: self.artiflongitude, type: "establishment")
                            }
                            // Else go to another function to grab establishments
                            // After steps 2 and 3 on EN are done, feed into nearbyPlaces
                        }
                    }
                    else {
                        self.verifiedNoise()
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
                
        }
    }
    
    
    func nearbyPlaces(lat: Double, long: Double, type: String){
        let parameters : [String : AnyObject] = [
            "location" : "\(lat),\(long)",
            "radius" : mapRadius,
            "types" : type,
            "key" : api.key
            
        ]
        
        Alamofire.request(.GET, "https:maps.googleapis.com/maps/api/place/nearbysearch/json?", parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .Success(let data):
                    self.json = JSON(data)["results"]
                    
                    
                    dispatch_async(dispatch_get_main_queue()){
                            if !self.discretizePoint {
                                    self.performSegueWithIdentifier("showPlaceList", sender: nil) // NOTE TO SELF: Hooked up segue from searchViewController to PlacesViewController, rather than Search button
                            }
                            else{
                                self.discretizePointToBuilding(self.json)
                            }

                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
        
    }
    
    func discretizePointToBuilding(buildings: JSON){
        var buildingGPS = [[Double]]()
        let currentArtificialLocation = CLLocation(latitude: artificial.latitude!, longitude: artificial.longitude!)
        var distance = [Double]()
        
        for(var i = 0; i < json.count; i++){
            let lat = Double("\(json[i]["geometry"]["location"]["lat"])")
            let long = Double("\(json[i]["geometry"]["location"]["lng"])")
            
            buildingGPS.append([lat!,long!])
            
            let buildingLocation = CLLocation(latitude: buildingGPS[i][0], longitude: buildingGPS[i][1])
            distance.append(currentArtificialLocation.distanceFromLocation(buildingLocation)) // In miles
        }
        
        let closestBuilding = buildingGPS[distance.indexOf(distance.minElement()!)!]
        
        artificial.generalised_building = String(json[Int(distance.indexOf(distance.minElement()!)!)]["name"])
        
        let discretizedLat = closestBuilding[0]
        let discretizedLng = closestBuilding[1]
        
        self.discretizePoint = false
        
        print("buildingGPS \(buildingGPS)")
        print("distance \(distance)")
        print("ESTABLISHMENT LAT/LONGS: \(discretizedLat),\(discretizedLng)")
        (artificial.latitude, artificial.longitude) = (discretizedLat, discretizedLng)
        nearbyPlaces(discretizedLat, long: discretizedLng, type: typeOfLocation.text!)
    }
    
    func getCurrentLocation() -> [Double] {
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            currentLocation = locationManager.location
        }
        
        if (currentLocation != nil){
            (real.latitude, real.longitude) = (currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            return [currentLocation.coordinate.longitude, currentLocation.coordinate.latitude]
        }
        return [Double(0)]
    }
    
    func addNoise(metres: UInt32) -> [Double] {
        var artifLong: Double
        var artifLat: Double
        let earthRadius: Double = 6371.0
        let angle = Double(arc4random_uniform(360) + 1) // General random angle 0-360
        print("Angle: " + String(angle))
        let distance = Double(arc4random_uniform(metres+1)) / 1000.0
        print("Randomised metres from 0-\(metres): \(distance) converted to km")
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
        
        print("      Real Latitude: " + String(latitude))
        print("Artificial Latitude: " + String(artifLat))
        
        print("      Real Longitude: " + String(longitude))
        print("Artificial Longitude: " + String(artifLong) + "\n")
        
        return [artifLong, artifLat]
    }
    
    func sensitiveLocations(lat: Double, long: Double, noise: UInt32) -> Bool {
        let realm = try! Realm()
        
        let filterResults = realm.objects(SensitiveLocations).filter("latitude >= \(Int(lat))").filter("latitude < \(Int(lat)+1)")
        if !filterResults.isEmpty {
            let usersLocation = CLLocation(latitude: lat, longitude: long)
            for i in 0..<filterResults.count{
                print(filterResults[i]["latitude"])
                
                let protectedLocation = CLLocation(latitude: filterResults[i]["latitude"]! as! Double, longitude: filterResults[i]["longitude"]! as! Double)
                
                let distance = (usersLocation.distanceFromLocation(protectedLocation)) // In metres
                
                print("Distance from sensitive location is: \(distance)m")
                if distance < (filterResults[i]["minimumMetres"] as! Double) { // Checking if distance < minimum from sensitive
                    let userMinimumNoise = UInt32(filterResults[i]["minimumMetres"] as! Int)
                    print("User's minimum distance from sensitive location is: \(userMinimumNoise)m")
                    self.noiseLevel = userMinimumNoise + noise
                    print("Noise changed to: \(self.noiseLevel)m")
                    return true
                }
            }
        }
        
        //self.noiseLevel = UInt32(String(noiseValue.text!.characters.dropLast()))!
        
        self.noiseLevel = UInt32(noiseValue.text!)!
        print("Noise kept/reset as: \(self.noiseLevel)")
        return false
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showPlaceList") {
            let placesVC = segue.destinationViewController as! PlacesViewController
            
            placesVC.json = self.json
            
            let inputAsArray:Array = (self.typeOfLocation.text!).componentsSeparatedByString(",")
            placesVC.chosenType = inputAsArray
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
