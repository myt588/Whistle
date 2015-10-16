//
//  FavorDetailTable.swift
//  Whistle
//
//  Created by Lu Cao on 6/24/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import AVFoundation
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class FavorShowDetailTable: UITableViewController, WEImageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    @IBOutlet weak var ownerPortrait                                : WEImageView!
    @IBOutlet weak var assistantPortrait                            : WEImageView!
    @IBOutlet weak var favorUserName                                : WEContentLabel!
    @IBOutlet weak var assistantUserName                            : WEContentLabel!
    @IBOutlet weak var favorUserLabel                               : WEContentLabel!
    @IBOutlet weak var assistantUserLabel                           : WEContentLabel!
    @IBOutlet weak var favorStatusIcon                              : WEHeaderIcon!
    // Voice
    @IBOutlet weak var voiceView                                    : FSVoiceBubble!
    @IBOutlet weak var voiceLengthCons                              : NSLayoutConstraint!
    
    @IBOutlet weak var priceLabel                                   : UILabel!
    @IBOutlet weak var rewardLabel                                  : UILabel!
    @IBOutlet weak var favorLabel                                   : UILabel!
    @IBOutlet weak var addressLabel                                 : WEContentLabel!
    @IBOutlet weak var image0                                       : UIImageView!
    @IBOutlet weak var image1                                       : UIImageView!
    @IBOutlet weak var image2                                       : UIImageView!
    @IBOutlet weak var image3                                       : UIImageView!
    @IBOutlet weak var image4                                       : UIImageView!
    @IBOutlet weak var image5                                       : UIImageView!
    @IBOutlet weak var image6                                       : UIImageView!
    @IBOutlet weak var image7                                       : UIImageView!
    @IBOutlet weak var image8                                       : UIImageView!
    
    // MARK: - Variables
    
    //----------------------------------------------------------------------------------------------------------
    // Parse
    //----------------------------------------------------------------------------------------------------------
    var favor                                                       : PFObject!
    var ownerPF                                                     : PFUser?
    var assistantPF                                                 : PFUser?
    //----------------------------------------------------------------------------------------------------------
    // Images
    //----------------------------------------------------------------------------------------------------------
    var images                                                      = [UIImage]()
    var imageViews                                                  = [UIImageView]()
    var imageViewHeight                                             : CGFloat = 100
    //----------------------------------------------------------------------------------------------------------
    //Control
    //----------------------------------------------------------------------------------------------------------
    var noVoice                                                     : Bool = false
    var noPrice                                                     : Bool = false
    var noContent                                                   : Bool = false
    var noReward                                                    : Bool = false
    var noImage                                                     : Bool = true
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        var portraits = [ownerPortrait, assistantPortrait]
        for element in portraits {
            element.layer.borderColor = Constants.Color.Border.CGColor
            element.layer.borderWidth = 3
            element.layer.cornerRadius = 40
            element.clipsToBounds = true
            element.delegate = self
        }
        var userLabels = [favorUserLabel, assistantUserLabel]
        for element in userLabels {
            element.backgroundColor = Constants.Color.ContentBackground
            element.layer.cornerRadius = 8
            element.clipsToBounds = true
        }
        favorStatusIcon.backgroundColor = Constants.Color.Border
        favorStatusIcon.layer.cornerRadius = 15
        favorStatusIcon.clipsToBounds = true
        addGestures()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        bindData(favor)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    
    // MARK: - IBActions
    
    // MARK: - User Interactions
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        imageViews = [image0, image1, image2, image3, image4, image5, image6, image7, image8]
        for element in imageViews {
            var tap = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
            element.addGestureRecognizer(tap)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func respondToTapGesture(sender: UITapGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        var imageInfo = JTSImageInfo()
        imageInfo.image = image0.image!
        imageInfo.referenceRect = view.frame
        imageInfo.referenceView = view
        var imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        imageViewer.showFromViewController(self.parentViewController, transition: JTSImageViewControllerTransition._FromOriginalPosition)
    }
    
    
    // MARK: - Functionalities
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor : PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        if let favor = favor {
            switch favor[Constants.Favor.Status] as! Int {
            case 0, 1:  // waiting
                favorStatusIcon.image = UIImage(named: "favor_detail_status_waiting")
            case 2, 3:  // processing
                favorStatusIcon.image = UIImage(named: "favor_detail_status_processing")
            case 4:     // finished
                favorStatusIcon.image = UIImage(named: "favor_detail_status_finished")
            case 5, 6:  // cancelled
                favorStatusIcon.image = UIImage(named: "favor_detail_status_cancelled")
            default:
                break
            }

            if let owner = favor[Constants.Favor.CreatedBy] as? PFUser {
                ownerPF = owner
                ownerPortrait.tag = 1
                ownerPortrait.receiveUser(ownerPortrait)
                self.favorUserName.text = owner[Constants.User.Nickname] as? String
                var image = owner[Constants.User.Portrait] as! PFFile
                image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if let data = data {
                        self.ownerPortrait.image = UIImage(data: data)
                        self.ownerPortrait.tag = 1
                    } else {
                        println("network error")
                    }
                })
            }
            
            if let assistant = favor[Constants.Favor.AssistedBy] as? PFUser {
                assistantPF = assistant
                assistantPortrait.tag = 2
                assistantPortrait.receiveUser(assistantPortrait)
                assistant.fetchIfNeededInBackgroundWithBlock({ (assistant, error) -> Void in
                    if let assistant = assistant as? PFUser
                    {
                        self.assistantUserName.text = assistant[Constants.User.Nickname] as? String
                        var image = assistant[Constants.User.Portrait] as! PFFile
                        image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if let data = data {
                                self.assistantPortrait.image = UIImage(data: data)
                            } else {
                                println("network error")
                            }
                        })
                    }
                })
            } else {
                self.assistantPortrait.image = UIImage(named: "portrait_waiting")
                self.assistantPortrait.backgroundColor = Constants.Color.ContentBackground
                self.assistantPortrait.clipsToBounds = true
                self.assistantPortrait.userInteractionEnabled = false
                self.assistantUserName.text = "Waiting..."
            }
            
            if let address = favor[Constants.Favor.Address] as? String {
                self.addressLabel.text = address
            }
            
            if let content = favor[Constants.Favor.Content] as? String {
                self.favorLabel.text = content
                self.noContent = false
            } else {
                self.noContent = true
            }
            
            if let reward = favor[Constants.Favor.Reward] as? String {
                self.rewardLabel.text = reward
                self.noReward = false
            } else {
                self.noReward = true
            }
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile {
                self.noVoice = false
                audio.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    let audioManager = AudioManager()
                    let name = audioNameWithDate()
                    audioManager.saveAudio(data!, name: name)
                    let url = audioManager.audioURLWithName(name)
                    self.voiceView.contentURL = url
                    var asset = AVURLAsset(URL: audioManager.audioURLWithName(name), options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
                    var duration: CMTime = asset.duration
                    var seconds = Int(CMTimeGetSeconds(duration))
                    self.voiceLengthCons.constant = 50 + CGFloat(seconds)*1.67
                })
            } else {
               self.noVoice = true
            }
            
            if let price = favor[Constants.Favor.Price] as? Int {
                if price == 0 {
                    self.noPrice = true
                } else {
                    self.noPrice = false
                    self.priceLabel.text = "\(price)"
                }
            } else {
                self.noPrice = true
            }
            
            self.noImage = true
            images = [UIImage]()
            configImageViews()
            if let images = favor[Constants.Favor.Image] as? NSArray {
                self.noImage = false
                for image in images {
                    image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            let imagee = UIImage(data: data!)
                            self.images.append(imagee!)
                            if self.images.count == images.count {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.configImageViews()
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
                }
            } else {
                self.noImage = true
                self.tableView.reloadData()
            }
        }
        tableView.setContentOffset(CGPointMake(0, -self.tableView.contentInset.top), animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Images
    //----------------------------------------------------------------------------------------------------------
    func configImageViews()
    //----------------------------------------------------------------------------------------------------------
    {
        imageViews = [image0, image1, image2, image3, image4, image5, image6, image7, image8]
        for (index, element) in enumerate(imageViews) {
            element.layer.borderColor                               = Constants.Color.ContentBackground.CGColor
            element.layer.borderWidth                               = 1
            element.layer.cornerRadius                              = 8
            if index <= images.count-1 {
                element.hidden = false
                element.image = images[index]
            } else {
                element.hidden = true
            }
        }
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Images
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Delegations
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return noVoice ? 0 : 1
        case 3:
            return noPrice ? 0 : 1
        case 4:
            return noReward ? 0 : 1
        case 5:
            return noContent ? 0 : 1
        case 6:
            return 1
        case 7:
            return noImage ? 0 : 1
        case 8:
            return noImage ? 1 : 0
        default:
            return 0
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //----------------------------------------------------------------------------------------------------------
    {
        switch indexPath.section {
        case 0:
            return 210
        case 1:
            return 35
        case 2:
            return 100
        case 3:                                                     // Price
            return 85
        case 4:                                                     // Reward
            return calculateHeightForString(rewardLabel.text!) + 85
        case 5:                                                     // Favor
            return calculateHeightForString(favorLabel.text!) + 85
        case 6:                                                     // Address
            return calculateHeightForString(addressLabel.text!) + 85
        case 7:                                                     // Images
            var rows: CGFloat?
            switch images.count {
            case 0:
                rows = 0
            case 1...3:
                rows = 1
            case 4...6:
                rows = 2
            case 7...9:
                rows = 3
            default:
                break
            }
            var imageViewsHeight = 30 + imageViewHeight * rows!
            return imageViewsHeight
        default:
            return 44
        }
    }
    
    func passUser() -> PFUser? {
        return nil
    }
    
    func passUser(sender: UIImageView) -> PFUser? {
        switch sender.tag {
        case 1:
            return ownerPF
        case 2:
            return assistantPF
        default:
            sender.userInteractionEnabled = false
            return nil
        }
    }
    
    
}










