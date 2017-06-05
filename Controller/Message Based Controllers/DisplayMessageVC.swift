//
//  DisplayMessageVC.swift
//  UniMarket
//
//  Created by Sten Golds on 4/14/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class DisplayMessageVC: UIViewController {

    @IBOutlet var messTitleTF: UILabel!
    @IBOutlet var emailTF: UILabel!
    @IBOutlet var messageTV: UITextView!
    
    
    //variable for the message being shown
    var message: ItemMessage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set labels with associated message attributes
        messTitleTF.text = "RE: " + message.postTitle
        emailTF.text = message.senderEmail
        
        //set text view with associated message attribute
        messageTV.text = message.message
        
        //adjust margins of text view
        messageTV.adjustInsetsToMargin()
    }

}
