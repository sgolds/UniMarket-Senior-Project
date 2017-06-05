//
//  MessagesTVC.swift
//  UniMarket
//
//  Created by Sten Golds on 4/14/17.
//  Copyright © 2017 Sten Golds. All rights reserved.
//

import UIKit
import Firebase

class MessagesTVC: UITableViewController {
    
    //array of messages to display
    var messages = [ItemMessage]()
    
    //user
    var currentUser: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if there is a current user retrieve user, and load their messages
        if let user = FIRAuth.auth()?.currentUser {
            currentUser = user
            
            //load current user's messages
            loadMessages()
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //make back button on display message have no text
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == VIEW_MESSAGE_SEGUE { //if going to the DisplayMessageVC continue
            if let displayMessVC = segue.destination as? DisplayMessageVC { //cast the destination of the segue as DisplayMessageVC, continue on sucess
                if let message = sender as? ItemMessage { //cast the sender of the segue to ItemMessage, continue on success
                    //set the message for the DisplayMessageVC to the sender message
                    displayMessVC.message = message
                }
            }
        }
     }
 

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //only want one section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //want one row per one message to display
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get message at given row
        let message = messages[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messCell") as? ItemMessageCell { //dequeue a reusable cell as ItemMessageCell, continue on success
            
            //configure the dequeued ItemMessageCell to conform to the data of the message associated with this row
            cell.configCell(message: message)
            
            //return the configured cell
            return cell
        } else { //if a dequeued cell couldn't be cast as a ItemMessageCell, create a new ItemMessageCell
            return ItemMessageCell()
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //segue to a view controller to display the selected message, use the selected message as the sender
        self.performSegue(withIdentifier: VIEW_MESSAGE_SEGUE, sender: messages[indexPath.row])
        
        //deselect the selected row
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //allow user to delete messages they have recieved
        if editingStyle == .delete {
            //delete the selected message from Firebase
            if let user = currentUser {
                
                //get message to remove
                let messKey = messages[indexPath.row].messKey
                
                //remove user association of message in firebase
                DataService.ds.USERS_REF.child(user.uid).child("Messages").child(messKey).removeValue()
                
                //remove message from firebase
                DataService.ds.CONTACT_REF.child(messKey).removeValue()
                
                //remove the selected message from the messages array
                messages.remove(at: indexPath.row)
                
                //reflect deletition in tableView
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
 
    /**
     * @name loadMessages
     * @desc get messages with current user as retriever from the firebase database and store these messages in messages array
     * @return void
     */
    func loadMessages() {
        if let user = currentUser {
            
            DataService.ds.USERS_REF.child(user.uid).child("Messages").observe(.value, with: { (userSnapshot) in //get message ids as snapshot
                //clear messages
                self.messages = []
                
                if let snapshots = userSnapshot.children.allObjects as? [FIRDataSnapshot] { //cast the snapshot as an array of snapshots, continue on success
                    
                    //iterate over the snapshots gotten
                    for snap in snapshots {
                        
                        //get message for specific message id in user message ids array
                        DataService.ds.CONTACT_REF.child(snap.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let messDict = snapshot.value as? Dictionary<String, AnyObject> {
                                
                                //initialize a message with the data gotten from the snapshot
                                let gotMess = ItemMessage(dictionary: messDict)
                                
                                //add the created message to the messages array
                                self.messages.append(gotMess)
                                
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
