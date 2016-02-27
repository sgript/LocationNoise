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
//    var input = Int()

    @IBAction func slidedSlider(sender: UISlider) {
//        self.input = Int(sender.value)
        self.updateNumOfArtificialLocations.text = "\(Int(sender.value))"
    }
    
    @IBAction func beginAttack(sender: AnyObject) {
        self.performSegueWithIdentifier("reviewAttack", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "reviewAttack") {
            let reviewAttackVC = segue.destinationViewController as! ReviewAttackViewController

            reviewAttackVC.pointsToPlot = Int(self.updateNumOfArtificialLocations.text!)!
            
        }
    }
    
}
