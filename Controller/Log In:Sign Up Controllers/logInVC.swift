//
//  logInVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/16/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase
import Material

class logInVC: UIViewController {

    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set TextField tints to white
        emailTF.setColorTints(color: .white)
        passwordTF.setColorTints(color: .white)
        
        //if the application has a user's email associated with this device
        //i.e. if the user created an account on this device
        //get the email and fill in the email TextField, so the user does not need to type in their email
        if let email = UserDefaults.standard.value(forKey: KEY_USER_EMAIL) as? String {
            self.emailTF.text = email
        }
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
    }
    

    /**
     * @name logInPressed
     * @desc logs the user in, is connected to the log in button in the storyboard
     * @param AnyObject sender - sender of the action
     * @return void
     */
    @IBAction func logInPressed(sender: AnyObject) {
        
        
        if let email = emailTF.text, email != "", let pwd = passwordTF.text, pwd != "" { //continues if user has entered information into the email and password TextFields
            
            //signs in with the user provided email and password
            FIRAuth.auth()!.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                
                if error != nil { //if error occurs, display alert to inform user an error has occured
                    if let msg = DataService.ds.handleFBError(error: error!) {
                        self.showErrorAlert(title: "Error", msg: msg)
                    }
                } else { //if no error has occured, segue to logged in portion of the app
                    
                    if let loggedUser = user {
                        if loggedUser.isEmailVerified {
                            
                            //saved logged in users email for easy re-login
                            UserDefaults.standard.setValue(email, forKey: KEY_USER_EMAIL)
                            
                            //continue to main app
                            self.performSegue(withIdentifier: LOGGED_IN_SEGUE, sender: nil)
                        } else {
                            
                            //send verification email
                            loggedUser.sendEmailVerification(completion: { (error) in
                                if error != nil {
                                    self.showErrorAlert(title: "Email Not Verified", msg: "Your email is not verified, and we are having an error sending a verificaiton email. Please try again.")
                                } else {
                                    self.showErrorAlert(title: "Email Not Verified", msg: "Your email address is not verified. We have sent a verification email to the provided address.")
                                }
                            })
                        }
                    }
                }
                
            })
        } else {
            //if the user did not provide an email/password show an alert telling them it is required
            showErrorAlert(title: "Email and Password Required", msg: "Must enter email/password")
        }
    }
}
