//
//  DetailsViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 06/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreLocation
import MapKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDesc: UITextView!
    
    let locationManager = CLLocationManager()
    var placeDetails: [String: AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayDetails()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("DetailsVC")
    }
    
    func displayDetails(){
        self.placeTitle.text = "\(placeDetails!["name"]!)"
        let milesFromReal = String(format:"%.2f", placeDetails!["distance"]! as! Float)
        let artificialLocation = CLLocation(latitude: artificial.latitude!, longitude: artificial.longitude!)
        let locationSearched = CLLocation(latitude: placeDetails!["lat"]! as! Double, longitude: placeDetails!["long"]! as! Double)
        let distance = (artificialLocation.distanceFromLocation(locationSearched) / 1000) * 0.62137
        let milesFromArt = String(format:"%.2f", distance)
        self.placeDesc.text = "Area: \(placeDetails!["vicinity"]!)\nRating: \(placeDetails!["rating"]!)\nDistance from real location: \(milesFromReal) miles\nGoogle thinks you are \(milesFromArt) miles away from \(self.placeTitle.text!)"
    }
}

extension DetailsViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            locationManager.startUpdatingLocation()
            //mapView.myLocationEnabled = true
            //mapView.settings.myLocationButton = true
            
            let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(real.latitude!), CLLocationDegrees(real.longitude!)))
            
            addLocationPoint()
            addArtificialPoint()
            marker.title = "Your location"
            marker.icon = GMSMarker.markerImageWithColor(UIColor.blackColor())
            marker.map = mapView
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13.8, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }

    func addLocationPoint(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(placeDetails!["lat"]! as! NSNumber), CLLocationDegrees(placeDetails!["long"]! as! NSNumber)))

        marker.title = "\(placeDetails!["name"]!)"
        marker.icon = GMSMarker.markerImageWithColor(UIColor.googleBlue())
        marker.map = mapView
        print("Plotted interest point")
    }
    
    func addArtificialPoint(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(artificial.latitude!), CLLocationDegrees(artificial.longitude!)))
        
        marker.icon = UIImage(named: "noise")
        
        if artificial.generalised_building != nil {
            marker.title = "Discretized to \(artificial.generalised_building!)"
        }
        else {
            marker.title = "Artificial location"
        }
        
        marker.map = mapView
        
        let circle = GMSCircle(position: CLLocationCoordinate2DMake(CLLocationDegrees(artificial.latitude!), CLLocationDegrees(artificial.longitude!)), radius: 1000)
        circle.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        circle.strokeWidth = 2
        circle.strokeColor = UIColor.googleBlue()
        circle.map = mapView
        
        print("Plotted artificial location")
    }
    

}