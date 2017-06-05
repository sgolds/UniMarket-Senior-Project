//
//  CreatePostVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/18/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase
import Material

class CreatePostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseImageAction, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //text field and image view references to storyboard
    @IBOutlet weak var titleTF: TextField!
    @IBOutlet weak var categoryTF: TextField!
    @IBOutlet weak var descriptionTF: TextField!
    @IBOutlet weak var chosenImage: UIImageView!
    
    //activity indicator variable
    var activityInd: UIActivityIndicatorView = UIActivityIndicatorView()
    var currentUser: FIRUser!
    
    //data for pickerView filter input (categoryTF)
    var categories = ["Books", "Electronics", "Clothing", "Home/Appliances", "Sports/Outdoors", "Misc"]
    
    //initialize imagePicker, Bool to toggle if the user selected an image or not
    var imagePicker = UIImagePickerController()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if there is a current user, get it
        if let user = FIRAuth.auth()?.currentUser {
            currentUser = user
        }
        
        //textField tints set to common blue
        titleTF.setColorTints(color: COMMON_BLUE)
        categoryTF.setColorTints(color: COMMON_BLUE)
        descriptionTF.setColorTints(color: COMMON_BLUE)
        
        //call method to create picker view for category selection
        createPickerView()
        
        //add the activity indicator used to show progress of adding a post
        addActivityInd()
        
        imagePicker.delegate = self
    }
    
    
    // MARK: - Dimissal Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTF.resignFirstResponder()
        descriptionTF.resignFirstResponder()
        categoryTF.resignFirstResponder()
    }
    
    /**
     * @name donePicker
     * @desc dismiss picker view, using books as default category at the start
     * @return void
     */
    func donePicker() {
        if categoryTF.text! == "" {
            categoryTF.text = "Books"
        }
        categoryTF.resignFirstResponder()
    }
    
    /**
     * @name postPressed
     * @desc create a new post, if proper requirements of a post are provided
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func postPressed(_ sender: Any) {
        
        if(descriptionTF.text != "" && titleTF.text != "") { //continue if user has entered a title and description
            
            //start activity indicator as firebase communication is beginning, disable user interaction
            self.activityInd.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            //get the description
            let descriptText = (descriptionTF.text != nil) ? descriptionTF.text! : ""
            
            //get the title
            let title = (titleTF.text != nil) ? titleTF.text! : ""
            
            //get category
            let category = (categoryTF.text != nil) ? categoryTF.text! : ""
            
            //create a firebase datatbase reference for the new post
            let refForNewPost = DataService.ds.POST_REF.childByAutoId()
            
            //set postKey to the autoId created for the post reference
            let postKey = refForNewPost.key
            
            //create the dictionary that will represent the post in the database
            let post: Dictionary<String, Any> = [
                "title": title,
                "category": category,
                "hasImg": imageSelected,
                "time": Int(NSDate().timeIntervalSince1970), //current time since 1970
                "description": descriptText,
                "flagged": 0, //initially 0
                "schoolId": "sandiego.edu",
                "posterID": currentUser.uid,
                "postKey": postKey
            ]
            
            //save post to database
            refForNewPost.setValue(post) { (error, dataRef) in
                if(error != nil) { //if there was an error saving post, display alert informing user
                    
                    //end activity indicator as firebase communication is finished, allow user interaction again
                    self.activityInd.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    self.showErrorAlert(title: "Post Not Saved", msg: "Your post could not be saved. Please try again later.")
                } else {
                    
                    //add user post image, if one was given, changes hasImg property to false if upload fails
                    if(self.imageSelected == true) {
                        if let image = self.chosenImage.image {
                            DataService.ds.postImageToStorage(image: image, name: postKey)
                        }
                    }
                    
                    //end activity indicator as firebase communication is finished, allow user interaction again
                    self.activityInd.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    //update the user's posts array to contain the new post
                    DataService.ds.updateUserPosts(postId: postKey)
                    
                    //return to post list/map view
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            //display to user that the post requires both a title and description
            showErrorAlert(title: "Post requires a title and description", msg: "")
        }

        
    }
    
    // MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTF.text = categories[row]
    }
    
    /**
     * @name createPickerView
     * @desc create picker view for choosing a category of post
     * @return void
     */
    func createPickerView() {
        //pickerView and input for filter
        let filterPicker = UIPickerView()
        filterPicker.delegate = self
        filterPicker.backgroundColor = COMMON_GRAY
        filterPicker.selectRow(0, inComponent: 0, animated: true)
        
        //toolbar for pickerView
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.backgroundColor = COMMON_GRAY
        toolBar.tintColor = COMMON_BLUE
        toolBar.sizeToFit()
        
        //done button for pickerView toolbar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PostListVC.donePicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        //add pickerView as input to filter textField
        categoryTF.inputView = filterPicker
        categoryTF.inputAccessoryView = toolBar
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
     * @name chooseImgPressed
     * @desc action to allow user to choose an image
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func chooseImgPressed(_ sender: Any) {
        //call choose image function defined in ChooseImageAction
        //protocol and extension
        chooseImage(ForView: sender)
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
