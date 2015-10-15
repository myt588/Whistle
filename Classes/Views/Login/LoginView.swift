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
    @IBOutlet weak var facebook                         : UIImageView!
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
                    self.requestFacebook(user)
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
    func requestFacebook(user: PFUser)
    //----------------------------------------------------------------------------------------------------------
    {
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.height(200).width(200), gender"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    println(result)
                    self.requestFacebookPicture(user, userData: result as! NSDictionary)
                } else {
                    println("network error")
                }
            })
        }
    }
    
    func requestFacebookPicture(user: PFUser, userData: NSDictionary)
    {
        let url = userData.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            if let image = image {
                self.processFacebook(user, userData: userData, image: image)
            } else {
                
            }
        })
    }
    
    func processFacebook(user: PFUser, userData: NSDictionary, image: UIImage)
    {
        var picture = image
        var thumbnail = ResizeImageByWidth(image, 60)
        var filePicture = PFFile(name: "portrait.jpg", data: NSData(data: picture.mediumQualityJPEGNSData))
        filePicture.saveInBackgroundWithBlock { (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
                TSMessage.showNotificationWithTitle("", subtitle: "Failed saving image in the background", type: TSMessageNotificationType.Error)
            }
        }
        var fileThumbnail = PFFile(name: "thumbnail.jpg", data: NSData(data: thumbnail.mediumQualityJPEGNSData))
        fileThumbnail.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
                TSMessage.showNotificationWithTitle("", subtitle: "Failed saving image in the background", type: TSMessageNotificationType.Error)
            }
        })
        user[Constants.User.Portrait] = filePicture
        user[Constants.User.Thumbnail] = fileThumbnail
        
        let facebookId = userData.objectForKey("id") as? String
        let email = userData.objectForKey("email") as? String
        let gender = userData.objectForKey("gender") as? String
        let name = userData["name"] as? String
        
        if email != nil {
            user[Constants.User.Email] = email
        }
        
        if gender != nil {
            user[Constants.User.Gender] = gender == "male" ? 1 : 0
        }
        
        user[Constants.User.FacebookId] = facebookId
        user[Constants.User.Nickname] = name
        user[Constants.User.NicknameLower] = name!.lowercaseString
        user[Constants.User.Likes] = 0
        user[Constants.User.Favors] = 0
        user[Constants.User.Assists] = 0
        user[Constants.User.Rating] = 0
        user[Constants.User.Rates] = 0
        user[Constants.User.Level] = 0

        user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
                TSMessage.showNotificationWithTitle("", subtitle: "Failed saving image in the background", type: TSMessageNotificationType.Error)
            } else {
                self.view.userInteractionEnabled = false
                self.userLoggedIn(user)
            }
        })

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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
}

