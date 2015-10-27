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
class LoginView: UIViewController
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var facebook                         : UIImageView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    
    let permissions = ["public_profile", "user_friends", "email", "user_photos"]
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configBg()
        addGestures()
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
        self.view.backgroundColor = Constants.Color.Background
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        var facebookTapped = UITapGestureRecognizer(target: self, action: "facebookTapped")
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
        var thumbnail = ResizeImage(image, 60, 60, 1.0)
        var filePicture = PFFile(name: "portrait.jpg", data: NSData(data: picture.mediumQualityJPEGNSData))
        filePicture.saveInBackgroundWithBlock { (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
            }
        }
        var fileThumbnail = PFFile(name: "thumbnail.jpg", data: NSData(data: thumbnail.mediumQualityJPEGNSData))
        fileThumbnail.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
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
        performSegueWithIdentifier("Login_To_Root", sender: self)
    }
}

