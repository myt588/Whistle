//
//  ProfilePersonalSettingTable.swift
//  Whistle
//
//  Created by Lu Cao on 7/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Photos
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfilePersonalSettingTable: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Information
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portrait                             : UIImageView!
    @IBOutlet weak var nameKeyLabel                         : UILabel!
    @IBOutlet weak var genderKeyLabel                       : UILabel!
    @IBOutlet weak var regionKeyLabel                       : UILabel!
    @IBOutlet weak var statusKeyLabel                       : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var imagePicker                                 = UIImagePickerController()
    private var user                                        : PFUser!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        imagePicker.delegate = self
        configLooks()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let user = PFUser.currentUser() {
            self.title = "Personal Info"
            bindData(user)
            self.user = user
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    //----------------------------------------------------------------------------------------------------------
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        portrait.layer.borderColor                      = Constants.Color.Border.CGColor
        portrait.layer.borderWidth                      = 2
        portrait.layer.cornerRadius                     = 30
        portrait.backgroundColor                        = Constants.Color.Border
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(user: PFUser)
    //----------------------------------------------------------------------------------------------------------
    {
        var file = user[Constants.User.Portrait] as! PFFile
        file.getDataInBackgroundWithBlock({ (data, error) -> Void in
            if let data = data {
                self.portrait.image = UIImage(data: data)!
            }
        })
        
        self.nameKeyLabel.text = user[Constants.User.Nickname] as? String
        if let gender = user[Constants.User.Gender] as? Int {
            switch gender
            {
            case 0:
                self.genderKeyLabel.text = "Female"
            case 1:
                self.genderKeyLabel.text = "Male"
            default:
                self.genderKeyLabel.text = "Please pick a gender"
                break
            }
        }
        
        if let region = user[Constants.User.Region] as? String {
            self.regionKeyLabel.text = region
        }
        
        if let status = user[Constants.User.Status] as? String {
            self.statusKeyLabel.text = status
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Photo Picker
    //----------------------------------------------------------------------------------------------------------
    func pickPhoto()
    //----------------------------------------------------------------------------------------------------------
    {
        let alert = WEAlertController(title: "Photo", message: "select photo source", style: .ActionSheet)
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        alert.addAction(SimpleAlert.Action(title: "Camera", style: .Default) { action in
            self.shootPhoto()
            })
        alert.addAction(SimpleAlert.Action(title: "Photo Library", style: .Default) { action in
            self.photoFromLibrary()
            })
        presentViewController(alert, animated: true, completion: nil)
    }
    
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
    
    //----------------------------------------------------------------------------------------------------------
    // take a picture, check if we have a camera first.
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
            JSSAlertView().danger(self, title: "No Camera", text: "Sorry, this device has no camera", buttonText: "ok")
        }
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Photo Picker
    //----------------------------------------------------------------------------------------------------------
        
    //----------------------------------------------------------------------------------------------------------
    func genderAlert()
    //----------------------------------------------------------------------------------------------------------
    {
        let alert = WEAlertController(title: "Gender", message: "select your gender", style: .ActionSheet)
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        alert.addAction(SimpleAlert.Action(title: "Male", style: .OK) { action in
            if let user = PFUser.currentUser() {
                user[Constants.User.Gender] = 1
                self.genderKeyLabel.text = "Male"
                user.saveEventually({ (success, error) -> Void in
                    if success {
                        println("gender changed")
                    } else {
                        println("network error")
                    }
                })
            }
        })
        alert.addAction(SimpleAlert.Action(title: "Female", style: .OK) { action in
            if let user = PFUser.currentUser() {
                user[Constants.User.Gender] = 0
                self.genderKeyLabel.text = "Female"
                user.saveEventually({ (success, error) -> Void in
                    if success {
                        println("gender changed")
                    } else {
                        println("network error")
                    }
                })
            }
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    // What to do when the picker returns with a photo
    //----------------------------------------------------------------------------------------------------------
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    //----------------------------------------------------------------------------------------------------------
    {
        var chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.portrait.contentMode = UIViewContentMode.ScaleAspectFit
        self.portrait.image = Image.cropToSquare(image: chosenImage)
        dismissViewControllerAnimated(true, completion: nil)
        if let user = PFUser.currentUser() {
            var picture = Image.resizeImage(chosenImage, width: 300, height: 300)
            var thumbnail = Image.resizeImage(chosenImage, width: 60, height: 60)
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
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    println("saved successfully")
                } else {
                    println("network error")
                }
            })
            user.pinInBackground()
        } else {
            println("current user error")
        }
    }
    
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            pickPhoto()
        }
        if indexPath.row == 4 {
            genderAlert()
        }
        if indexPath.row == 5 {
            var vc = storyboard?.instantiateViewControllerWithIdentifier("RegionPicker") as! ProfileRegionPicker
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
}
