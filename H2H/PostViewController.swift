//
//  PostViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 5/29/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse
import CloudKit
import MobileCoreServices

@available(iOS 8.0, *)
class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postTextField: UITextView!
    @IBOutlet weak var imageToPost: UIImageView!
    var activityIndicator = UIActivityIndicatorView()
    
    let container = CKContainer.defaultContainer()
    var publicDatabase: CKDatabase?
    var currentRecord: CKRecord?
    var photoURL: NSURL?
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // next two functions are utilized to remove the keyboard by the return key or touching outside of the keyboard
    // it is the called in the viewDidLoad method below.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        // sets source of picture -> can switch photolibrary to camera to take a picture to post
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(image)
        imageToPost.image = image
        imageToPost.contentMode = UIViewContentMode.ScaleAspectFit
        photoURL = saveImageToFile(image)
        print(photoURL)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postImage(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if postTextField.text != "" {
            
            if (photoURL == nil) {
                let post = CKRecord(recordType: "Post")
                post.setObject(postTextField.text, forKey: "content")
                displayAlert("No Photo", message: "Use the Photo option to choose a photo for the record")
                publicDatabase!.saveRecord(post, completionHandler: { (record:CKRecord?, error:NSError?) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            print("Post Saved")
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.displayAlert("Posted", message: "You're Post has been Successful")
                            self.postTextField.text = ""
                            self.imageToPost.image = UIImage(named: "placeholder.png")
                        })
                    } else {
                        print("This is where the error occurs: \(error)")
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    }
                })
                return
            } else {
                let asset = CKAsset(fileURL: photoURL!)
                let post = CKRecord(recordType: "Post")
                post.setObject(postTextField.text, forKey: "content")
                post.setObject(asset, forKey: "image")

                publicDatabase!.saveRecord(post, completionHandler: { (record, error) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.postTextField.text = ""
                            self.currentRecord = post
                        })
                        self.activityIndicator.stopAnimating()
                        self.displayAlert("Posted", message: "You're Post has been Successful")
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    } else {
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    }
                })
            }
        } else {
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    func saveImageToFile(image: UIImage) -> NSURL
    {
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = fileMgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let filePath = dirPaths[0].URLByAppendingPathComponent("currentImage.png").path
        
        UIImageJPEGRepresentation(image, 0.5)!.writeToFile(filePath!, atomically: true)
        
        return NSURL.fileURLWithPath(filePath!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publicDatabase = container.publicCloudDatabase
        
        postTextField.layer.cornerRadius = 10
        postTextField.clipsToBounds = true
        imageToPost.layer.cornerRadius = 40
        imageToPost.clipsToBounds = true
        self.postTextField.delegate = self
        
    }
}
