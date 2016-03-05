//
//  ReviewAttackViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 27/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import CoreLocation

class ReviewAttackViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let metres:UInt32 = 100
    let searchVC = SearchViewController()
    var pointsToPlot = Int()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        print(pointsToPlot)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ReviewAttacksVC")
    }
    
    func getUserCurrentLocation() -> [Double] {
        searchVC.locationManager = self.locationManager
        let longlat = searchVC.getCurrentLocation()
        
        return longlat
    }
    
    func getArtificialPoint() -> [Double] {
        searchVC.latitude = real.latitude!
        searchVC.longitude = real.longitude!
        
        let artiflonglat = searchVC.addNoise(self.metres)
        artificial.latitude = artiflonglat[1]
        artificial.longitude = artiflonglat[0]
        
        return artiflonglat
        
    }
    
}

extension ReviewAttackViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                locationManager.startUpdatingLocation()
                mapView.myLocationEnabled = true
                mapView.settings.myLocationButton = true
                
                let longlat = getUserCurrentLocation()
                real.latitude = longlat[1]
                real.longitude = longlat[0]
                
                print(longlat)
                for(var i = 1; i <= self.pointsToPlot; i++){
                    let points = getArtificialPoint()
                    let title = "Artificial point \(i)"
                    
                    addArtificialPoint(title, longlat: points)
                }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13.8, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func addArtificialPoint(markTitle: String, longlat: [Double]){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(artificial.latitude!), CLLocationDegrees(artificial.longitude!)))
        
        marker.icon = UIImage(named: "noise")
        marker.title = markTitle
        marker.map = mapView
        
        let circle = GMSCircle(position: CLLocationCoordinate2DMake(CLLocationDegrees(longlat[1]), CLLocationDegrees(longlat[0])), radius: Double(self.metres))
        circle.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        circle.strokeWidth = 2
        circle.strokeColor = UIColor.googleBlue()
        circle.map = mapView
        
        print("Plotted artificial location")
    }
    

}