//
//  signUpVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/16/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase
import Material

class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseImageAction {
    
    //text field and image view references to storyboard
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    @IBOutlet weak var firstNameTF: TextField!
    @IBOutlet weak var lastNameTF: TextField!
    @IBOutlet weak var chosenImage: UIImageView!
    
    //activity indicator variable
    var activityInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    //initialize imagePicker, Bool to toggle if the user selected an image or not
    var imagePicker = UIImagePickerController()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //textField active colors
        emailTF.setColorTints(color: COMMON_BLUE)
        passwordTF.setColorTints(color: COMMON_BLUE)
        firstNameTF.setColorTints(color: COMMON_BLUE)
        lastNameTF.setColorTints(color: COMMON_BLUE)
        
        //center the activity indicator in view, make it only visible when running, and set its style to large and white
        activityInd.center = self.view.center
        activityInd.hidesWhenStopped = true
        activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityInd.color = COMMON_BLUE
        
        //add activity indicator to view
        view.addSubview(activityInd)
        
        //make current VC the delegate to the image picker
        imagePicker.delegate = self
    }

    /**
     * @name touchesBegan
     * @desc overrides touchesBegan function in order to make the keyboard disappear if the user taps outside the keyboard
     * and TextField area
     * @param Set<UITouch> touches - set of touches by the user
     * @param UIEvent event - event associated with the touches
     * @return void
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
    }
    
    /**
     * @name signUpPressed
     * @desc signs up the user, is connected to the sign up button in the storyboard
     * @param AnyObject sender - sender of the action
     * @return void
     */
    @IBAction func signUpPressed(sender: AnyObject) {
        
        //get source for email, e.g. edu or com, will find more efficient way
        var emailSource = ""
        
        if let emailForTest = emailTF.text {
            let emailFTArr = emailForTest.components(separatedBy: ".")
            emailSource = emailFTArr[emailFTArr.count - 1] as String
        }
        
        
        //test if email is edu
        if emailSource != "edu" {
            
            self.showErrorAlert(title: "Email Error", msg: "Must use valid .edu email")
            
        } else if let email = emailTF.text, email != "", let pwd = passwordTF.text, pwd != "", let firstName = firstNameTF.text, firstName != "", let lastName = lastNameTF.text, lastName != "" { //continues if user has entered information into the email, password, first name, and last name TextFields
            
            //start activity indicator as firebase communication is beginning, disable user interaction
            self.activityInd.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            //create user in firebase authentication with the provided email and password
            FIRAuth.auth()!.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                
                if error != nil { //if error occurs, display alert to inform user an error has occured
                    if let msg = DataService.ds.handleFBError(error: error!) {
                        
                        //end activity indicator as firebase communication is finished, allow user interaction again
                        self.activityInd.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        self.showErrorAlert(title: "Error", msg: msg)
                    }
                } else {
                    //save the created accounts email, so it will show up at the log infor the user in the future
                    UserDefaults.standard.setValue(email, forKey: KEY_USER_EMAIL)
                    
                    //get current user
                    if let userSigned = user {
                        //starting info for the user that will be put into the firebase database
                        
                        let emailArr = email.components(separatedBy: "@")
                        let schoolId = emailArr[emailArr.count - 1] as String
                        
                        //create user as dictionary
                        let userToInput = ["provider": userSigned.providerID, "email": userSigned.email!, "displayName": firstName + " " + lastName, "schoolId": schoolId] as [String : Any]
                        
                        
                        //create user in the firebase database
                        DataService.ds.createFirebaseUser(uid: userSigned.uid, user: userToInput)
                        
                        //add user profile image, if one was given
                        if(self.imageSelected == true) {
                            if let image = self.chosenImage.image {
                                DataService.ds.changeProfilePicture(image: image)
                            }
                        }
                        
                        //add username to profile
                        let changeRequest = userSigned.profileChangeRequest()
                        
                        changeRequest.displayName = firstName + " " + lastName
                        changeRequest.commitChanges { error in
                            if(error != nil) {
                                print("Error adding display name")
                            } else {
                                print("Display name added")
                            }
                        }
                        
                        //send verification email
                        userSigned.sendEmailVerification(completion: { (error) in
                            
                            //variables to store message to display to user
                            var alertTitle = ""
                            var alertMessage = ""
                            
                            if error != nil {
                                
                                alertTitle = "Email Verification Send Error"
                                alertMessage = "Account made but verificaiton email not sent, on next login one will be sent."
                                
                            } else {
                                
                                alertTitle = "Verification Email Sent"
                                alertMessage = "Please check your email and click the provided link."
                    
                            }
                            
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            
                            //action to segue to log in portion of the app
                            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                                self.performSegue(withIdentifier: AFTER_SIGNED_UP_SEGUE, sender: nil)
                            }
                            
                            alert.addAction(action)
                            
                            //end activity indicator as firebase communication is finished, allow user interaction again
                            self.activityInd.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                    }
                }
                
            })
            
        } else {
            showErrorAlert(title: "Email and Password Required", msg: "Must enter email/password")
        }
        
    }
    
    /**
     * @name addImagePressed
     * @desc when user taps the change picture button this function opens an action sheet allowing the user edit their profile image
     * by choosing 1. upload a photo from camera roll, 2. take a photo, 3. cancel decision to edit the post image
     * if 1 or 2 is selected, presents the imagePicker
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func addImagePressed(_ sender: Any) {
        //call choose image function defined in ChooseImageAction
        //protocol and extension
        chooseImage(ForView: sender)
    }
    
    /**
     * @name backPressed
     * @desc move to previous controller when back button is pressed
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func backPressed(_ sender: Any) {
        //segue to start up portion of the app
        self.performSegue(withIdentifier: AFTER_SIGNED_UP_SEGUE, sender: nil)
    }
    

    /**
    * @name imagePickerController - didFinishPickingMediaWithInfo
    * @desc gets the chosen image, sets the profile picture to the selected image
    * and toggles the Bool to show an image has been selected, changes the user's profile image to the new image,
    * and finally dismisses the picker
    * @param UIImagePickerController picker - the image picker controller
    * @param [String : AnyObject] info - the media info selected
    * @return void
    */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //attempts to get a UIImage out of the selected media, continues if UIImage was successfully grabbed
        //sets profilePicture to the grabbed UIImage, and toggles imageSelected Bool to true
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.chosenImage.image = image
            self.imageSelected = true
        }
        
        //dismisses picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
    * @name imagePickerControllerDidCancel
    * @desc dismisses the image picker controller if the controller canceled
    * @param UIImagePickerController picker - the image picker controller
    * @return void
    */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePicker.dismiss(animated: true, completion: nil)
    }


}
