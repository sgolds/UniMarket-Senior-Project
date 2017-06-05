//
//  MaterialPopUpView.swift
//  UniMarket
//
//  Created by Sten Golds on 3/22/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

@IBDesignable
class MaterialPopUpView: UIView {

    override func awakeFromNib() {
        
        //create a shadow for the view, as well as round the view's corners
        layer.shadowColor = UIColor(red: GRAY_SHADOW, green: GRAY_SHADOW, blue: GRAY_SHADOW, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 4.0
    }

}
