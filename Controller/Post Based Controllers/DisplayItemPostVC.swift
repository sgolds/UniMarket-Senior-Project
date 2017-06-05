//
//  DisplayItemPostVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/18/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class DisplayItemPostVC: UIViewController {

    
    //references to the label and text view in storyboard
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    //variable for the post being shown
    var post: ItemPost!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set labels to post associated post attributes
        titleLabel.text = post.title
        descriptionTV.text = post.description
        
        //adjust TextView margins
        descriptionTV.adjustInsetsToMargin()
        
        //if an image was passed in, set the imageView to display passed image
        if let image = image {
            imageView.image = image
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == CONTACT_SEGUE { //if going to the viewPostVC continue
            if let contactVC = segue.destination as? ContactVC { //cast the destination of the segue as viewPostVC, continue on sucess
                //set the post for the viewPostVC to the sender post
                contactVC.post = post
            }
        }
    }
 
    /**
     * @name flagPressed
     * @desc adjust the flags on the speciic post
     * @return void
     */
    @IBAction func flagPressed(_ sender: Any) {
        //adjusts the flag variable for the associated post
        self.post.adjustFlagged(addFlagged: true)
        
        //informs user that they have flagged the post
        self.showErrorAlert(title: "Post Flagged", msg: "");
    }

}
