//
//  ViewController.swift
//  H2H
//
//  Created by Hoyoung Jung on 1/1/16.
//  Copyright © 2016 Hoyoung Jung. All rights reserved.
//

import UIKit
import Parse
import LiquidFloatingActionButton

class ViewController: UIViewController, UITextViewDelegate {

    var messages = [String]()
    var imageFiles = [PFFile]()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var special: UITextView!
    @IBOutlet weak var specialPicture: UIImageView!
    
    // Data source for floating button
    var cells = [LiquidFloatingCell]()
    var floatingActionButton: LiquidFloatingActionButton!
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBAction func rightBarAction(sender: AnyObject) {
        if PFUser.currentUser()?.username != nil {
            rightButton.title = "Log Out"
            print("If Loop \(PFUser.currentUser()?.username)")
        } else {
            rightButton.title = "Log In"
            print("Else Loop \(PFUser.currentUser()?.username)")
        }
        
        if PFUser.currentUser()?.username == nil {
            self.performSegueWithIdentifier("toLogin", sender: self)
        } else {
            print(PFUser.currentUser())
            PFUser.logOut()
        }
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        dataSearchPull()
        print("Refreshed")
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
            print("If Loop \(PFUser.currentUser()?.username)")
        } else {
            rightButton.title = "Log In"
            print("Else Loop \(PFUser.currentUser()?.username)")
        }
        
        createFloatingButtons() // password = Fabiana&Doobie
        if PFUser.currentUser()?.username == "WonJinJung" {
            floatingActionButton.hidden = false
        } else {
            print(PFUser.currentUser())
            floatingActionButton.hidden = true
        }
        
        dataSearchPull()
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser()?.username != nil {
            rightButton.title = "Log Out"
            print("If Loop \(PFUser.currentUser()?.username)")
        } else {
            rightButton.title = "Log In"
            print("Else Loop \(PFUser.currentUser()?.username)")
        }
        if PFUser.currentUser()?.username == "WonJinJung" {
            floatingActionButton.hidden = false
            dataSearchPull()
        } else {
            print(PFUser.currentUser())
            floatingActionButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataSearchPull() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "Post")
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            self.messages.removeAll(keepCapacity: true)
            self.imageFiles.removeAll(keepCapacity: true)
            if let objects = objects {
                for object in objects {
                    self.special.text = object["message"] as! String
                    self.special.textColor = UIColor.whiteColor()
                    self.special.font = UIFont(name: "Avenir Next", size: 17)
                    self.special.textAlignment = .Center
                    let imagefile = object["imageFile"] as! PFFile
                    
                    imagefile.getDataInBackgroundWithBlock({ (data, error) in
                        if let downloadedImage = UIImage(data: data!) {
                            self.specialPicture.image = downloadedImage
                        }
                    })
                }
            }
        })
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        return
    }

    // MARK: - Create floating Buttons
    
    private func createFloatingButtons() {
        //cells.append(createButtonCell("settings.png"))
        cells.append(createButtonCell("post.png"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 52 - 16, y: self.view.frame.height - 52 - 16, width: 56, height: 56)
        let floatingButton1 = createButton(floatingFrame, style: .Left)
        
        self.view.addSubview(floatingButton1)
        self.floatingActionButton = floatingButton1
    }
    
    private func createButtonCell(iconName: String) -> LiquidFloatingCell {
        return LiquidFloatingCell(icon: UIImage(named: iconName)!)
    }
    
    private func createButton(frame: CGRect, style: LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton
    {
        let floatingActionButton1 = LiquidFloatingActionButton(frame: frame)
        
        floatingActionButton1.animateStyle = style
        floatingActionButton1.color = UIColor.init(red: 151/256.0, green: 208/256.0, blue: 195/256.0, alpha: 1.0)
        floatingActionButton1.tintColor = UIColor.whiteColor()
        floatingActionButton1.alpha = 1.0
        floatingActionButton1.dataSource = self
        floatingActionButton1.delegate = self
        
        return floatingActionButton1
    }
    
}

extension ViewController: LiquidFloatingActionButtonDataSource
{
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
}

extension ViewController: LiquidFloatingActionButtonDelegate
{
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        print("button number \(index) did click")
        if index == 0 {
            self.performSegueWithIdentifier("PostViewController", sender: self)
        }
        self.floatingActionButton.close()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

