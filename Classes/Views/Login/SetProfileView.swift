//
//  SetProfileView.swift
//  Whistle
//
//  Created by Yetian Mao on 6/25/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class SetProfileView: UITableViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TSMessageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var message                      : UILabel!
    @IBOutlet weak var textField                    : UITextField!
    @IBOutlet weak var profileImage                 : UIImageView!
    @IBOutlet weak var nameView                     : UIView!
    @IBOutlet weak var lazyLabel                    : WEContentLabel!
    @IBOutlet weak var nameCount                    : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var user: PFUser?
    var rowCount : Int = 2
    //----------------------------------------------------------------------------------------------------------
    private var imagePicker = UIImagePickerController()
    private var image : UIImage?
    private var name : String?
    private var email : String?
    private var gender : String?
    private var facebookId : String?
    private var twitterId : String?
    private var needEdit : Bool = false
    //----------------------------------------------------------------------------------------------------------
    let permissions = ["public_profile", "user_friends", "email", "user_photos"]
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    required init(coder decoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        user = PFUser.currentUser()
        super.init(coder: decoder)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        
        tableView.contentInset              = UIEdgeInsetsMake(0, 0, 0, 0)
        
        profileImage.layer.cornerRadius     = 42.5
        profileImage.layer.borderWidth      = 2
        profileImage.layer.borderColor      = Constants.Color.Border.CGColor
        
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
        
        //------------------------------------------------------------------------------------------------------
        imagePicker.delegate = self
        textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadScene", name: Constants.Notification.SetProfileView, object: nil)
        
        // Add gestures
        //------------------------------------------------------------------------------------------------------
        var tap = UITapGestureRecognizer(target: self, action: "tapToSeeOptions")
        profileImage.addGestureRecognizer(tap)
        //------------------------------------------------------------------------------------------------------
        //------------------------------------------------------------------------------------------------------
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        //------------------------------------------------------------------------------------------------------
        super.viewDidAppear(animated)
        //------------------------------------------------------------------------------------------------------
        itemsToDisplay()
        //------------------------------------------------------------------------------------------------------
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    @IBAction func done(sender: UIBarButtonItem)
    //----------------------------------------------------------------------------------------------------------
    {
        self.textField.endEditing(true)
        if let user = self.user {
            
            if textField.text == "" {
                ProgressHUD.showError("Please enter a nickname")
                return
            }
            
            self.editing = false
            SwiftSpinner.show("Just\na moment...")
            view.userInteractionEnabled = false
            
            if self.profileImage.image != UIImage(named: "login_photo") {
                var picture = Image.resizeImage(profileImage.image!, width: 300, height: 300)
                var thumbnail = Image.resizeImage(profileImage.image!, width: 60, height: 60)
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
            }
            
            if email != nil {
                user[Constants.User.Email] = self.email
            }
            
            if gender != nil {
                user[Constants.User.Gender] = self.gender == "male" ? 1 : 0
            }
            
            if facebookId != nil {
                user[Constants.User.FacebookId] = self.facebookId
            }
            
            if twitterId != nil {
                user[Constants.User.TwitterId] = self.twitterId
            }
            
            user[Constants.User.Nickname] = textField.text
            user[Constants.User.NicknameLower] = textField.text.lowercaseString
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
                    self.performSegueWithIdentifier("setProfileToInit", sender: self)
                }
            })
            user.pinInBackground()
        } else {
            performSegueWithIdentifier("setProfileToInit", sender: self)
        }
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func loadScene()
    //----------------------------------------------------------------------------------------------------------
    {
        SwiftSpinner.hide()
        self.textField.becomeFirstResponder()
        view.userInteractionEnabled = true
        self.textField.text = self.name
        self.profileImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.profileImage.image = Image.cropToSquare(image: self.image!)
        self.profileImage.layer.cornerRadius = self.profileImage.layer.frame.height/2
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.masksToBounds = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func itemsToDisplay()
    //----------------------------------------------------------------------------------------------------------
    {
        if PFFacebookUtils.isLinkedWithUser(user!) {
            SwiftSpinner.show("Downloading\nInformation...")
            view.userInteractionEnabled = false
            self.needEdit = true
            getFBUserData()
        } else if PFTwitterUtils.isLinkedWithUser(user!) {
            SwiftSpinner.show("Downloading\nInformation...")
            view.userInteractionEnabled = false
            self.needEdit = true
            getTwitterUserData()
        } else {
            self.rowCount = 5
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func getTwitterUserData()
    //----------------------------------------------------------------------------------------------------------
    {
        var url : NSURL = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!
        var request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
        PFTwitterUtils.twitter()?.signRequest(request)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(
            request,
            completionHandler: {
                data, response, error in
                if (error != nil) {
                    println("network error")
                }
                var json = JSON(data: data)
                self.name = json["name"].string
                self.twitterId = json["id_str"].string
                self.nameCount.text = "\(count(self.name!))/\(Constants.Limit.Name)"
                let url : String = json["profile_image_url"].string!
                ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
                    self.image = image
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.SetProfileView, object: self)
                })
        })
        task.resume()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func getFBUserData()
    //----------------------------------------------------------------------------------------------------------
    {
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large), gender"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    println(result)
                    let temp = result as! NSDictionary
                    self.facebookId = temp.objectForKey("id") as? String
                    self.email = temp.objectForKey("email") as? String
                    self.gender = temp.objectForKey("gender") as? String
                    let url = temp.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                    ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
                        self.image = image
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.SetProfileView, object: self)
                    })
                    self.name = result["name"] as? String
                    self.nameCount.text = "\(count(self.name!))/\(Constants.Limit.Name)"
                } else {
                    println("network error")
                }
            })
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tapToSeeOptions()
    //----------------------------------------------------------------------------------------------------------
    {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if needEdit {
            let edit = UIAlertAction(title: "Edit", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in

            })
            optionMenu.addAction(edit)
        }
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shootPhoto()

        })
        let chooseFromLibrary = UIAlertAction(title: "Choose from Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.photoFromLibrary()

        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in

        })
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(chooseFromLibrary)
        optionMenu.addAction(cancel)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Image
    //----------------------------------------------------------------------------------------------------------
    // Start Photo Library
    //----------------------------------------------------------------------------------------------------------
    func photoFromLibrary()
    //----------------------------------------------------------------------------------------------------------
    {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Take a picture, check if we have a camera first.
    //----------------------------------------------------------------------------------------------------------
    func shootPhoto()
    //----------------------------------------------------------------------------------------------------------
    {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            TSMessage.showNotificationWithTitle("No Camera", subtitle: "Whistle needs access to the camera.", type: TSMessageNotificationType.Error)
        }
    }
    
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return rowCount
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 3 {
            SwiftSpinner.show("Directing To\nFacebook...")
            view.userInteractionEnabled = false
            PFFacebookUtils.linkUserInBackground(self.user!, withReadPermissions: self.permissions, block: { (success, error) -> Void in
                if success {
                    self.needEdit = true
                    self.rowCount = 2
                    self.getFBUserData()
                } else {
                    SwiftSpinner.hide()
                    self.view.userInteractionEnabled = true
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            view.userInteractionEnabled = false
            PFTwitterUtils.linkUser(self.user!, block: { (success, error) -> Void in
                if success {
                    self.needEdit = true
                    self.rowCount = 2
                    self.getTwitterUserData()
                } else {
                    self.view.userInteractionEnabled = true
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }
    
    // ImagePicker delegates
    // What to do when the picker returns with a photo
    //----------------------------------------------------------------------------------------------------------
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    //----------------------------------------------------------------------------------------------------------
    {
        var chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.profileImage.image = Image.cropToSquare(image: chosenImage)
        self.profileImage.layer.cornerRadius = self.profileImage.layer.frame.height/2
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.masksToBounds = true
        self.needEdit = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //What to do if the image picker cancels.
    //----------------------------------------------------------------------------------------------------------
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    //----------------------------------------------------------------------------------------------------------
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Limit the length of textField
    //----------------------------------------------------------------------------------------------------------
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    //----------------------------------------------------------------------------------------------------------
    {
        if (range.length + range.location > count(textField.text) ) { return false }
        let newLength = count(textField.text) + count(string) - range.length
        if newLength <= Constants.Limit.Name {
            nameCount.text = "\(newLength)/\(Constants.Limit.Name)"
        }
        return newLength <= Constants.Limit.Name
    }
    
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
}










