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

class DetailsViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var placeIcon: UIImageView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var placeDetails: [String: AnyObject]?
    
    override func viewDidLoad() {
        print("In details view controller")
        super.viewDidLoad()
        displayDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("DetailsVC")
        
        scrollView.contentSize.height = 1000
    }
    
    
    func displayDetails() {
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
//
                        self.placeIcon.image = image
                    }
                }
        }
        
        self.placeTitle.text = "\(placeDetails!["name"]!)"
            
    }
    
//    override func loadView() {
//        let camera = GMSCameraPosition.cameraWithLatitude(1.285, longitude: 103.848, zoom: 12)
//        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
//        self.view = mapView
//    }
    
}
