//
//  SignUpViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 5/29/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse
import CloudKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passCheckTextField: UITextField!
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
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
        textFieldShouldReturn(usernameTextField)
        textFieldShouldReturn(passwordTextField)
        textFieldShouldReturn(passCheckTextField)
    }
    
    @IBAction func SignUpAction(sender: AnyObject) {
        
        // Tests to check if username and password contain information
        // if not, user is alerted with an error message
        if usernameTextField.text == "" || passwordTextField.text == "" || passCheckTextField.text == "" {
            
            displayAlert("Error in Form", message: "Please enter a username and password")
            
        } else if passwordTextField.text != passCheckTextField.text {
            displayAlert("Password Error", message: "Passwords do not match")
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again"
            
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                if error == nil {
                    // successfull signup -> what to do after signup is complete
                    PFUser.logInWithUsernameInBackground(self.usernameTextField.text!, password: self.passwordTextField.text!, block: { (user, error) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if user != nil {
                            self.navigationController?.popToRootViewControllerAnimated(true)
                            let newUser = CKRecord(recordType: "Users")
                            newUser["username"] = self.usernameTextField.text
                            if PFUser.currentUser()?.username != nil {
                                newUser["username"] = (PFUser.currentUser()?.username)! as String
                            } else {
                                newUser["username"] = "Anonymous"
                            }

                            
                        } else {
                            if let errorString = error!.userInfo["error"] as? String {
                                errorMessage = errorString
                            }
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.displayAlert("Failed Log In", message: errorMessage)
                        }
                    })
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        errorMessage = errorString
                    }
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Failed SignUp", message: errorMessage)
                }
            })
        }
    }
}
