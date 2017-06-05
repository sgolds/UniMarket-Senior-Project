//
//  textFieldExt.swift
//  UniMarket
//
//  Created by Sten Golds on 4/24/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit
import Material

extension TextField {
    
    /**
     * @name setColorTints
     * @desc adjusts the placeholder and divider color of the TextField
     * @return void
     */
    func setColorTints(color: UIColor) {
        self.placeholderActiveColor = color
        self.dividerActiveColor = color
    }
}
