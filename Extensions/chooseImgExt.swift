//
//  chooseImgExt.swift
//  UniMarket
//
//  Created by Sten Golds on 3/5/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit

extension ChooseImageAction where Self: UIViewController  {
    
    
    /**
     * @name ChooseImage
     * @desc when called this function opens an action sheet allowing the user edit the post image
     * by choosing 1. upload a photo from camera roll, 2. take a photo, 3. cancel decision to edit the post image
     * if 1 or 2 is selected, presents the imagePicker
     * @param Any sender - the sender of the action
     * @return void
     */
    func chooseImage(ForView sender: Any) {
        //initialize the action sheet controller
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //add action for choosing a photo from the camera roll
        let chooseAction: UIAlertAction = UIAlertAction(title: "Choose Picture", style: .default) { action -> Void in
            
            //set the source for the imagePicker to camera roll, and disable editing
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            
            //present the imagePicker
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(chooseAction)
        
        //add action for taking a new photo
        let takeAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .default) { action -> Void in
            
            //set the source for the imagePikcer to camera
            self.imagePicker.sourceType = .camera
            
            //present the imagePicker
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(takeAction)
        
        //add the cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //dismiss action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //present the action sheet as a popover
        actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
        present(actionSheetController, animated: true, completion: nil)
    }
}
