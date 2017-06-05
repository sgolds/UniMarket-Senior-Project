//
//  vcExt.swift
//  UniMarket
//
//  Created by Sten Golds on 2/16/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /**
     * @name showErrorAlert
     * @desc shows error alert with provided info, eliminates repeating code to display alerts
     * @param String title - title for alert
     * @param String msg - message for alert
     * @return void
     */
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
