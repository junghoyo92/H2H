//
//  ViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 1/1/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse
import CloudKit


class ViewController: UIViewController, UITextViewDelegate {

    var messages = [String]()
    var arrPosts: Array<CKRecord> = []
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase?
    var currentRecord: CKRecord?
    var photoURL: NSURL?
    
    @IBOutlet var special: UITextView!
    @IBOutlet weak var specialPicture: UIImageView!
    @IBOutlet weak var storeInfoText: UITextView!
    
    @IBOutlet weak var leftBarButtonOutlet: UIBarButtonItem!
    
    @IBAction func leftBarButtonAction(sender: AnyObject) {
        self.performSegueWithIdentifier("PostViewController", sender: self)
    }
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBAction func rightBarAction(sender: AnyObject) {
        if PFUser.currentUser()?.username != nil && rightButton.title == "Log In" {
            rightButton.title = "Log Out"
        } else if PFUser.currentUser()?.username != nil && rightButton.title == "Log Out" {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            PFUser.logOut()
            leftBarButtonOutlet.enabled = false
            self.leftBarButtonOutlet.tintColor = UIColor.clearColor()
            rightButton.title = "Log In"
            
            activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        } else if PFUser.currentUser()?.username == nil && rightButton.title == "Log In" {
            self.performSegueWithIdentifier("toLogin", sender: self)
        } else {
            rightButton.title = "Log In"
            leftBarButtonOutlet.enabled = false
            self.leftBarButtonOutlet.tintColor = UIColor.clearColor()
        }
    }
    
    @IBAction func facebook(sender: AnyObject) {
        
        let fbURLWeb: NSURL = NSURL(string: "https://www.facebook.com/Hairway-2-Heaven-Fresno-CA-301835083290706/")!
        let fbURLID: NSURL = NSURL(string: "fb://profile/301835083290706")!
        
        if UIApplication.sharedApplication().canOpenURL(fbURLID) {
            // FB Installed
            UIApplication.sharedApplication().openURL(fbURLID)
        } else {
            // FB is not installed, so open in Safari
            UIApplication.sharedApplication().openURL(fbURLWeb)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Change the navigation bar background color to blue.
        navigationController!.navigationBar.barTintColor = UIColor.redColor()
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: UIFont(name: "Avenir Next Condensed", size: 24)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        if PFUser.currentUser()?.username != nil {
            rightButton.title = "Log Out"
        } else {
            rightButton.title = "Log In"
        }
        dataSearchPull()
        storeInfoText.tintColor = UIColor.whiteColor()
        storeInfoText.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue]
        
        
        if PFUser.currentUser()?.username == "WonJinJung16" || PFUser.currentUser()?.username == "H2HDemoProfile" {
            self.leftBarButtonOutlet.enabled = true
            self.leftBarButtonOutlet.tintColor = UIColor.whiteColor()
        } else {
            self.leftBarButtonOutlet.enabled = false
            self.leftBarButtonOutlet.tintColor = UIColor.clearColor()
        }
        publicDatabase = container.publicCloudDatabase
        setupCloudKitSubscription()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.dataSearchPull), name: "performReload", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        dataSearchPull()
        if PFUser.currentUser()?.username != nil {
            rightButton.title = "Log Out"
        } else {
            rightButton.title = "Log In"
        }
        
        if PFUser.currentUser()?.username == "WonJinJung16" || PFUser.currentUser()?.username == "H2HDemoProfile" {
            self.leftBarButtonOutlet.enabled = true
            self.leftBarButtonOutlet.tintColor = UIColor.whiteColor()
        } else {
            self.leftBarButtonOutlet.enabled = false
            self.leftBarButtonOutlet.tintColor = UIColor.clearColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func setupCloudKitSubscription() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.boolForKey("subscribed") == false {
            let predicate = NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)
            let subscription = CKSubscription(recordType: "Post", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
            let notificationInfo = CKNotificationInfo()
            
            notificationInfo.alertLocalizationKey = "There's a New Deal from Hairway 2 Heaven"
            notificationInfo.shouldBadge = true
            
            subscription.notificationInfo = notificationInfo
            
            let publicData = CKContainer.defaultContainer().publicCloudDatabase
            publicData.saveSubscription(subscription) { (subscription:CKSubscription?, error:NSError?) in
                if error != nil {
                    print("Occurs in SetupCloudKitSubscription: \(error?.localizedDescription)")
                } else {
                    userDefaults.setBool(true, forKey: "subscribed")
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    func dataSearchPull() {
        let query = CKQuery(recordType: "Post", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicDatabase?.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, error:NSError?) in
            if results != nil {
                if results!.count > 0 {
                    var post = results![0]
                    self.currentRecord = post
                    dispatch_async(dispatch_get_main_queue(), {
                        self.special.text = post.objectForKey("content") as! String
                        self.special.textColor = UIColor.whiteColor()
                        self.special.font = UIFont(name: "Avenir Next Medium", size: 14)
                        self.special.textAlignment = .Center

                        if post.objectForKey("image") != nil {
                            let photo = post.objectForKey("image") as! CKAsset
                            let image = UIImage(contentsOfFile: photo.fileURL.path!)
                        
                            self.specialPicture.image = image
                        } else {
                            self.specialPicture.image = UIImage(named: "placeholder.png")
                        }
                    })
                } else {
                    self.special.text = "There are currently no Posts available"
                    self.specialPicture.image = UIImage(named: "placeholder.png")
                }
            } else {
                print("Check On ViewController DataSearch Pull:\(error)")
            }
        }
        return
    }

}