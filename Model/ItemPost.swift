//
//  ItemPost.swift
//  UniMarket
//
//  Created by Sten Golds on 2/17/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import Firebase

/**
 * @name ItemPost
 * @desc class created for post objects of style item
 */
class ItemPost {
    
    //private ItemPost object properties
    private var _time: Int!
    private var _flaggedAmount: Int!
    private var _hasImg: Bool!
    private var _title: String!
    private var _category: String!
    private var _schoolId: String!
    private var _posterId: String!
    private var _description: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    
    //public Post object property getters, so code outside this class code cannot change the properties
    var time: Int {
        return _time
    }
    
    var flaggedAmount: Int {
        return _flaggedAmount
    }
    
    var hasImg: Bool {
        return _hasImg
    }
    
    var title: String {
        return _title
    }
    
    var category: String {
        return _category
    }
    
    var schoolId: String {
        return _schoolId
    }
    
    var posterId: String {
        return _posterId
    }
    
    var description: String {
        return _description
    }
    
    var postKey: String {
        return _postKey
    }
    
    
    //initialize the Post object using Dictionary<String, AnyObject>
    init(dictionary: Dictionary<String, AnyObject>) {
        
        //if statements below perform the following:
        // 1. check if dictionary has a value of the correct type for a specified Post property
        // 2. if dictionary has a value for the Post property, set the private property variable to the value from the dictionary
        if let time = dictionary["time"] as? Int {
            self._time = time
        }
        
        if let flagged = dictionary["flagged"] as? Int {
            self._flaggedAmount = flagged
        }
        
        if let title = dictionary["title"] as? String {
            self._title = title
        }
        
        if let category = dictionary["category"] as? String {
            self._category = category
        }
        
        if let schoolId = dictionary["schoolId"] as? String {
            self._schoolId = schoolId
        }
        
        if let posterId = dictionary["posterID"] as? String {
            self._posterId = posterId
        }
        
        if let desc = dictionary["description"] as? String {
            self._description = desc
        }
        
        if let hasImg = dictionary["hasImg"] as? Bool {
            self._hasImg = hasImg
        }
        
        if let postKey = dictionary["postKey"] as? String {
            self._postKey = postKey
            
            //set postRef for the Post object to the reference for the postKey value in the posts section of the firebase database
            self._postRef = DataService.ds.POST_REF.child(self.postKey)
        }
        
    }
    
    /**
     * @name adjustFlagged
     * @desc adjusts number of flags on the post
     * @param Bool addFlagged - for whether a flag is added or removed
     * @return void
     */
    func adjustFlagged(addFlagged: Bool) {
        
        if addFlagged {
            _flaggedAmount = _flaggedAmount + 1
        } else {
            _flaggedAmount = _flaggedAmount - 1
        }
        
        _postRef.child("flagged").setValue(_flaggedAmount)
    }
    
    
}
