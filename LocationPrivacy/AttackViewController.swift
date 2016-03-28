//
//  AttackViewController.swift
//  LocationPrivacy
//
//  Created by sgript on 27/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit

class AttackViewController: UIViewController {
    @IBOutlet weak var updateNumOfArtificialLocations: UILabel!
    @IBOutlet weak var beginImmobileAttack: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var beginMobileAttack: UIButton!
    @IBOutlet weak var information: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginMobileAttack.hidden = true
    }
    
    
    @IBAction func slidedSlider(sender: UISlider) {
        self.updateNumOfArtificialLocations.text = "\(Int(sender.value))"
    }
    
    @IBAction func beginAttack(sender: AnyObject) {
        self.performSegueWithIdentifier("reviewAttack", sender: self)
    }
    
    @IBAction func beginMobileAttack(sender: AnyObject) {
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "reviewAttack") {
            let reviewAttackVC = segue.destinationViewController as! ReviewAttackViewController

            reviewAttackVC.pointsToPlot = Int(self.updateNumOfArtificialLocations.text!)!
        }
        
        if (segue.identifier == "mobileAttack") {
            //let mobileAttackVC = segue.destinationViewController
        }
        
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
            case 0:
                beginMobileAttack.hidden = true
                beginImmobileAttack.hidden = false
                information.text = "Immobile attacks will work under the constraints of having a fixed real location and create an artificial point using the user's real location with noise from 0 up to a fixed number of metres (100 for this demo)."
            
            case 1:
                beginImmobileAttack.hidden = true
                beginMobileAttack.hidden = false
                information.text = ""
            
            default:
                break
        }
    }
    
}
