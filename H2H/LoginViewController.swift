//
//  LoginViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 5/25/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse

@available(iOS 8.0, *)
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func bottomSwitch(sender: AnyObject) {
        self.performSegueWithIdentifier("toSignUp", sender: self)
    }
    
    // next two functions are utilized to remove the keyboard by the return key or touching outside of the keyboard
    // it is the called in the viewDidLoad method below.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        textFieldShouldReturn(username)
        textFieldShouldReturn(password)
    }
    
    @IBAction func action(sender: AnyObject) {
        
        // Tests to check if username and password contain information
        // if not, user is alerted with an error message
        if username.text == "" || password.text == "" {
            
            displayAlert("Error in Form", message: "Please enter a username and password")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again"
            
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                    
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if user != nil {
                    print("Logged In!")
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        errorMessage = errorString
                    }
                    
                    self.displayAlert("Failed Log In", message: errorMessage)
                    
                }
            })
        username.text = ""
        password.text = ""
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}