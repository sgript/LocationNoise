//
//  UINavigationController.swift
//  LocationPrivacy
//
//  Created by sgript on 08/02/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import UIKit


class UINavigationController: UIViewController {
    var statusBarStyle: UIStatusBarStyle

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
}
