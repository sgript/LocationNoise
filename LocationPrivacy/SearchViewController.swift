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

class SearchViewController: UIViewController {
    @IBOutlet weak var typeOfLocation: UITextField!
    @IBOutlet weak var noiseValue: UILabel!
    var locationManager:CLLocationManager!
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var mapRadius = 1000;
    var json: JSON = []
    
    override func viewDidLoad() {
        locationManager = CLLocationManager()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func noiseAction(sender: UISlider) { // Note to self, sliders suck, change to something else.
        let currentVal = Int(sender.value)
        noiseValue.text = "\(currentVal)"
    }
    
    @IBAction func searchLocation(sender: UIButton) {
        //(longitude, latitude) = (getCurrentLocation()[0], getCurrentLocation()[1])
        //print(longitude, latitude)
        
        // If statement needed to ensure input for type of location + noise is given
        var artiflongitude: Double = 0.0
        var artiflatitude: Double = 0.0
        (artiflongitude, artiflatitude) = (addNoise(Double(noiseValue.text!)!)[0], addNoise(Double(noiseValue.text!)!)[1])
        
        
        let parameters : [String : AnyObject] = [
//            "location" : "\(artiflatitude),\(artiflongitude)",
            "location" : "51.4836193155864, -3.16298625178967",             // CHANGE LATER BACK TO ARTIFICIAL!!!
            "radius" : mapRadius,
            "types" : noiseValue.text!,
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showPlaceList") {
            let placesVC = segue.destinationViewController as! PlacesViewController

            placesVC.json = self.json
            placesVC.chosenType = self.typeOfLocation.text! // Check for crashes when no location given!!
        }
    }
    
}
