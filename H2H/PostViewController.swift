//
//  PostViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 5/29/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse

@available(iOS 8.0, *)
class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postTextField: UITextView!
    @IBOutlet weak var imageToPost: UIImageView!
    var activityIndicator = UIActivityIndicatorView()
    
    
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
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    // occurs when a user has finished picking their image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
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
        
        let query = PFQuery(className: "Post")
        print(query)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            if let objects = objects {
                for object in objects {
                    object.deleteInBackground()
                }
            }
        })
        
        let post = PFObject(className: "Post")
        
        post["message"] = postTextField.text
        post["userID"] = PFUser.currentUser()?.objectId!
        
        // this adds a compression and makes it a jpeg which is better for upload
        let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.7)
        
        //2 creates an image file from the above
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        
        post["imageFile"] = imageFile
        
        post.saveInBackgroundWithBlock { (success, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
            
            if error == nil {
                
                self.displayAlert("Posted", message: "Message has succesfully posted")
                self.imageToPost.image = UIImage(named: "placeholder.png")
                self.postTextField.text = ""
                
            } else {
                self.displayAlert("Post Unsuccessful", message: "Please try again or select a different image")
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postTextField.delegate = self
        
    }
}
