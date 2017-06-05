//
//  ItemMessage.swift
//  UniMarket
//
//  Created by Sten Golds on 4/13/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation

/**
 * @name ItemMessage
 * @desc class created for message objects associated with a post
 */
class ItemMessage {
    
    //private ItemMessage object properties
    private var _postTitle: String!
    private var _senderID: String!
    private var _senderEmail: String!
    private var _message: String!
    private var _messKey: String!
    
    
    //public message object property getters, so code outside this class code cannot change the properties
    var senderID: String {
        return _senderID
    }
    
    var postTitle: String {
        return _postTitle
    }
    
    var senderEmail: String {
        return _senderEmail
    }
    
    var message: String {
        return _message
    }
    
    var messKey: String {
        return _messKey
    }
    
    
    //initialize the message object using Dictionary<String, AnyObject>
    init(dictionary: Dictionary<String, AnyObject>) {
        
        //if statements below perform the following:
        // 1. check if dictionary has a value of the correct type for a specified Message property
        // 2. if dictionary has a value for the Message property, set the private property variable to the value from the dictionary
        
        if let senderID = dictionary["senderID"] as? String {
            self._senderID = senderID
        }
        
        if let postTitle = dictionary["postTitle"] as? String {
            self._postTitle = postTitle
        }
        
        if let senderEmail = dictionary["senderEmail"] as? String {
            self._senderEmail = senderEmail
        }
        
        if let message = dictionary["message"] as? String {
            self._message = message
        }
        
        if let messKey = dictionary["messKey"] as? String {
            self._messKey = messKey
        }
        
    }
    
    
}
