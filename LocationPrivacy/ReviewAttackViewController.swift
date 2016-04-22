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
//import QuartzCore
//import Darwin


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
                
                var artificial_points = [[Double]]()
                for(var i = 1; i <= self.pointsToPlot; i++){

                    let title = "Artificial point \(i)"
                    let points = getArtificialPoint()
                    
                    
                    artificial_points.append(points)
                
                    mapComponents(title, longlat: points, artificial_point: true)
                }
                
                let average_artificial_location = findIntersection(artificial_points)
                mapComponents("Predicted real location", longlat: average_artificial_location, artificial_point: false)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapComponents(markTitle: String, longlat: [Double], artificial_point: Bool){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(longlat[1]), CLLocationDegrees(longlat[0])))
        
        marker.title = markTitle
        marker.map = mapView
        marker.icon = GMSMarker.markerImageWithColor(UIColor.appleRed())

        
        if artificial_point {
            marker.icon = UIImage(named: "noise")
            let circle = GMSCircle(position: CLLocationCoordinate2DMake(CLLocationDegrees(longlat[1]), CLLocationDegrees(longlat[0])), radius: Double(self.metres))
            circle.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            circle.strokeWidth = 2
            circle.strokeColor = UIColor.googleBlue()
            circle.map = mapView
        
        }
    }
    
    func findIntersection(artificial_locations: [[Double]]) -> [Double] {
        
        var cartesians = [[Double]]()
        for(var i = 0; i < artificial_locations.count; i++){
            let latitudeRadian = artificial_locations[i][1] * M_PI/180.0
            let longitudeRadian = artificial_locations[i][0] * M_PI/180.0
            
            let x = cos(latitudeRadian) * cos(longitudeRadian)
            let y = cos(latitudeRadian) * sin(longitudeRadian)
            let z = sin(latitudeRadian)
            
            cartesians.append([x,y,z])
        }
        
        print("GPS COORDS: \(artificial_locations)")
        print("CARTESIAN: \(artificial_locations)")
        
        var x = Double()
        var y = Double()
        var z = Double()
        for cartesian in cartesians {
            x = x + cartesian[0]
            y = y + cartesian[1]
            z = z + cartesian[2]
        }
        
        x = x / Double(cartesians.count)
        y = y / Double(cartesians.count)
        z = z / Double(cartesians.count)
        
        let lon = atan2(y, x)
        let hyp = sqrt(x * x + y * y)
        let lat = atan2(z, hyp)
        
        // Back to decimals
        let latitude = lon * 180.0/M_PI
        let longitude = lat * 180.0/M_PI
        
        print("Average lat/long: \([latitude, longitude])")
        return [latitude, longitude]
    }

}