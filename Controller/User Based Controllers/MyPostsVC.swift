//
//  MyPostsVC.swift
//  UniMarket
//
//  Created by Sten Golds on 3/5/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase

class MyPostsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    //references to text view in storyboard
    @IBOutlet weak var tableView: UITableView!
    
    //array of posts to display
    var posts = [ItemPost]()
    
    //image chosen
    var selectedImage: UIImage?
    
    //user
    var currentUser: FIRUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        //set tableView delegate and datasource to self
        //and hide seperator lines of table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        //if there is a current user retrieve user, and load their posts
        if let user = FIRAuth.auth()?.currentUser {
            currentUser = user
            
            //load current user's posts
            loadUserPosts()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //make back button on display post have no text
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == SHOW_USER_POST { //if going to the DisplayMyPostVC continue
            if let displayVC = segue.destination as? DisplayMyPostVC { //cast the destination of the segue as DisplayMyPostVC, continue on sucess
                if let post = sender as? ItemPost { //cast the sender of the segue to Post, continue on success
                    //set the post for the DisplayMyPostVC to the sender post
                    displayVC.post = post
                    
                    if let image = selectedImage {
                        displayVC.image = image
                    }
                }
            }
        }
    }

    
    // MARK: - Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //only want one section
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //want one row per one post to display
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get post at given row
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userPostCell") as? ItemPostCell { //dequeue a reusable cell as ItemPostCell, continue on success
            
            if let image = PostListVC.imageCache.object(forKey: post.postKey as NSString) { //if cache has an image for the post, load the image from cache
                
                //configure the dequeued ItemPostCell with an image provided
                cell.configCell(post: post, image: image)
            } else {
                
                //configure the dequeued ItemPostCell to conform to the data of the post associated with this row
                cell.configCell(post: post)
            }
            
            //return the configured cell
            return cell
        } else { //if a dequeued cell couldn't be cast as a ItemPostCell, create a new ItemPostCell
            return ItemPostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //get post at path
        let postAtPath = posts[indexPath.row]
        
        //if post has an image, use larger cell with imageView area, if not, do not display empty imageView area
        if postAtPath.hasImg {
            return 400
        } else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //store selected cell
        let cell = tableView.cellForRow(at: indexPath) as! ItemPostCell
        
        if let image = cell.postImage.image {
            selectedImage = image
        } else {
            selectedImage = nil
        }
        
        //segue to a view controller to display the selected post, use the selected post as the sender
        self.performSegue(withIdentifier: SHOW_USER_POST, sender: posts[indexPath.row])
        
        //deselect the selected row
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //allow users to edit their saved entries list
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //allow user to delete a Post from their created posts list
        if editingStyle == .delete {
            
            //delete the selected Post from Firebase
            if let user = currentUser {
                
                //get post to remove
                let postKey = posts[indexPath.row].postKey
                
                //remove user ownership of post in firebase
                DataService.ds.USERS_REF.child(user.uid).child("Posts").child(postKey).removeValue()
                
                //remove post from firebase
                DataService.ds.POST_REF.child(postKey).removeValue()
                
                //remove the selected post from the posts array
                posts.remove(at: indexPath.row)
                
                //reflect deletition in tableView
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    /**
     * @name loadUserPosts
     * @desc get posts with current user as poster from the firebase database and store these posts in posts array
     * @return void
     */
    func loadUserPosts() {
        
        if let user = currentUser {
            
            DataService.ds.USERS_REF.child(user.uid).child("Posts").observe(.value, with: { (userSnapshot) in //get post ids as snapshot
                //clear posts
                self.posts = []
                
                if let snapshots = userSnapshot.children.allObjects as? [FIRDataSnapshot] { //cast the snapshot as an array of snapshots, continue on success
                    
                    //iterate over the snapshots gotten
                    for snap in snapshots {
                        
                        //get post for specific post id in user post ids array
                        DataService.ds.POST_REF.child(snap.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                
                                //initialize a post with the data gotten from the snapshot
                                let gotPost = ItemPost(dictionary: postDict)
                                
                                //add the created post to the posts array
                                self.posts.append(gotPost)
                                
                            }
                            
                            self.tableView.reloadData()
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
            })
        }
    }

}
