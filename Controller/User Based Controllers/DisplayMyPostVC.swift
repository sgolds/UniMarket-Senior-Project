//
//  DisplayMyPostVC.swift
//  UniMarket
//
//  Created by Sten Golds on 3/7/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class DisplayMyPostVC: UIViewController {
    
    //references to label, text view, and image view in storyboard
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptTV: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    //variable for the post being shown
    var post: ItemPost!
    var image: UIImage?


    override func viewDidLoad() {
        super.viewDidLoad()

        //set labels and text view with associated post attributes
        titleLbl.text = post.title
        descriptTV.text = post.description
        
        //adjust margins of text view
        descriptTV.adjustInsetsToMargin()
        
        //if post has an image, set imageView image to post image
        if let image = image {
            imageView.image = image
        }
    }
    

}
