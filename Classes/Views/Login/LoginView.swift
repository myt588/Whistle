//
//  ViewController.swift
//  ParseStarterProject
//
//  Created by Yetian Mao on 6/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import ParseUI
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class LoginView: UIViewController, TSMessageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var logoLabel                        : WEContentLabel!
    @IBOutlet weak var phone                            : UIImageView!
    @IBOutlet weak var facebook                         : UIImageView!
    @IBOutlet weak var twitter                          : UIImageView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    let permissions                                     = ["public_profile", "user_friends", "email", "user_photos"]
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        configBg()
        addGestures()
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configBg()
    //----------------------------------------------------------------------------------------------------------
    {
        var filePath                        = NSBundle.mainBundle().pathForResource("test", ofType: "gif")
        var gif                             = NSData(contentsOfFile: filePath!)
        var webViewBG                       = UIWebView(frame: self.view.bounds)
        webViewBG.loadData(gif, MIMEType: "image/gif", textEncodingName: nil, baseURL: nil)
        webViewBG.userInteractionEnabled = false
        self.view.insertSubview(webViewBG, atIndex: 0)
        var darkBlur                        = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                        = UIVisualEffectView(effect: darkBlur)
        blurView.frame                      = view.bounds
        view.insertSubview(blurView, aboveSubview: webViewBG)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        logoLabel.addBottomBorderWithHeight(0.3, color: Constants.Color.Border)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        var facebookTapped                  = UITapGestureRecognizer(target: self, action: "facebookTapped")
        facebook.addGestureRecognizer(facebookTapped)
        var twitterTapped                   = UITapGestureRecognizer(target: self, action: "twitterTapped")
        twitter.addGestureRecognizer(twitterTapped)
        var phoneTapped                     = UITapGestureRecognizer(target: self, action: "phoneTapped")
        phone.addGestureRecognizer(phoneTapped)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func phoneTapped()
    //----------------------------------------------------------------------------------------------------------
    {
        performSegueWithIdentifier("signin_with_phone", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func facebookTapped()
    //----------------------------------------------------------------------------------------------------------
    {
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                    self.userLoggedIn(user)
                } else {
                    println("User logged in through Facebook!")
                    self.userLoggedIn(user)
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
                ParseErrorHandler.handleParseError(error)
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func twitterTapped()
    //----------------------------------------------------------------------------------------------------------
    {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in with Twitter!")
                    self.userLoggedIn(user)
                } else {
                    println("User logged in with Twitter!")
                    self.userLoggedIn(user)
                }
            } else {
                println("Uh oh. The user cancelled the Twitter login.")
                ParseErrorHandler.handleParseError(error)
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func userLoggedIn(user: PFUser)
    //----------------------------------------------------------------------------------------------------------
    {
        ParsePushUserAssign()
        PFCloud.callFunctionInBackground("deleteSession", withParameters: ["device": PFInstallation.currentInstallation().installationId]) { (message, error) -> Void in
            if let message: AnyObject = message {
                println(message)
            } else {
                ParseErrorHandler.handleParseError(error)
            }
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
}

