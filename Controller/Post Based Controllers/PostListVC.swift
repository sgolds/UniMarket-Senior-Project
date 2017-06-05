//
//  PostListVC.swift
//  UniMarket
//
//  Created by Sten Golds on 2/17/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase
import Material

class PostListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //references to the table view in storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterCatTF: TextField!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //array of posts to display
    var posts = [ItemPost]()
    var userSchoolId = ""
    var filteredPosts = [ItemPost]()
    
    //data for pickerView filter input (filterCatTF)
    var categories = ["All", "Books", "Electronics", "Clothing", "Home/Appliances", "Sports/Outdoors", "Misc"]
    
    //image chosen
    var selectedImage: UIImage?
    
    //cache used to store downloaded images, so images aren't repeatedly downloaded
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notification observer to reload the tableview when an image for newly added post is successfully added to storage
        NotificationCenter.default.addObserver(self, selector: #selector(loadTableNewImg), name: NSNotification.Name(rawValue: "loadTable"), object: nil)
        
        
        //set tableView delegates/datasourse as well as remove divider between posts
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        //set search bar delegate
        searchBar.delegate = self
        
        //create the picker view used to filter posts
        createFilterPickerView()
        
        //get current user's schoolId and then call method to retrieve posts that share the school ID
        if let user = FIRAuth.auth()?.currentUser {
            DataService.ds.USERS_REF.child(user.uid).observe(.value, with: { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    self.userSchoolId = userDict["schoolId"] as! String
                    self.loadPosts(schoolId: self.userSchoolId, category: nil)
                }
            })
        }
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //make back button on display post and new post have no text associated
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == DISPLAY_ITEM_POST_SEGUE { //if going to the viewPostVC continue
            if let displayVC = segue.destination as? DisplayItemPostVC { //cast the destination of the segue as viewPostVC, continue on sucess
                if let post = sender as? ItemPost { //cast the sender of the segue to Post, continue on success
                    //set the post for the viewPostVC to the sender post
                    displayVC.post = post
                    
                    if let image = selectedImage {
                        displayVC.image = image
                    }
                }
            }
        }
     }
 
    // MARK: - Dismissal Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        filterCatTF.resignFirstResponder()
    }
    
    func donePicker() {
        filterCatTF.resignFirstResponder()
    }

    
    // MARK: - Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //only want one section
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //want one row per one post to display
        
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get post at given row
        let post = filteredPosts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? ItemPostCell { //dequeue a reusable cell as ItemPostCell, continue on success
            
            cell.imageView?.image = nil
            
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
        let postAtPath = filteredPosts[indexPath.row]
        
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
        self.performSegue(withIdentifier: DISPLAY_ITEM_POST_SEGUE, sender: filteredPosts[indexPath.row])
        
        //deselect the selected row
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        //store selected cell
        let cell = tableView.cellForRow(at: indexPath) as! ItemPostCell
        
        //hide shadow to show cell was selected
        cell.holderView.shadowOpacity = 0.0
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        //store selected cell
        let cell = tableView.cellForRow(at: indexPath) as! ItemPostCell
        
        //display shadow to show cell was deselected
        cell.holderView.shadowOpacity = 0.7
    }
    

    /**
     * @name loadTableNewImg
     * @desc method called by upload image in dataservice to indicate the new post's image was successfiully added
     * @return void
     */
    func loadTableNewImg() {
        self.tableView.reloadData()
    }
    
    // MARK: - Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            
            //lower case search text for easy mataching
            let lowerCasedPhrase = text.lowercased()
            
            //filter posts so the displayed posts either have the searched phrase in their title or their description
            filteredPosts = text.isEmpty ? posts : posts.filter { (post) -> Bool in
                return post.title.lowercased().contains(lowerCasedPhrase) || post.description.lowercased().contains(lowerCasedPhrase)
            }
            
            //reload table to show filtered posts
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //sets search bar text to empty, and hides keyboard
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        //restores all posts
        filteredPosts = posts
        
        //reload table view
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        filterCatTF.text = categories[row]
    }
    
    /**
     * @name loadPosts
     * @desc get posts from the firebase database and store these posts in posts array
     * @return void
     */
    func loadPosts(schoolId: String, category: String?) {
        
        DataService.ds.POST_REF.observe(.value, with: { (snapshot) in //get posts as snapshot
            //clear posts
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] { //cast the snapshot as an array of snapshots, continue on success
                //iterate over the snapshots gotten
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> { //cast value of the snapshot to a dict, continue on success
                        
                        //get school id associated with post, force cast as we know there will be one
                        let postSchoolId = postDict["schoolId"] as! String
                        
                        //get posts associated with user's school
                        if postSchoolId == schoolId {
                            //initialize a post with the data gotten from the snapshot
                            let gotPost = ItemPost(dictionary: postDict)
                            
                            if category == nil {
                                //add the created post to the posts array
                                self.posts.append(gotPost)
                            } else if let cat = category, cat == gotPost.category {
                                //add the created post to the posts array
                                self.posts.append(gotPost)
                            }
                        }
                    }
                    
                }
            }
            
            self.filteredPosts = self.posts
            
            //reload the tableView so the gotten posts will be displayed
            self.tableView.reloadData()
        })
        
    }
    
    /**
     * @name createFilterPickerView
     * @desc create the picker view used to filter posts based on category
     * @return void
     */
    func createFilterPickerView() {
        //pickerView and input for filter
        let filterPicker = UIPickerView()
        filterPicker.delegate = self
        filterPicker.backgroundColor = COMMON_GRAY
        
        //toolbar for pickerView
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.backgroundColor = COMMON_GRAY
        toolBar.tintColor = COMMON_BLUE
        toolBar.sizeToFit()
        
        //done button for pickerView toolbar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PostListVC.donePicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        //add pickerView as input to filter textField
        filterCatTF.inputView = filterPicker
        filterCatTF.inputAccessoryView = toolBar
        
        //textField active colors
        filterCatTF.placeholderActiveColor = COMMON_BLUE
        filterCatTF.dividerActiveColor = COMMON_BLUE
    }
    
    /**
     * @name filterPressed
     * @desc either display or hide filter view, based on if hidden or not
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func filterPressed(_ sender: Any) {
        if filterView.isHidden {
            filterView.isHidden = false
        } else {
            filterView.isHidden = true
        }
    }
    
    /**
     * @name applyFilterPressed
     * @desc apply the category filter selected by user
     * @param Any sender - the sender of the action
     * @return void
     */
    @IBAction func applyFilterPressed(_ sender: Any) {
        //if there is no category, or all categories are included, just load all posts for the school
        //else load the posts with associated category
        if filterCatTF.text! == "" || filterCatTF.text! == "All" {
            loadPosts(schoolId: userSchoolId, category: nil)
        } else {
            loadPosts(schoolId: userSchoolId, category: filterCatTF.text!)
        }
        
        //hide the filter selection view
        filterView.isHidden = true
        
        //resign filter picker view
        filterCatTF.resignFirstResponder()
    }
    

}
