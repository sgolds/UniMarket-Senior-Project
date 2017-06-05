//
//  ItemPostCell.swift
//  UniMarket
//
//  Created by Sten Golds on 2/18/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit

class ItemPostCell: UITableViewCell {
    
    //references to the ItemPostCell created in storyboard
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    //variable used to store the associated post
    var post: ItemPost!
    
    
    /**
     * @name awakeFromNib
     * @desc overrides awakeFromNib of UITableViewCell so that the EntryCell is manipulated by the code
     * @return void
     */
    override func awakeFromNib() {
        
        //clear selection style for cell, allows for custom styling
        self.selectionStyle = .none
    }
    
    /**
     * @name configCell
     * @desc configures the ItemPostCell with the data from the associated post
     * @param ItemPost post - post of which this ItemPostCell will represent
     * @return void
     */
    func configCell(post: ItemPost, image: UIImage? = nil) {
        
        //set ItemPostCell post to passed in Post
        self.post = post
        
        //set post name and description  labels
        self.titleLabel.text = post.title
        self.descriptionLabel.text = post.description
        
        if post.hasImg {
            //if cell was given image, set cell image to the given image, else download the associated image
            if image != nil {
                self.postImage.image = image
            } else {
                //placeholder image while real post image is loading
                self.postImage.image = #imageLiteral(resourceName: "noImg")
                
                //get reference for the post's image
                let imgRef = DataService.ds.POSTS_IMAGES_REF.child(post.postKey + ".jpg")
                
                // Download the post's image
                imgRef.data(withMaxSize: 2 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print(error!.localizedDescription)
                    } else {
                        //if download was successful, convert data into an image, set PostCell's image to the post image, and add image to cache
                        if let imageData = data {
                            if let loadedImage = UIImage(data: imageData) {
                                self.postImage.image = loadedImage
                                
                                PostListVC.imageCache.setObject(loadedImage, forKey: post.postKey as NSString)
                                
                            }
                        }
                    }
                }
            }
        } else {
            self.postImage.image = nil
        }
    }
    

}
