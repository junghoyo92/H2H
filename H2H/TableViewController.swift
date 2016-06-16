//
//  TableViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 6/1/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse
import CloudKit

class TableViewController: UITableViewController {
    
    var messages = [CKRecord]()
    var refresh:UIRefreshControl!
    var messageSelectedIndex: Int!
    var thereIsCellTapped = false
    var selectedRowIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.removeFromSuperview()
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresh?.addTarget(self, action: #selector(TableViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresh!)
        
        loadData()
    }
    
    @IBAction func sendPost(sender: AnyObject) {
        let alert = UIAlertController(title: "Write 2 Us", message: "Your Message", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField) in
            textField.placeholder = "Enter Message Here"
        }
        
        alert.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (action:UIAlertAction) in
            let postTextField = alert.textFields!.first!
            
            if postTextField != "" {
                let newMessage = CKRecord(recordType: "Message")
                newMessage["message"] = postTextField.text
                if PFUser.currentUser()?.username != nil {
                    newMessage["username"] = (PFUser.currentUser()?.username)! as String
                } else {
                    newMessage["username"] = "Anonymous"
                }
                
                let publicData = CKContainer.defaultContainer().publicCloudDatabase
                publicData.saveRecord(newMessage, completionHandler: { (record:CKRecord?, error:NSError?) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            print("Post Saved")
                            self.tableView.beginUpdates()
                            self.messages.insert(newMessage, atIndex: 0)
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        })
                    } else {
                        print(error)
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadData() {
        messages = [CKRecord]()
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Message", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, error:NSError?) in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.messages = results!
                    self.tableView.reloadData()
                    print("Start Reloading")
                    self.tableView.reloadData()
                    self.refresh?.endRefreshing()
                })
            } else {
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        // configure the cell....
        if messages.count == 0 {
            return cell
        }
        
        let message = messages[indexPath.row]
        cell.descriptionLabel.text = message["message"] as? String
        cell.titleLabel.text = message["username"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == selectedRowIndex && thereIsCellTapped {
            return 300
        }
        
        return 135
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.grayColor()
        
        // avoid paint the cell is the index is outside the bounds
        if self.selectedRowIndex != -1 {
            self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.selectedRowIndex, inSection: 0))?.backgroundColor = UIColor.whiteColor()
        }
        
        if selectedRowIndex != indexPath.row {
            self.thereIsCellTapped = true
            self.selectedRowIndex = indexPath.row
        }
        else {
            // there is no cell selected anymore
            self.thereIsCellTapped = false
            self.selectedRowIndex = -1
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

}
