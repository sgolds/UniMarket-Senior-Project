//
//  Constants.swift
//  UniMarket
//
//  Created by Sten Golds on 2/17/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit

//keys
let KEY_USER_EMAIL = "user email"

//colors
let GRAY_SHADOW: CGFloat = 120.0 / 255.0
let COMMON_BLUE = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
let COMMON_GRAY = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
let DARK_BLUE_FONT = UIColor(red: 55.0/255.0, green: 71.0/255.0, blue: 79.0/255.0, alpha: 1.0)

//segues
let LOGGED_IN_SEGUE = "loggedIn"
let AFTER_SIGNED_UP_SEGUE = "toLoginPostSign"
let DISPLAY_ITEM_POST_SEGUE = "toItemDisplay"
let CREATE_ACCOUNT_SEGUE = "toSignUp"
let SHOW_USER_POST = "toShowUserPost"
let CONTACT_SEGUE = "toContact"
let VIEW_MESSAGE_SEGUE = "toViewMessage"
