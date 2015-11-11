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
class ProfilePersonalSettingTable: UITableViewController, UINavigationControllerDelegate, OLFacebookImagePickerControllerDelegate, RSKImageCropViewControllerDelegate
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Information
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portrait                             : WEProfileView!
    @IBOutlet weak var nameKeyLabel                         : UILabel!
    @IBOutlet weak var genderKeyLabel                       : UILabel!
    @IBOutlet weak var regionKeyLabel                       : UILabel!
    @IBOutlet weak var statusKeyLabel                       : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var user                                        : PFUser!
    private var facebookPicker                              = OLFacebookImagePickerController()
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        facebookPicker.delegate = self
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
    func bindData(user: PFUser)
    //----------------------------------------------------------------------------------------------------------
    {
        self.portrait.loadImage(user)
        self.portrait.useDefault = true
        self.portrait.canTap = false
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
    
    // #Mark: Delegates
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            self.presentViewController(facebookPicker, animated: true, completion: nil)
        }
        if indexPath.row == 4 {
            genderAlert()
        }
        if indexPath.row == 5 {
            var vc = storyboard?.instantiateViewControllerWithIdentifier("RegionPicker") as! ProfileRegionPicker
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController!, didFinishPickingImages images: [AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func facebookImagePickerDidCancelPickingImages(imagePicker: OLFacebookImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func facebookImagePicker(imagePicker: OLFacebookImagePickerController!, didSelectImage image: OLFacebookImage!) {
        requestFacebookPicture(image.fullURL.absoluteString!)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        self.facebookPicker.popViewControllerAnimated(true)
        println(self.facebookPicker.albumVC.photoViewController.selected)
    }
    
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        processFacebookImage(croppedImage)
    }
    
    func requestFacebookPicture(url: String)
    {
        ImageLoader.sharedLoader.imageForUrl(url, completionHandler:{(image: UIImage?, url: String) in
            if let image = image {
                let imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.Square)
                imageCropVC.delegate = self
                self.facebookPicker.pushViewController(imageCropVC, animated: true)
            } else {
                println("image download failed")
            }
        })
    }
    
    func processFacebookImage(image: UIImage) {
        var picture = Image.resizeImage(Image.cropToSquare(image: image), width: 300, height: 300)
        var thumbnail = Image.resizeImage(image, width: 60, height: 60)
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
                self.facebookPicker.popToRootViewControllerAnimated(false)
                self.facebookPicker.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println("network error")
            }
        })
    }
    
}
