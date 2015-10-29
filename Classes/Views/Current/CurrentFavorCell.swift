//
//  CurrentFavorCell.swift
//  Whistle
//
//  Created by Lu Cao on 6/30/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import AVFoundation
import Foundation
import Parse
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class CurrentFavorCell: UITableViewCell, WERecentButtonsViewDelegate
//----------------------------------------------------------------------------------------------------------
{

    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Background color views
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var bannerView                           : UIView!
    @IBOutlet weak var wrapperView                          : UIView!
    //----------------------------------------------------------------------------------------------------------
    // Banner
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var priceLabel                           : WEContentLabel!
    @IBOutlet weak var statusButton                         : UIButton!
    @IBOutlet weak var statusLabel                          : UILabel!
    @IBOutlet weak var timeElapsedLabel                     : UILabel!
    @IBOutlet weak var genderImage                          : UIImageView!
    @IBOutlet weak var portraitView                         : WEProfileView!
    //----------------------------------------------------------------------------------------------------------
    // Content
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    @IBOutlet weak var favorHeader                          : UILabel!
    @IBOutlet weak var contentLabel                         : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Buttons
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var buttonsView                          : WERecentButtonsView!
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var audioLengthCons                      : NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    private var favor                                       : PFObject!
    private var row                                         : Int!
    var vc                                                  : CurrentSwitcher?
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        buttonsView.delegate = self
        configLooks()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForReuse()
    //----------------------------------------------------------------------------------------------------------
    {
        self.priceLabel.text = ""
        self.statusButton.hidden = false
        self.statusLabel.text = ""
        self.timeElapsedLabel.text = ""
        self.genderImage.hidden = true
        self.genderImage.image = nil
        self.portraitView.hidden = true
        self.portraitView.image = nil
        self.audioView.hidden = true
        self.contentLabel.text = ""
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
        statusLabel.textColor                               = UIColor.blackColor()
        
        bannerView.backgroundColor                          = Constants.Color.Banner
        wrapperView.backgroundColor                         = Constants.Color.ContentBackground
        
        portraitView.layer.borderWidth                      = 3
        portraitView.layer.borderColor                      = Constants.Color.Border.CGColor
        portraitView.layer.cornerRadius                     = portraitView.layer.frame.height/2
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor : PFObject?, row: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        if let favor = favor {
            self.favor = favor
            self.row = row
            let status = favor[Constants.Favor.Status] as! Int
            buttonsView.ownerState(status)
            switch status {
            case 0:                                         // No Takers
                self.statusButton.setImage(nil, forState: .Normal)
                self.statusButton.setTitle("0", forState: .Normal)
                self.statusLabel.text = "Waiting for assisting..."
            case 1:                                         // Has Takers
                let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
                query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                    if error == nil {
                        self.statusButton.setImage(nil, forState: .Normal)
                        self.statusButton.setTitle("\(count)", forState: .Normal)
                        self.statusButton.tag = row
                        self.statusButton.addTarget(self, action: "showTakers:", forControlEvents: .TouchUpInside)
                        self.statusLabel.text = "Please Pick an Assistant..."
                    } else {
                        println("network error")
                    }
                })
            default:
                showTaker(favor)
            }
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile {
                self.audioView.hidden = false
                self.favorHeader.hidden = true
                self.contentLabel.hidden = true
                audio.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    let audioManager = AudioManager()
                    let name = audioNameWithDate()
                    audioManager.saveAudio(data!, name: name)
                    let url = audioManager.audioURLWithName(name)
                    self.audioView.contentURL = url
                    var asset = AVURLAsset(URL: audioManager.audioURLWithName(name), options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
                    var duration: CMTime = asset.duration
                    var seconds = Int(CMTimeGetSeconds(duration))
                    self.audioLengthCons.constant = 50 + CGFloat(seconds)*1.67
                })
            } else {
                self.audioView.hidden = true
                if let content = favor[Constants.Favor.Content] as? String {
                    self.favorHeader.hidden = false
                    self.contentLabel.hidden = false
                    self.contentLabel.text = content
                }
            }
            
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
            
            if let price = favor[Constants.Favor.Price] as? Int {
                self.priceLabel.text = "\(price)"
            }
        }
    }
    
    func showTaker(favor: PFObject) {
        if let user = favor[Constants.Favor.AssistedBy] as? PFUser {
            portraitView.user = user
            var name = user[Constants.User.Nickname] as? String
            self.statusLabel.text = "\(name!)"
            self.statusLabel.font = UIFont(name: "Arial", size: 20)
            if let gender = user[Constants.User.Gender] as? Int {
                if gender == 1 {
                    self.genderImage.image = UIImage(named: "profile_male")
                }
                if gender == 0 {
                    self.genderImage.image = UIImage(named: "profile_female")
                }
            } else {
                self.genderImage.image = nil
            }
            var image = user[Constants.User.Portrait] as! PFFile
            image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data {
                    self.statusButton.hidden = true
                    self.portraitView.hidden = false
                    self.genderImage.hidden = false
                    self.portraitView.image = UIImage(data: data)
                } else {
                    println("network error")
                }
            })
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func showTakers(sender: UIButton!)
    //----------------------------------------------------------------------------------------------------------
    {
        vc!.selectedIndex = sender.tag
        vc!.performSegueWithIdentifier("Current_To_Assistant", sender: self)
    }
    
    func shareTapped(sender: UIButton!) {
        socialShare(sharingText: "llalala", UIImage(named: "favor_map_icon"), NSURL(string: "http://itunes.apple.com/app/"))
        println("share tapped")
    }
    
    func rateTapped(sender: UIButton!) {
        println("rate tapped")
        let query = PFQuery(className: Constants.UserReviewPivotTable.Name)
        query.whereKey(Constants.UserReviewPivotTable.From, equalTo: PFUser.currentUser()!)
        query.whereKey(Constants.UserReviewPivotTable.Because, equalTo: favor)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let object = object {
                MessageHandler.message(.HaveReviewed)
            } else {
                if let vc = self.vc {
                    vc.selectedIndex = self.row
                    vc.performSegueWithIdentifier("rate", sender: vc)
                }
            }
        }
    }
    
    func confirmTapped(sender: UIButton!) {
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
                                //vc.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: self.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
    
    func cancelTapped(sender: UIButton!) {
        println("cancel tapped")
        if let vc = self.vc {
            let alert = WEAlertController(title: "Cancel", message: "Are you certain?", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 5
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //vc.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: self.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
    
    func reportTapped(sender: UIButton!) {
        println("report tapped")
        let query = PFQuery(className: Constants.UserReportPivotTable.Name)
        query.whereKey(Constants.UserReportPivotTable.From, equalTo: PFUser.currentUser()!)
        query.whereKey(Constants.UserReportPivotTable.Because, equalTo: favor)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let object = object {
                MessageHandler.message(.HaveReported)
            } else {
                if let vc = self.vc {
                    vc.selectedIndex = self.row
                    vc.performSegueWithIdentifier("report", sender: vc)
                }
            }
        }
    }

}
