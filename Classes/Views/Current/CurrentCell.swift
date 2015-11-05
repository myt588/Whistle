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
    @IBOutlet weak var prizeView                            : WEPrizeView!
    @IBOutlet weak var coutLabel                            : UILabel!
    @IBOutlet weak var blurImage                            : WEBlurImageView!
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
    
    private var favor                                       : PFObject!
    private var row                                         : Int!
    var vc                                                  : CurrentSwitcher?
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
        self.timeElapsedLabel.text = ""
        self.nameLabel.text = ""
        self.chatButton.enabled = false
        self.reviewButton.enabled = false
        self.shareButton.enabled = true
        self.cancelButton.hidden = true
        self.confirmButton.backgroundColor = UIColor.orangeColor()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForReuse()
    //----------------------------------------------------------------------------------------------------------
    {
        self.timeElapsedLabel.text = ""
        self.portraitView.imageView = nil
        self.blurImage.imageView = nil
        self.cancelButton.hidden = true
        self.chatButton.enabled = false
        self.reviewButton.enabled = false
        self.shareButton.enabled = true
        self.cancelButton.hidden = true
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor = UIColor.clearColor()
        blurImage.clipsToBounds = true
        
        midView.backgroundColor = UIColorFromHex(0x261724, alpha: 0.65)
        var darkBlurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        darkBlurView.frame = midView.bounds
        midView.insertSubview(darkBlurView, atIndex: 0)
        
        midView.layer.shadowOffset = CGSize(width: -5, height: -5)
        midView.layer.shadowOpacity = 0.65
        
        portraitView.layer.shadowOffset = CGSize(width: 5, height: -5)
        portraitView.layer.shadowOpacity = 0.65
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
                self.coutLabel.hidden = true
                self.portraitView.image = UIImage(named: "user_unknown")
                self.portraitView.canTap = false
                self.blurImage.loadImage(PFUser.currentUser()!)
                self.confirmButtonConfig("Waiting...", action: nil)
            case 1:                                         // Has Takers
                self.blurImage.loadImage(PFUser.currentUser()!)
                self.portraitView.image = UIImage(named: "user_photo")
                self.portraitView.canTap = false
                let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
                query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                    if error == nil {
                        self.coutLabel.hidden = false
                        self.coutLabel.text = "\(count)"
                        var tap = UITapGestureRecognizer(target: self, action: "showTakers")
                        self.coutLabel.addGestureRecognizer(tap)
                        self.confirmButtonConfig("Select your assistant", action: nil)
                    } else {
                        println("network error")
                    }
                })
            default:
                if status == 4 || status == 5 || status == 6{
                    self.cancelButton.hidden = true
                }
                self.confirmButtonConfig("Finished", action: "whistlerAccepted")
                self.reviewButton.enabled = true
                self.reviewButton.favor = favor
                let user: AnyObject? = favor[Constants.Favor.AssistedBy] == nil ? favor[Constants.Favor.CreatedBy] : favor[Constants.Favor.AssistedBy]
                bindData(user as? PFUser)
            }
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
            if let price = favor[Constants.Favor.Price] as? Int {
                self.prizeView.bindData(price)
            }
        }
    }
    
    func bindInterest(favor: PFObject?, row: Int) {
        if let favor = favor {
            self.favor = favor
            self.row = row
            self.confirmButtonConfig("Interested", action: nil)
            bindData(favor[Constants.Favor.CreatedBy] as? PFUser)
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
            if let price = favor[Constants.Favor.Price] as? Int {
                self.prizeView.bindData(price)
            }
        }
    }
    
    func bindAssist(favor: PFObject?, row: Int) {
        if let favor = favor {
            self.favor = favor
            self.row = row
            self.confirmButtonConfig("Favor Finished", action: "assistantDelivered")
            self.reviewButton.enabled = true
            self.reviewButton.favor = favor
            bindData(favor[Constants.Favor.CreatedBy] as? PFUser)
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
            if let price = favor[Constants.Favor.Price] as? Int {
                self.prizeView.bindData(price)
            }
        }
    }
    
    func bindAssistant(pivot: PFObject?) {
        if let pivot = pivot {
            self.confirmButtonConfig("Hire", action: nil)
            bindData(pivot[Constants.FavorUserPivotTable.Takers] as? PFUser)
            timeElapsedLabel.text = pivot.updatedAt?.relativeTime
            if let price = pivot[Constants.FavorUserPivotTable.Price] as? Int {
                self.prizeView.bindData(price)
            }
        }
    }
    
    func bindData(user: PFUser?) {
        if let user = user
        {
            user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user as? PFUser
                {
                    var name = user[Constants.User.Nickname] as? String
                    self.chatButton.enabled = true
                    self.chatButton.user = user
                    self.coutLabel.hidden = true
                    self.nameLabel.text = "\(name!)"
                    self.portraitView.loadImage(user)
                    self.portraitView.canTap = true
                    self.blurImage.loadImage(user)
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }
    
    func confirmButtonConfig(title: String, action: Selector?) {
        let attr = [NSFontAttributeName : UIFont(name: "MyriadPro-LightSemiExt", size: 23)!]
        let string = NSAttributedString(string: title, attributes: attr)
        self.confirmButton.setAttributedTitle(string, forState: .Normal)
        if action != nil {
            self.confirmButton.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
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
            let alert = WEAlertController(title: "Cancel", message: "Are you certain?", style: .Alert)
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
            let alert = WEAlertController(title: "Confirm", message: "Are you sure that your favor is successfully delivered", style: .Alert)
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
            let alert = WEAlertController(title: "Confirm", message: "Are you sure that your favor is successfully delivered", style: .Alert)
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
}


