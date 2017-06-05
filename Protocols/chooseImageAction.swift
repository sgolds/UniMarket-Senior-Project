//
//  chooseImageAction.swift
//  UniMarket
//
//  Created by Sten Golds on 3/5/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit

protocol ChooseImageAction: class {
    
    //requirement variables for chooseImage function to work properly
    var imagePicker: UIImagePickerController { get set }
    var imageSelected: Bool { get set }
    
    //requirement variables for viewing image chosen
    weak var chosenImage: UIImageView! { get set }
    
    //function that allows user to choose an image, whether from camera roll or by taking one with the camera
    //further defined in chooseImageExt.swift in Extenstions group
    func chooseImage(ForView sender: Any)
    
}
