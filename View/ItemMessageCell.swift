//
//  ItemMessageCell.swift
//  UniMarket
//
//  Created by Sten Golds on 4/14/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class ItemMessageCell: UITableViewCell {

    //references to the ItemMessageCell created in storyboard
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    //variable used to store the associated message
    var message: ItemMessage!

    /**
     * @name configCell
     * @desc configures the ItemMessageCell with the data from the associated post
     * @param ItemMessage message - message of which this ItemMessageCell will represent
     * @return void
     */
    func configCell(message: ItemMessage) {
        
        //set ItemMessageCell post to passed in Post
        self.message = message
        
        
        //set message title and message preview labels
        self.titleLabel.text = "RE: " + message.postTitle
        self.messageLabel.text = message.message
    }

}
