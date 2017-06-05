//
//  DataService.swift
//  UniMarket
//
//  Created by Sten Golds on 2/16/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import Firebase



class DataService {
    //singleton instance for dataservice
    static let ds = DataService()
    
    //References for firebase database
    private var _REF_BASE = FIRDatabase.database().reference()
    private var _POST_REF = FIRDatabase.database().reference().child("posts")
    private var _USERS_REF = FIRDatabase.database().reference().child("users")
    private var _CONTACT_REF = FIRDatabase.database().reference().child("contact")
    
    //References for firebase storage
    private var _STORAGE_REF = FIRStorage.storage().reference(forURL: storageUrl)
    private var _IMAGES_REF = FIRStorage.storage().reference(forURL: storageUrl).child("images")
    private var _USER_PROF_IMAGES_REF = FIRStorage.storage().reference(forURL: storageUrl).child("images").child("users")
    private var _POSTS_IMAGES_REF = FIRStorage.storage().reference(forURL: storageUrl).child("images").child("posts")
    
    //User profile picture
    private var _profilePic: UIImage?

    //getters for private variables
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var POST_REF: FIRDatabaseReference {
        return _POST_REF
    }
    
    var USERS_REF: FIRDatabaseReference {
        return _USERS_REF
    }
    
    var CONTACT_REF: FIRDatabaseReference {
        return _CONTACT_REF
    }
    
    var STORAGE_REF: FIRStorageReference {
        return _STORAGE_REF
    }
    
    var IMAGES_REF: FIRStorageReference {
        return _IMAGES_REF
    }
    
    var POSTS_IMAGES_REF: FIRStorageReference {
        return _POSTS_IMAGES_REF
    }
    
    var profilePic: UIImage? {
        return _profilePic
    }
    
    /**
     * @name createFirebaseUser
     * @desc creates a new user in firebase
     * @param String uid - the id used to store the user in firebase
     * @param Dictionary<String, String> user - the dictionary to set user value to
     * @return void
     */
    func createFirebaseUser(uid: String, user: Dictionary<String, Any>) {
        //create user with ID of uid and value of user in the USERS_REF area of firebase
        USERS_REF.child(uid).setValue(user)
    }
    
    /**
     * @name updateUserPosts
     * @desc adds a post to the user's dictionary of post they have created
     * @param String postId - the id used to store the post in firebase
     * @return void
     */
    func updateUserPosts(postId: String) {
        if let currUser = FIRAuth.auth()?.currentUser { //if there is a current user, get it
            
            //get user uid so user can be located and updated in firebase
            let currUid = currUser.uid
            
            //add postId to user's post array dictionary
            USERS_REF.child(currUid).child("Posts").child(postId).setValue(true)
            
        }
    }
    
    /**
     * @name updateUserPosts
     * @desc adds a post to the user's dictionary of post they have created
     * @param String postId - the id used to store the post in firebase
     * @return void
     */
    func updateUserMessages(userID: String, messageID: String) {
        
        //add postId to user's post array dictionary
        USERS_REF.child(userID).child("Messages").child(messageID).setValue(true)
    }
    
    /**
     * @name postImageToStorage
     * @desc uploads given picture with given string for name to firebase
     * @param UIImage image - the image to upload
     * @param String name - the name for the image .jpg, should be PostKey
     * @return void
     */
    func postImageToStorage(image: UIImage, name: String) {
        
        if let data: Data = UIImageJPEGRepresentation(image, 0.2) { //if image was successfully converted to JPEG rep continue to upload
            
            // Create a reference to the file you want to upload
            let imgRef = DataService.ds._IMAGES_REF.child("posts").child(name + ".jpg")
            
            // Upload the file to the path for name
            imgRef.put(data, metadata: nil) { metadata, error in
                
                //if there was an error, show that the associated post does not have an image
                //else tell the tableView displaying posts that a new image has been uploaded for a post, and to reload
                if(error != nil) {
                    DataService.ds._POST_REF.child(name).updateChildValues(["hasImg": false])
                    
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadTable"), object: nil)
                }
                
            }
        }
    }
    
    /**
     * @name changeProfilePicture
     * @desc uploads chosen user profile picture to firebase, then overrides user
     * profile image URL data so the new image is associated with the user
     * @param UIImage image - the image to become the new profile picture
     * @return void
     */
    func changeProfilePicture(image: UIImage) {
        if let user = FIRAuth.auth()?.currentUser { //if there is a current user, get it
            
            //get user uid to use for picture .jpg name
            let picName = user.uid
            
            if let data: Data = UIImageJPEGRepresentation(image, 0.2) { //if image was successfully converted to JPEG rep continue to upload
                
                // Create a reference to the file you want to upload
                let imgRef = DataService.ds._USER_PROF_IMAGES_REF.child(picName + ".jpg")
                
                
                // Upload the file to the path "images/users/(user uid).jpg"
                imgRef.put(data, metadata: nil) { metadata, error in
                    
                    //if there was an error, print it
                    if(error != nil) {
                        print(error!.localizedDescription)
                    } else {
                        //add url to download photo to user object
                        imgRef.downloadURL(completion: { (url, error) in
                            if let url = url {
                                //add username to profile
                                let changeRequest = user.profileChangeRequest()
                                
                                changeRequest.photoURL = url
                                changeRequest.commitChanges { error in
                                    if(error != nil) {
                                        print("Error adding photo url name")
                                    } else {
                                        print("Display name added")
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    /**
     * @name getProfilePic
     * @desc Get associated user profile picture, and set dataservice profile picture to user picture
     * @param FIRUser user - Firebase user to retrieve profile picture of
     * @return void
     */
    func getProfilePic(user: FIRUser) {
        if let user = FIRAuth.auth()?.currentUser { //get current user, continue on success

            if let imageUrl = user.photoURL { //get user's profile image URL, continue on success
                
                //create database reference where the image is stored
                let ref = FIRStorage.storage().reference(forURL: imageUrl.absoluteString)
                
                //download user's profile image
                ref.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Image successfully downloaded")
                        
                        //if image data was downloaded successfully
                        //convert data to UIImage and set the profile ImageView to display the downloaded image
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self._profilePic = img
                            }
                        }
                    }
                })
            }
        }
    }
    
    /**
     * @name handleFBError
     * @desc investigates the reason for the error, and displays an alert informing the user of the error
     * @param Error error - error to handle
     * @return void
     */
    func handleFBError(error: Error) -> String? {
        
        if let eCode = FIRAuthErrorCode(rawValue: error._code) { //get the error code, needed in order to investigate meaning of error
            //string to display desired message
            var message = ""
            
            
            switch (eCode) { //switch statement to check if the error is one of the commonplace errors we expect to see
            case .errorCodeInvalidEmail: //if error is invalid email, set error message to inform of invalid email and break switch statement
                message = "Invalid email address"
                break
            case .errorCodeWrongPassword: //if error is wrong password, set error message to inform of wrong password and break switch statement
                message = "Invalid password"
                break
            case .errorCodeEmailAlreadyInUse, .errrorCodeAccountExistsWithDifferentCredential: //if error includes already in use email, set error message to inform of includes already in use email and break switch statement; additionally the 3 r's in second clause are in line with Firebase's code
                message = "Email already in use"
                break
            case .errorCodeUserNotFound: //if error is user not found, set error message to inform of user not found and break switch statement
                message = "User not found"
                break
            default: //if error is not one of the one's tested for, inform user that there was a problem and to try again
                message = "Problem with authentication. Try again."
            }
            
            return message
        }
        
        return nil
    }
}
