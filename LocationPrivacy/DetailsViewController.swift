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
    //@IBOutlet weak var placeIcon: UIImageView!
    //var placeIcon: UIImageView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeDesc: UITextView!
    
    
    let locationManager = CLLocationManager()
    var placeDetails: [String: AnyObject]?
    
    override func viewDidLoad() {
        print("In details view controller")
        print("\(placeDetails)")
        super.viewDidLoad()
        getImage()
        displayDetails()
        
        
        //self.placeIcon.hidden = true // Fix later
        //scrollView.contentSize.height = 1000
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("DetailsVC")


    }
    
    func displayDetails(){
        self.placeTitle.text = "\(placeDetails!["name"]!)"
        let milesFromReal = String(format:"%.1f", placeDetails!["distance"]! as! Float)
        let artificialLocation = CLLocation(latitude: artificial.latitude!, longitude: artificial.longitude!)
        let locationSearched = CLLocation(latitude: placeDetails!["lat"]! as! Double, longitude: placeDetails!["long"]! as! Double)
        let distance = (artificialLocation.distanceFromLocation(locationSearched) / 1000) * 0.62137
        let milesFromArt = String(format:"%.1f", distance)
        self.placeDesc.text = "Area: \(placeDetails!["vicinity"]!)\nRating: \(placeDetails!["rating"]!)\nDistance from real location:\(milesFromReal)\nGoogle thinks you are \(milesFromArt) away from \(self.placeTitle.text!)"
    }
    
    func getImage() {
        if placeDetails != nil {
            Alamofire.request(.GET, "\(placeDetails!["icon"]!)")
                .responseImage { response in
                    debugPrint(response)
                    
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)
                    
                    if let image = response.result.value {
                        

//                        let size = CGSize(width: 71.0, height: 71.0)
//                        let scaledImage = image.af_imageScaledToSize(size)
//                        print("image downloaded: \(scaledImage)")
                        
                        let newSize = CGSizeMake(CGFloat(35.0), CGFloat(35.0))
                        UIGraphicsBeginImageContext(newSize)
                        image.drawInRect(CGRectMake(0, 0, CGFloat(35.0), CGFloat(35.0)))
                        let newImg = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()

                        //self.placeIcon.image = newImg
                    }
                }
        }
    
    }
    
    
}

extension DetailsViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("debug1")
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            print("debug2")
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
                
            addLocationPoint()
            addArtificialPoint()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13.8, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    // CLLocationDegrees(placeDetails!["lat"]!)
    func addLocationPoint(){
        print("startLocationPoint")
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(placeDetails!["lat"]! as! NSNumber), CLLocationDegrees(placeDetails!["long"]! as! NSNumber)))

        //marker.icon = self.placeIcon.image
        marker.title = "\(placeDetails!["name"]!)"
        marker.map = mapView
        print("finishedAddLocationPoint")
    }
    
    func addArtificialPoint(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(CLLocationDegrees(artificial.latitude!), CLLocationDegrees(artificial.longitude!)))
        
        marker.icon = UIImage(named: "noise")
        marker.title = "Artificial location"
        marker.map = mapView
        
        let circle = GMSCircle(position: CLLocationCoordinate2DMake(CLLocationDegrees(artificial.latitude!), CLLocationDegrees(artificial.longitude!)), radius: 1000)
        circle.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        circle.strokeWidth = 2
        circle.strokeColor = UIColor.googleBlue()
        circle.map = mapView
        print("finishedAddArtificialPoint")
    }
    

}