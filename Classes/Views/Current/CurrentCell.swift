//
//  CurrentCell.swift
//  Whistle
//
//  Created by Yetian Mao on 10/28/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import ParseUI
import AVFoundation
import Foundation
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class CurrentCell: UITableViewCell
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portraitView                         : WECurrentImageView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var timeElapsedLabel                     : UILabel!
    @IBOutlet weak var coutLabel                            : UILabel!
    @IBOutlet weak var blurImage                            : WEBlurImageView!
    @IBOutlet weak var gifImageView                         : UIImageView!
    @IBOutlet weak var gifIconImageView                     : UIImageView!
    //----------------------------------------------------------------------------------------------------------
    // Content
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var confirmButton                        : UIButton!
    @IBOutlet weak var cancelButton                         : UIButton!
    @IBOutlet weak var chatButton                           : WEChatButton!
    @IBOutlet weak var reviewButton                         : WEReviewButton!
    @IBOutlet weak var shareButton                          : WEShareButton!
    
    @IBOutlet weak var midView                              : UIView!
    @IBOutlet weak var botView                              : UIView!
    
    private var row                                         : Int!
    private var pivot                                       : PFObject!
    private var pickAssistantTutorial                       = WETutorial()
    private var waitAssistantTutorial                       = WETutorial()
    private var confirmButtonTutorial                       = WETutorial()
    var favor                                               : PFObject!
    var vc                                                  : CurrentSwitcher?
    var table                                               : CurrentAssistantTable?
    
    private var timer                                       : NSTimer?
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
        self.timeElapsedLabel.text = ""
        self.nameLabel.text = ""
        self.chatButton.enabled = true
        self.reviewButton.enabled = false
        self.shareButton.enabled = true
        self.cancelButton.hidden = true
        self.confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.portraitView.isWaiting = true
        self.timer?.invalidate()
        self.pickAssistantTutorial.dismiss()
        self.waitAssistantTutorial.dismiss()
        self.confirmButtonTutorial.dismiss()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForReuse()
    //----------------------------------------------------------------------------------------------------------
    {
        self.timeElapsedLabel.text = ""
        self.coutLabel.text = ""
        self.cancelButton.hidden = true
        self.chatButton.enabled = true
        self.reviewButton.enabled = false
        self.shareButton.enabled = true
        self.confirmButton.backgroundColor = UIColor.clearColor()
        self.portraitView.isWaiting = true
        self.timer?.invalidate()
        self.pickAssistantTutorial.dismiss()
        self.waitAssistantTutorial.dismiss()
        self.confirmButtonTutorial.dismiss()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        contentView.clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        blurImage.addShade()
//        blurImage.addBlur()
        
//        midView.layer.shadowOffset = CGSize(width: 0, height: -3.5)
//        midView.layer.shadowOpacity = 0.85
//        
//        botView.layer.shadowOffset = CGSize(width: 0, height: -2.5)
//        botView.layer.shadowOpacity = 0.65
//        
//        portraitView.layer.shadowOffset = CGSize(width: 5, height: 5)
//        portraitView.layer.shadowOpacity = 0.65
//
        botView.backgroundColor = Constants.Color.ContentBackground.colorWithAlphaComponent(0.3)
        confirmButton.backgroundColor = UIColor.clearColor()
        confirmButton.layer.shadowColor = UIColor.blackColor().CGColor
        confirmButton.layer.shadowOffset = CGSizeMake(5, 5)
        confirmButton.layer.shadowRadius = 5
        confirmButton.layer.shadowOpacity = 1.0
//
        coutLabel.textColor = UIColor.whiteColor()
        coutLabel.layer.shadowColor = UIColor.blackColor().CGColor
        coutLabel.layer.shadowOffset = CGSizeMake(5, 5)
        coutLabel.layer.shadowRadius = 5
        coutLabel.layer.shadowOpacity = 1.0

//        gifIconImageView.contentMode = .ScaleAspectFill
//        gifIconImageView.image = UIImage.gifWithName("waiting_icon")
//        gifIconImageView.layer.shadowColor = UIColor.blackColor().CGColor
//        gifIconImageView.layer.shadowOffset = CGSizeMake(5, 5)
//        gifIconImageView.layer.shadowRadius = 5
//        gifIconImageView.layer.shadowOpacity = 0.65


//        var topBorder = UIView(frame: CGRectMake(0, 0, blurImage.frame.size.width, 20))
//        topBorder.backgroundColor = UIColor.redColor()
//        blurImage.addSubview(topBorder)

//        midView.backgroundColor = UIColorFromHex(0x261724, alpha: 0.35)
//        var darkBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
//        darkBlurView.frame = midView.bounds
//        midView.insertSubview(darkBlurView, atIndex: 0)
    }
    
    func bindFavor(favor : PFObject?, row: Int)
    {
        if let favor = favor {
            self.favor = favor
            self.row = row
            self.cancelButton.hidden = false
            self.cancelButton.addTarget(self, action: "cancel", forControlEvents: .TouchUpInside)
            let status = favor[Constants.Favor.Status] as! Int
            switch status {
            case 0:                                         // No Takers
                self.chatButton.enabled = false
                self.coutLabel.hidden = false
                self.coutLabel.text = "?"
                if self.portraitView.subviews.count == 1 {
                    self.portraitView.subviews.first?.removeFromSuperview()
                }
                self.portraitView.image = nil
                self.portraitView.canTap = false
                self.blurImage.loadImage(PFUser.currentUser()!)
                self.confirmButtonConfig(MessageName.Favor0.rawValue, action: nil)
                self.waitAssistantTutorial.waitForAssistantTutorial(self)
            case 1:                                         // Has Takers
                self.chatButton.enabled = false
                self.blurImage.loadImage(PFUser.currentUser()!)
                if self.portraitView.subviews.count == 1 {
                    self.portraitView.subviews.first?.removeFromSuperview()
                }
                self.portraitView.image = nil
                self.portraitView.canTap = false
                self.confirmButtonConfig(MessageName.Favor1.rawValue, action: nil)
                let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
                query.cachePolicy = PFCachePolicy.CacheThenNetwork
                query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                    if error == nil {
                        self.coutLabel.hidden = false
                        self.coutLabel.text = "\(count)"
                        self.portraitView.image = nil
                        self.pickAssistantTutorial.pickAssistantTutorial(self)
                        var tap = UITapGestureRecognizer(target: self, action: "showTakers")
                        self.coutLabel.addGestureRecognizer(tap)
//                        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "bounceCountLabel", userInfo: nil, repeats: true)
//                        self.confirmButtonConfig(MessageName.Favor1.rawValue, action: nil)
                    } else {
                        println("network error")
                    }
                })
            default:
                if status == 4 || status == 5 || status == 6 {
                    self.cancelButton.hidden = true
                }
                if status == 2 {
                    self.confirmButtonConfig(MessageName.Favor2.rawValue, action: "whistlerAccepted")
                    confirmButtonTutorial.confirmButtonTutorial(self)
                }
                if status == 4 {
                    self.confirmButtonConfig(MessageName.Favor4.rawValue, action: nil)
                }
                if status == 5 {
                    self.confirmButtonConfig(MessageName.Favor5.rawValue, action: nil)
                }
                self.reviewButton.enabled = true
                self.reviewButton.favor = favor
                let user: AnyObject? = favor[Constants.Favor.AssistedBy] == nil ? favor[Constants.Favor.CreatedBy] : favor[Constants.Favor.AssistedBy]
                bindData(user as? PFUser)
            }
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
        }
    }
    
    func bindInterest(favor: PFObject?, row: Int) {
        if let favor = favor {
            self.favor = favor
            self.row = row
            self.confirmButtonConfig(MessageName.CurrentInterest.rawValue, action: nil)
            bindData(favor[Constants.Favor.CreatedBy] as? PFUser)
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
        }
    }
    
    func bindAssist(favor: PFObject?, row: Int) {
        if let favor = favor {
            self.favor = favor
            self.row = row
            let status = favor[Constants.Favor.Status] as! Int
            switch status {
            case 4:
                self.confirmButtonConfig(MessageName.Assisted.rawValue, action: nil)
            case 5:
                self.confirmButtonConfig(MessageName.AssistCancel.rawValue, action: nil)
            default:
                self.confirmButtonConfig(MessageName.Assist.rawValue, action: nil)
            }
            self.reviewButton.enabled = true
            self.reviewButton.favor = favor
            bindData(favor[Constants.Favor.CreatedBy] as? PFUser)
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
        }
    }
    
    func bindAssistant(pivot: PFObject?) {
        if let pivot = pivot {
            self.pivot = pivot
            self.confirmButtonConfig(MessageName.AssistantHire.rawValue, action: "hire")
            bindData(pivot[Constants.FavorUserPivotTable.Takers] as? PFUser)
            timeElapsedLabel.text = pivot.updatedAt?.relativeTime
        }
    }
    
    func bindData(user: PFUser?) {
        if let user = user
        {
            user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user as? PFUser
                {
                    var name = user[Constants.User.Nickname] as? String
                    self.chatButton.user = user
                    self.coutLabel.hidden = true
                    self.nameLabel.text = "\(name!)"
                    self.portraitView.loadImage(user)
                    self.portraitView.canTap = true
                    self.portraitView.useDefault = true
                    self.blurImage.loadImage(user)
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }
    
    func confirmButtonConfig(title: String, action: Selector?) {
        let attr = [NSFontAttributeName : UIFont(name: "Thonburi-Bold", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        let string = NSAttributedString(string: title, attributes: attr)
        self.confirmButton.setAttributedTitle(string, forState: .Normal)
        self.confirmButton.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3)
        self.confirmButton.titleLabel?.numberOfLines = 1
        self.confirmButton.titleLabel?.adjustsFontSizeToFitWidth = true
        if action != nil {
            self.confirmButton.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
            self.confirmButton.backgroundColor = UIColorFromHex(0x7BBA37, alpha: 0.5)
            self.confirmButton.layer.cornerRadius = 8
        }
    }

    //----------------------------------------------------------------------------------------------------------
    func showTakers()
    //----------------------------------------------------------------------------------------------------------
    {
        vc!.selectedIndex = self.row
        vc!.performSegueWithIdentifier("Current_To_Assistant", sender: self)
    }

    func cancel()
    {
        if let vc = self.vc {
            let alert = WEAlertController(title: "Cancel", message: MessageName.CancelFavor.rawValue , style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 5
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.row)
                                vc.tableView.reloadData()
                            })
                        } else {
                            ParseErrorHandler.handleParseError(error)
                        }
                    })
                }
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func assistantDelivered()
    {
        if let vc = self.vc {
            let alert = WEAlertController(title: "Confirm", message: MessageName.AcceptAssist.rawValue, style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 3
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.row)
                                vc.tableView.reloadData()
                            })
                        } else {
                            ParseErrorHandler.handleParseError(error)
                        }
                    })
                }
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func whistlerAccepted() {
        if let vc = self.vc {
            let alert = WEAlertController(title: "Confirm", message: MessageName.AcceptAssist.rawValue, style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 4
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.row)
                                vc.tableView.reloadData()
                            })
                        } else {
                            ParseErrorHandler.handleParseError(error)
                        }
                    })
                }
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func hire()
    //----------------------------------------------------------------------------------------------------------
    {
        if let table = self.table {
            if let user = pivot[Constants.FavorUserPivotTable.Takers] as? PFUser {
                favor[Constants.Favor.AssistedBy] = user
                favor[Constants.Favor.Status] = 2
                if let ownerPrice = favor[Constants.Favor.Price] as? Int {
                    if let takerPrice = pivot[Constants.FavorUserPivotTable.Price] as? Int {
                        if ownerPrice != takerPrice {
                            favor[Constants.Favor.Price] = takerPrice
                        }
                    }
                }
                favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        SendPushNotification2([user.objectId!], "Has hired you", PF_INSTALLATION_WHISTLE)
                        table.navigationController?.popViewControllerAnimated(true)
                        MessageHandler.message(MessageName.Hired)
                    } else {
                        ParseErrorHandler.handleParseError(error)
                    }
                })
            }
        }
    }
    
    func bounceCountLabel() {
        bounceView(coutLabel)
    }
}


