//
//  ContactVC.swift
//  UniMarket
//
//  Created by Sten Golds on 4/13/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Material
import Firebase

class ContactVC: UIViewController, UITextViewDelegate {
    
    //references to text views in storyboard
    @IBOutlet var emailTF: TextField!
    @IBOutlet weak var messageTV: UITextView!
    
    //associated post
    var post: ItemPost!
    
    //variables for the activity indicator, and current user
    var activityInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var currentUser: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set default contact email to current user's email
        if let user = FIRAuth.auth()?.currentUser {
            currentUser = user
            emailTF.text = user.email!
        }
        
        //make ContactVC delegate for messageTV, adjust the TextView margins
        //and do initial call to tvEditingHelper to set the TextView with the placeholder text
        messageTV.delegate = self
        messageTV.adjustInsetsToMargin()
        tvEditingHelper(editing: false)
        
        //add toolbar with dismiss button to messageTV
        toolBarSetUp()
        
        //add activity indicator used to show progress of sending a message
        addActivityInd()
    }
    
    /**
     * @name toolBarSetUp
     * @desc create and setup toolbar for TextView keyboard
     * @return void
     */
    func toolBarSetUp() {
        //toolbar for TextView
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.backgroundColor = COMMON_GRAY
        toolBar.tintColor = COMMON_BLUE
        toolBar.sizeToFit()
        
        //done button for TextView toolbar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ContactVC.donePressed))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        //add done button and toolbar to TextView
        messageTV.inputAccessoryView = toolBar
    }
    
    /**
     * @name addActivityInd
     * @desc add activity indicator to view, used for progress of post upload
     * @return void
     */
    func addActivityInd() {
        //center the activity indicator in view, make it only visible when running, and set its style to large and white
        activityInd.center = self.view.center
        activityInd.hidesWhenStopped = true
        activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityInd.color = COMMON_BLUE
        
        //add activity indicator to view
        view.addSubview(activityInd)
    }
    
    /**
     * @name tvEditingHelper
     * @desc resign TextView keyboard when done on toolbar is pressed
     * @return void
     */
    func donePressed() {
        messageTV.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //call helper method function, letting it know the user is currently editing the TextView
        tvEditingHelper(editing: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //call helper method function, letting it know the user is not currently editing the TextView
        tvEditingHelper(editing: false)
    }
    
    /**
     * @name tvEditingHelper
     * @desc adjusts TextView colors based on if there is user inputed text in the TextView or not
     * @param Bool editing - used to tell function if the user is editing the TextView
     * @return void
     */
    func tvEditingHelper(editing: Bool) {
        
        //run block if user is currently editing the TextView
        if editing {
            //checks if text in text view is currently a placeholder, if so clears textview, sets font color to
            //non-placeholder color, and tells app that the text is to be saved to the entry object
            if messageTV.textColor == UIColor.lightGray {
                messageTV.text = nil
                messageTV.textColor = DARK_BLUE_FONT
            }
        } else {
            //checks if there is currently no text in the view
            if messageTV.text.isEmpty {
                
                //Sets line spacing of paragraphs to 7; makes text color the placeholder color of light gray; adds placeholder text
                messageTV.text = "Type Here..."
                messageTV.textColor = .lightGray
            }
        }
    }

    // MARK: - Dimissal Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTF.resignFirstResponder()
        messageTV.resignFirstResponder()
    }

    /**
     * @name contactPressed
     * @desc send the user who created the post a message by creating a message object that will display in the
     * user's messages section
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func contactPressed(_ sender: Any) {
        if(emailTF.text != "" && messageTV.text != "") { //continue if user has entered a title and description
            
            //start activity indicator as firebase communication is beginning, disable user interaction
            self.activityInd.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            //get the email address
            let email = (emailTF.text != nil) ? emailTF.text! : ""
            
            //get the message text
            let message = (messageTV.text != nil) ? messageTV.text! : ""
            
            //create a firebase datatbase reference for the new message
            let refForNewMess = DataService.ds.CONTACT_REF.childByAutoId()
            
            //set messKey to the autoId created for the message reference
            let messKey = refForNewMess.key
            
            //create the dictionary that will represent the post in the database
            let messageDict: Dictionary<String, Any> = [
                "senderID": currentUser.uid,
                "postTitle": self.post.title,
                "senderEmail": email,
                "message": message,
                "messKey": messKey
            ]
            
            //save post to database
            refForNewMess.setValue(messageDict) { (error, dataRef) in
                if(error != nil) { //if there was an error saving post, display alert informing user
                    
                    //end activity indicator as firebase communication is finished, allow user interaction again
                    self.activityInd.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.showErrorAlert(title: "Message Not Sent", msg: "Your message could not be sent. Please try again later.")
                    
                } else {
                    //end activity indicator as firebase communication is finished, allow user interaction again
                    self.activityInd.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    //update the user's messages array to contain the new post
                    DataService.ds.updateUserMessages(userID: self.post.posterId, messageID: messKey)
                    
                    //return to post list/map view
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            //display to user that the contact requires a message and email
            showErrorAlert(title: "", msg: "")
        }

    }
    

}
