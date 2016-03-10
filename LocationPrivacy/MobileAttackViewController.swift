//
//  MobileAttackViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 07/03/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import GoogleMaps

class MobileAttackViewController: UIViewController {
    var seconds = Double()
    var distance = Double()
    
    @IBOutlet weak var mapView: GMSMapView! // MKMapView!
    
    lazy var locationsManager: CLLocationManager = {
        var _locationsManager = CLLocationManager()
        _locationsManager.delegate = self
        _locationsManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationsManager.activityType = .Fitness
        
        _locationsManager.distanceFilter = 10.0
        
        return _locationsManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsManager.requestAlwaysAuthorization()
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
        
        startLocationUpdates()
        mapView.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewWillDisappear(true)
        timer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MobileAttackVC")
    }
    
    func eachSecond(timer: NSTimer){
        seconds++
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
        //timeLabel.text = "Time: " + secondsQuantity.description
        print("Time: \(secondsQuantity.description)")
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: distance)
        //distanceLabel.text = "Distance: " + distanceQuantity.description
        print("Distance: \(distanceQuantity.description)")
        
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        //paceLabel.text = "Pace: " + paceQuantity.description
        print("Pace: \(paceQuantity.description)")
    }
    
    func startLocationUpdates(){
        locationsManager.startUpdatingLocation()
    }
    
}

extension MobileAttackViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                }
            }
            
            self.locations.append(location)
        }
    }
}
