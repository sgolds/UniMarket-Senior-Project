//
//  customTabBarVC.swift
//  UniMarket
//
//  Created by Sten Golds on 3/31/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class customTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set tint color of tab items to the common blue color, but with less opacity
        self.tabBar.tintColor = COMMON_BLUE.withAlphaComponent(0.70)

        //set images for tab bar controller
        if let items = self.tabBar.items {
            items[0].image = #imageLiteral(resourceName: "posts icon")
            items[0].selectedImage = #imageLiteral(resourceName: "posts icon")
            
            items[1].image = #imageLiteral(resourceName: "profile icon")
            items[1].selectedImage = #imageLiteral(resourceName: "profile icon")
            
            items[2].image = #imageLiteral(resourceName: "my posts icon")
            items[2].selectedImage = #imageLiteral(resourceName: "my posts icon")
            
            items[3].image = #imageLiteral(resourceName: "messages icon")
            items[3].selectedImage = #imageLiteral(resourceName: "messages icon")
        }
        
    }

}
