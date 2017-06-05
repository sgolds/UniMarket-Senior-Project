//
//  ProfileVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/18/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    //references to the labels and image view in storyboard
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    //initialize imagePicker, Bool to toggle if the user selected an image or not
    //and Bool for if the profile image is loaded
    var imagePicker = UIImagePickerController()
    var imageSelected = false
    var imageLoaded = false
    
    //variable to store user's profile image
    var userImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = FIRAuth.auth()?.currentUser { //get current user, continue on success
            
            //set email label to user's email
            self.emailLabel.text = user.email
            
            //get display name
            if let name = user.displayName {
                self.nameLabel.text = name
            }
            
            //get user image, loaded on app bootup or user sign in
            if let dsImg = DataService.ds.profilePic {
                self.profilePicture.image = dsImg
                self.imageLoaded = true
            }
        }
    }
    
    
    
    /**
     * @name signOutPressed
     * @desc sign out the user
     * @param AnyObject sender - the sender of the action
     * @return void
     */
    @IBAction func signOutPressed(_ sender: Any) {
        do { //attempt to sign the user out
            try FIRAuth.auth()?.signOut() //app delegate will load the login view
        } catch {
            //if user could not be signed out, inform them of that
            showErrorAlert(title: "Could not sign out", msg: "Try again in a few minutes")
        }
    }
    

}
