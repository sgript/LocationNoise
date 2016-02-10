//
//  CustomTextField.swift
//  
//
//  Created by sgript on 08/02/2016.
//
//

import UIKit

public class CustomTextField: UITextField {
    
    @IBOutlet var nextField : UITextField?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: bounds.size.height))
        leftView = paddingView
        //leftViewMode = .Always
    }
    
}

public extension CustomTextField {
    
    func isEmpty() -> Bool {
        return text!.characters.count == 0
    }
    
}
