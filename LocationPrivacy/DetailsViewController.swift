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

class DetailsViewController: UIViewController {
    @IBOutlet weak var placeIcon: UIImageView!
    var placeDetails: [String: AnyObject]?
    
    override func viewDidLoad() {
        print("In details view controller")
        super.viewDidLoad()
        displayDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("DetailsVC")
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
                        
//                        let newSize = CGSizeMake(CGFloat(35.0), CGFloat(35.0))
//                        UIGraphicsBeginImageContext(newSize)
//                        image.drawInRect(CGRectMake(0, 0, CGFloat(35.0), CGFloat(35.0)))
//                        let newImg = UIGraphicsGetImageFromCurrentImageContext()
//                        UIGraphicsEndImageContext()
//
                        self.placeIcon.image = image
                    }
                }
        }
            
    }
    
}
