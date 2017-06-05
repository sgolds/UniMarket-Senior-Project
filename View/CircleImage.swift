//
//  CircleImage.swift
//  UniMarket
//
//  Created by Sten Golds on 3/31/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {

    override func layoutSubviews() {
        //make each corner half the length of the image, therefore creating a circular image
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
