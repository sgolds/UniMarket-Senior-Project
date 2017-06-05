//
//  tvExt.swift
//  UniMarket
//
//  Created by Sten Golds on 4/14/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    /**
     * @name adjustInsetsToMargin
     * @desc makes left margin for text view aligned to the frame left bound
     * @return void
     */
    func adjustInsetsToMargin() {
        self.textContainerInset = .zero
        self.contentInset = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
    }
}
