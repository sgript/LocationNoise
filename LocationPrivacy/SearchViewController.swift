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
    
    @IBAction func noiseAction(sender: UISlider) {
        let currentVal = Int(sender.value)
        noiseValue.text = "\(currentVal)"
    }

    @IBAction func searchLocation(sender: AnyObject) {
        var chosenType = typeOfLocation.text
        (longitude, latitude) = (getCurrentLocation()[0], getCurrentLocation()[1])

        
        let parameters : [String : AnyObject] = [
            "location" : "\(latitude),\(longitude)",
            "radius" : mapRadius,
            "types" : noiseValue.text!,
            "sensor" : "true",
            "key" : "AIzaSyDhx9NTuC7DBbVGKhrEuMLD5GJESIgzZjw"
            
        ]
        
        Alamofire.request(.GET, "https:maps.googleapis.com/maps/api/place/nearbysearch/json?", parameters: parameters).responseJSON { response in
            print(response)
            switch response.result {
            case .Success(let data):
                self.json = JSON(data)["results"]

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
    
    func addNoise(metres: String) {
        
    }
    
}
