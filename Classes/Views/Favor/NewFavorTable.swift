//
//  NewFavorTable.swift
//  Whistle
//
//  Created by Lu Cao on 6/26/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import AVFoundation
import Foundation
import Photos
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class NewFavorTable: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - Public Variable
    var tags: [PFObject] = [PFObject]()

    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Location
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var locationIcon                             : UIImageView!
    @IBOutlet weak var locationLine                             : UIView!
    @IBOutlet weak var locationHeader                           : UILabel!
    @IBOutlet weak var pickLocationButton                       : UIButton!
    @IBOutlet weak var addressLabel                             : UILabel!
    @IBOutlet weak var aptTextField                             : UITextField!
    @IBOutlet weak var descTextField                            : UITextField!
    //----------------------------------------------------------------------------------------------------------
    // Tags
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var tagCollectionView                        : WETagCollectionView!
    //----------------------------------------------------------------------------------------------------------
    // Audio
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var audioIcon                                : UIImageView!
    @IBOutlet weak var audioLine                                : UIView!
    @IBOutlet weak var audioHeader                              : UILabel!
    @IBOutlet weak var recordButton                             : UIButton!
    @IBOutlet weak var deleteAudioButton                        : UIButton!
    @IBOutlet weak var audioView                                : FSVoiceBubble!
    //----------------------------------------------------------------------------------------------------------
    // Favor
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var favorIcon                                : UIImageView!
    @IBOutlet weak var favorLine                                : UIView!
    @IBOutlet weak var favorHeader                              : UILabel!
    @IBOutlet weak var favorHideButton                          : UIButton!
    @IBOutlet weak var favorTextView                            : UITextView!
    @IBOutlet weak var favorCharCountLabel                      : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Reward
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var rewardIcon                               : UIImageView!
    @IBOutlet weak var rewardLine                               : UIView!
    @IBOutlet weak var rewardHeader                             : UILabel!
    @IBOutlet weak var rewardHideButton                         : UIButton!
    @IBOutlet weak var rewardCharCountLabel                     : UILabel!
    @IBOutlet weak var rewardTextView                           : UITextView!
    //----------------------------------------------------------------------------------------------------------
    // Photos
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var photosIcon                               : UIImageView!
    @IBOutlet weak var photosLine                               : UIView!
    @IBOutlet weak var photosHeader                             : UILabel!
    @IBOutlet weak var photo1                                   : UIImageView!
    @IBOutlet weak var photo2                                   : UIImageView!
    @IBOutlet weak var photo3                                   : UIImageView!
    @IBOutlet weak var photo4                                   : UIImageView!
    @IBOutlet weak var photo5                                   : UIImageView!
    @IBOutlet weak var photo6                                   : UIImageView!
    @IBOutlet weak var photo7                                   : UIImageView!
    @IBOutlet weak var photo8                                   : UIImageView!
    @IBOutlet weak var photo9                                   : UIImageView!
    @IBOutlet weak var photosParentView                         : UIView!
    @IBOutlet weak var photoCountLabel                          : UILabel!
    // Constraints
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var audioViewLengthCons                      : NSLayoutConstraint!
    @IBOutlet weak var favorContentTopCons                      : NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var waveformView                                    = SiriWaveformView()
    private var recordingView                                   = UIView()
    private var hasRecording                                    = false
    private var audioRecorder                                   : AudioRecorder = AudioRecorder()
    private var audioManager                                    : AudioManager = AudioManager()
    private var name                                            : NSString = "Recording"
    
    private var imageNum                                        : Int = 0 {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    private var addPhotoButton                                  = UIButton()
    private var deletePhotoButtons                              = [UIButton]()
    private var images                                          = [UIImage]()
    private var imageViews                                      = [UIImageView]()

    private var location                                        : PFGeoPoint?
    private var address                                         : String?
    //----------------------------------------------------------------------------------------------------------
    private var addressIsHidden                                 : Bool = true
    private var favorContentIsHidden                            : Bool = true
    private var rewardContentIsHidden                           : Bool = true
    //----------------------------------------------------------------------------------------------------------
    private var isaudioViewHidden                               : Bool = true
    { didSet { tableView.reloadData() } }
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initialzations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        
        configTags()
        configLooks()
        configAudio()
        addGestures()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationPicked:", name: "locationPicked", object: nil)
//        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(true)
        if PFUser.currentUser() == nil {
            ParseErrorHandler.LoginUser(self)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        configShape()
    }
    
    // MARK: - NSNotification Passing Data
    //----------------------------------------------------------------------------------------------------------
    func locationPicked(notification : NSNotification) {
    //----------------------------------------------------------------------------------------------------------
        if notification.name == "locationPicked" {
            let location = notification.object as! Location
            self.addressLabel.text = location.formattedAddress
            self.aptTextField.alpha = 1
            self.address = location.formattedAddress
            self.location = PFGeoPoint(latitude: location.latitude!, longitude: location.longtitude!)
            
            addressIsHidden = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    // START: - Tab Bar Items
    //----------------------------------------------------------------------------------------------------------
    @IBAction func send(sender: UIBarButtonItem)
    //----------------------------------------------------------------------------------------------------------
    {
        var selectedTags = [String]()
        if tagCollectionView._totalTagsSelected > 0
        {
            for tag in tagCollectionView.tags
            {
                if tag.selected
                {
                    selectedTags.append(tag.textContent)
                }
            }
        }
        
        if let user = PFUser.currentUser() {
            if (user[Constants.User.Gender] as! Int) == 1 {
                selectedTags.append("dude")
            } else {
                selectedTags.append("girl")
            }
        }
        
        var favor : PFObject = PFObject(className: Constants.Favor.Name)
        var fileImage : PFFile
        var fileAudio : PFFile
        var audioOrText : Bool = false
        
        if let location = self.location {
            favor[Constants.Favor.Location] = location
            if aptTextField.text != "" {
                address = aptTextField.text + ", " + address!
            }
            if descTextField.text != "" {
                address = descTextField.text + ", " + address!
            }
            favor[Constants.Favor.Address] = address
        } else {
            MessageHandler.message(MessageName.NoLocation, vc: self.navigationController)
            return
        }
        
        favor[Constants.Favor.Tag] = selectedTags
        
        if self.favorTextView.text != "" && self.favorTextView.text != Constants.PlaceHolder.NewFavor {
            audioOrText = true
            favor[Constants.Favor.Content] = self.favorTextView.text
        }
        
        if self.rewardTextView.text != "" && self.rewardTextView.text != Constants.PlaceHolder.NewReward {
            favor[Constants.Favor.Reward] = self.rewardTextView.text
        }
        
        if let audio = audioManager.audioWithName(name) {
            audioOrText = true
            let fileAudio = PFFile(name: "Recording.m4a", data: audio)
            fileAudio.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
                if success {
                    println("Audio success")
                } else {
                    println("error" )
                }
            }
            favor[Constants.Favor.Audio] = fileAudio
        }
        
        if !audioOrText {
            MessageHandler.message(MessageName.NoAudioOrText, vc: self.navigationController)
            return
        }
        
        for element in imageViews {
            if element.alpha == 1 {
                images.append(element.image!)
            }
        }
        
        if self.images.count != 0 {
            for image in images {
                let data = image.mediumQualityJPEGNSData
                if data.length > 10000000 {
                    println("file size too big")
                    break
                }
                fileImage = PFFile(name: "picture.jpg", data: data)
                fileImage.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
                    if success {
                        println("Image success")
                    } else {
                        println("error")
                    }
                }
                var imageObject = PFObject(className: Constants.Image.Name)
                imageObject[Constants.Image.File] = fileImage
                imageObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        println("Image saved")
                    }
                })
                favor.addObject(fileImage, forKey: Constants.Favor.Image)
            }
        }
        
        favor[Constants.Favor.Status] = 0
        favor[Constants.Favor.CreatedBy] = PFUser.currentUser()
        
        ProgressHUD.show("Posting Favor...", interaction: false)
        self.view.userInteractionEnabled = false
        
        favor.saveInBackgroundWithBlock {
            (success : Bool, error : NSError?) -> Void in
            if (success) {
                ProgressHUD.dismiss()
                self.view.userInteractionEnabled = true
                self.dismissViewControllerAnimated(true, completion: nil)
                MessageHandler.message(MessageName.FavorPosted)
                PostNotification("currentLocationFound")
            } else {
                ParseErrorHandler.handleParseError(error)
                ProgressHUD.dismiss()
                self.view.userInteractionEnabled = true
            }
        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------
    @IBAction func cancel(sender: UIBarButtonItem)
    //----------------------------------------------------------------------------------------------------------
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Tab Bar Items
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Audio
    //----------------------------------------------------------------------------------------------------------
    @IBAction func deleteAudioButtonTapped(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        audioView.alpha = 0
        sender.alpha = 0
        
        hasRecording = false
        audioManager.removeAudioWithName(name)
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Audio
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Favor & Reward
    //----------------------------------------------------------------------------------------------------------
    @IBAction func toggleHidden(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        switch sender.tag {
        case 1:
            if favorContentIsHidden {
//                favorContentTopCons.active = true
                favorHideButton.setTitle("Skip", forState: .Normal)
                favorTextView.alpha = 1
            } else {
//                favorContentTopCons.active = false
                favorHideButton.setTitle("Compose", forState: .Normal)
                favorTextView.alpha = 0
            }
            favorContentIsHidden = !favorContentIsHidden
        case 2:
            if rewardContentIsHidden {
                rewardHideButton.setTitle("Skip", forState: .Normal)
                rewardTextView.alpha = 1
            } else {
                rewardHideButton.setTitle("Compose", forState: .Normal)
                rewardTextView.alpha = 0
            }
            rewardContentIsHidden = !rewardContentIsHidden
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Favor
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - User Interactions
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
//        var tap = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
//        tableView.addGestureRecognizer(tap)
        
        var buttonLongPressGuesture = UILongPressGestureRecognizer(target: self, action: "handleButtonLongPressGuesture:")
        recordButton.addGestureRecognizer(buttonLongPressGuesture)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func respondToTapGesture(gesture: UIGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        view.endEditing(true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func handleButtonLongPressGuesture(recognizer: UILongPressGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        //as you hold the button this would fire
        if recognizer.state == UIGestureRecognizerState.Began {
            
            self.audioManager.removeAudioWithName(name)
            name = audioNameWithDate()
            self.audioRecorder.initRecorder(name)
            self.audioRecorder.startRecording()
            // add waveform view
            var window = UIApplication.sharedApplication().delegate?.window
            window!?.addSubview(self.recordingView)
        }
        
        // as you release the button this would fire
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            self.audioRecorder.stopRecordng()
            // remove waveform view
            recordingView.removeFromSuperview()
            hasRecording = true
            
            isaudioViewHidden = false
        
            audioView.contentURL = audioManager.audioURLWithName(name)
            
            var asset = AVURLAsset(URL: audioManager.audioURLWithName(name), options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
            var duration: CMTime = asset.duration
            var seconds = Int(CMTimeGetSeconds(duration))
            
            audioViewLengthCons.constant = 50 + CGFloat(seconds)*1.67
            
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.audioView.alpha = 1
                self.deleteAudioButton.alpha = 1
            }, completion: nil)
            
            
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        var buttons = [pickLocationButton]
        for element in buttons {
            element.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            element.backgroundColor = UIColor.whiteColor()
            element.layer.cornerRadius = 12.5
            element.tintColor = Constants.Color.Main
        }
        
        deleteAudioButton.alpha                                     = 0
        
        favorTextView.tag = 1
        rewardTextView.tag = 2
        var textViews = [favorTextView, rewardTextView]
        for element in textViews {
            element.delegate                                        = self
            element.textContainerInset                              = UIEdgeInsetsMake(10, 8, 10, 8)
            element.textColor                                       = Constants.Color.PlaceHolder
            element.backgroundColor                                 = Constants.Color.ContentBackground
            element.layer.cornerRadius                              = 8
            element.alpha = 0
            if element.tag == 1 {
                element.text                                        = Constants.PlaceHolder.NewFavor
            }
            if element.tag == 2 {
                element.text                                        = Constants.PlaceHolder.NewReward
            }
        }
        
        var locationFields = [aptTextField, descTextField]
        for element in locationFields {
            element.textColor                                  = Constants.Color.CellText
            element.attributedPlaceholder = NSAttributedString(string:element.placeholder!, attributes:[NSForegroundColorAttributeName: Constants.Color.PlaceHolder])
            element.backgroundColor = Constants.Color.ContentBackground
        }
        
        tagCollectionView.backgroundColor                           = UIColor.clearColor()
        
        favorHideButton.tag = 1
        rewardHideButton.tag = 2
        var hideButtons = [favorHideButton, rewardHideButton]
        for element in hideButtons {
            element.setTitleColor(Constants.Color.Main2, forState: .Normal)
        }
        
        imageViews = [photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9]
        for element in imageViews {
            element.layer.borderColor                               = Constants.Color.ContentBackground.CGColor
            element.layer.borderWidth                               = 1
            element.layer.cornerRadius                              = 8
            element.alpha                                           = 0
            element.clipsToBounds                                   = true
            var deleteButton                                        = UIButton(frame: CGRectMake(0, 0, 22, 22))
            deleteButton.layer.cornerRadius                         = 11
            deleteButton.setImage(UIImage(named: "favor_new_delete"), forState: .Normal)
            deleteButton.addTarget(self, action: "deletePhoto:", forControlEvents: .TouchUpInside)
            let deletePhotoOrigImage                                = deleteButton.imageView?.image
            let deletePhotoTintedImage                              = deletePhotoOrigImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            deleteButton.setImage(deletePhotoTintedImage, forState: .Normal)
            deleteButton.tintColor                                  = Constants.Color.CellText
            deleteButton.backgroundColor                            = Constants.Color.ContentBackground
            deleteButton.alpha                                      = 0
            photosParentView.addSubview(deleteButton)
            deletePhotoButtons.append(deleteButton)
        }
        
        addPhotoButton                                              = UIButton(frame: CGRectZero)
        addPhotoButton.clipsToBounds                                = true
        addPhotoButton.setImage(UIImage(named: "favor_new_add_photo"), forState: .Normal)
        addPhotoButton.addTarget(self, action: "addPhoto", forControlEvents: .TouchUpInside)
        addPhotoButton.layer.cornerRadius                           = 8
        let addPhotoOrigImage                                       = addPhotoButton.imageView?.image
        let addPhotoTintedImage                                     = addPhotoOrigImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        addPhotoButton.setImage(addPhotoTintedImage, forState: .Normal)
        addPhotoButton.tintColor                                    = Constants.Color.CellText
        addPhotoButton.backgroundColor                              = favorTextView.backgroundColor
        photosParentView.addSubview(addPhotoButton)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configShape()
    //----------------------------------------------------------------------------------------------------------
    {
        var buttonList = [recordButton]
        for element in buttonList {
            element.layer.cornerRadius                             = element.layer.frame.height/2
            element.backgroundColor                                = Constants.Color.Border
            let origImage                                          = element.imageView?.image
            let tintedImage                                        = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            element.setImage(tintedImage, forState: .Normal)
            element.tintColor                                      = Constants.Color.Main2
        }
        
        if imageNum == 0 {
            addPhotoButton.layer.frame = imageViews[imageNum].layer.frame
            addPhotoButton.layer.frame.origin = imageViews[imageNum].layer.frame.origin
        }
    }
    
    func configTags()
    {
        for currentTag in tags {
            let name = currentTag["name"] as! String
            tagCollectionView.tags.append(Tag(selected: false, isLocked: false, textContent: name))
        }
    }
    
    func configAudio()
    {
        name = audioNameWithDate()
        audioRecorder.initRecorder(name)
        audioView.alpha = 0
        initWaveformView()
        initRecordingView()
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Record Audio
    //----------------------------------------------------------------------------------------------------------
    func initWaveformView()
    //----------------------------------------------------------------------------------------------------------
    {
        var displaylink = CADisplayLink(target: self, selector: "updateWaveform")
        displaylink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        waveformView.primaryWaveLineWidth = 3.0
        waveformView.secondaryWaveLineWidth = 1.0
        
        waveformView.frame = UIScreen.mainScreen().applicationFrame
        waveformView.backgroundColor = UIColor.blackColor()
        waveformView.alpha = 0.75
    }
    
    //----------------------------------------------------------------------------------------------------------
    func updateWaveform()
    //----------------------------------------------------------------------------------------------------------
    {
        self.audioRecorder.audioRecorder?.updateMeters()
        var normalizedValue = pow(10, self.audioRecorder.audioRecorder!.averagePowerForChannel(0) / 20)
        waveformView.updateWithLevel(CGFloat(normalizedValue))
    }
    
    //----------------------------------------------------------------------------------------------------------
    func initRecordingView()
    //----------------------------------------------------------------------------------------------------------
    {
        // add waveform to this subview
        recordingView.addSubview(waveformView)
        
        // add label to this subview
        var label = UILabel(frame: CGRectMake(20, 0, 300, 21))
        label.layer.frame.origin.y += 100
        label.textColor = UIColor.whiteColor()
        label.text = "Release finger to finish recording"
        recordingView.addSubview(label)
        recordingView.bringSubviewToFront(label)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Photos
    //----------------------------------------------------------------------------------------------------------
    func addPhoto()
    //----------------------------------------------------------------------------------------------------------
    {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
            }
            return
        }
        
        if authorization == .Authorized {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    MessageHandler.message(.NoCamera, vc: self.navigationController)
                }
                controller.sourceType = sourceType
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add Photo(s)", comment: "Action Title"), handler: { _ in
                presentImagePickerController(.Camera)
                }, secondaryHandler: { _, numberOfPhotos in
                    controller.getSelectedImagesWithCompletion() { images in
                        self.configImageView(images)
                    }
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: NSLocalizedString("Photo Library", comment: "Action Title"), handler: { _ in
                presentImagePickerController(.PhotoLibrary)
                }, secondaryHandler: { _, numberOfPhotos in
                    presentImagePickerController(.PhotoLibrary)
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                println("Cancelled")
            }))
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else {
            MessageHandler.message(.CameraAccess, vc: self.navigationController)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configImageView(selectedImages: [UIImage?])
    //----------------------------------------------------------------------------------------------------------
    {
        for element in selectedImages {
            if imageNum < 8 {
                imageViews[imageNum].image                              = element
                imageViews[imageNum].alpha                              = 1
                
                deletePhotoButtons[imageNum].alpha                      = 1
                deletePhotoButtons[imageNum].layer.frame.origin         = CGPointMake(imageViews[imageNum].layer.frame.origin.x - 5, imageViews[imageNum].layer.frame.origin.y - 5)
                deletePhotoButtons[imageNum].tag                        = imageNum
                
                imageNum++
                addPhotoButton.layer.frame                              = imageViews[imageNum].layer.frame
                addPhotoButton.layer.frame.origin                       = imageViews[imageNum].layer.frame.origin
            } else if imageNum < 9 {
                imageViews[imageNum].image                              = element
                imageViews[imageNum].alpha                              = 1
                
                deletePhotoButtons[imageNum].alpha                      = 1
                deletePhotoButtons[imageNum].layer.frame.origin         = CGPointMake(imageViews[imageNum].layer.frame.origin.x - 5, imageViews[imageNum].layer.frame.origin.y - 5)
                deletePhotoButtons[imageNum].tag                        = imageNum
                
                imageNum++
                addPhotoButton.alpha                                    = 0
            }
            photoCountLabel.text                                        = "\(imageNum)/9"
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func deletePhoto(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        imageNum--
        imageViews[imageNum].alpha                     = 0
        deletePhotoButtons[imageNum].alpha             = 0
        addPhotoButton.alpha                           = 1
        addPhotoButton.layer.frame                     = imageViews[imageNum].layer.frame
        addPhotoButton.layer.frame.origin              = imageViews[imageNum].layer.frame.origin
        photoCountLabel.text                           = "\(imageNum)/9"
        for index in sender.tag...imageNum {
            imageViews[index].image = imageViews[index+1].image
        }
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Photos
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //----------------------------------------------------------------------------------------------------------
    {
        switch indexPath.section {
        case 0:                                             // Location
            return addressIsHidden ? 100 : calculateHeightForString(addressLabel.text!) + 135
        case 1:                                             // Tag
            return 150
        case 2:                                             // Audio
            return 120
        case 3:                                             // Favor
            return favorContentIsHidden ? 80 : 250
        case 4:                                             // Reward
            return rewardContentIsHidden ? 80 : 250
        case 5:                                             // Photos
            var rows: CGFloat?
            switch imageNum {
            case 0...2:
                rows = 1
            case 3...5:
                rows = 2
            case 6...9:
                rows = 3
            default:
                break
            }
            var imageViewsHeight = 100 + 100 * rows!
            return imageViewsHeight
        default:
            return 44
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func textViewDidBeginEditing(textView: UITextView)
    //----------------------------------------------------------------------------------------------------------
    {
        if textView.tag == 1 {
            if textView.text == Constants.PlaceHolder.NewFavor {
                textView.text = ""
                textView.textColor = Constants.Color.CellText
            }
        }
        if textView.tag == 2 {
            if textView.text == Constants.PlaceHolder.NewReward {
                textView.text = ""
                textView.textColor = Constants.Color.CellText
            }
        }
        textView.becomeFirstResponder()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func textViewDidEndEditing(textView: UITextView)
    //----------------------------------------------------------------------------------------------------------
    {
        if textView.tag == 1 {
            if textView.text == "" {
                textView.text = Constants.PlaceHolder.NewFavor
                textView.textColor = Constants.Color.CellPlaceHolder
            }
        }
        if textView.tag == 2 {
            if textView.text == "" {
                textView.text = Constants.PlaceHolder.NewReward
                textView.textColor = Constants.Color.CellPlaceHolder
            }
        }
        textView.resignFirstResponder()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    //----------------------------------------------------------------------------------------------------------
    {
        let num: Int = count(textView.text)
        if textView.tag == 1 {                                      // Favor
            if num - range.length + count(text) > Constants.Limit.Favor {
                return false
            } else {
                favorCharCountLabel.text = "\(num - range.length + count(text))/\(Constants.Limit.Favor)"
                return true
            }
        }
        if textView.tag == 2 {                                      // Reward
            if num - range.length + count(text) > Constants.Limit.Reward {
                return false
            } else {
                rewardCharCountLabel.text = "\(num - range.length + count(text))/\(Constants.Limit.Reward)"
                return true
            }
        }
        return true
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    //----------------------------------------------------------------------------------------------------------
    {
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.configImageView([image])
    }
    
}










