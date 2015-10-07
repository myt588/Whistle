//
//  CurrentAssistCell.swift
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

class CurrentAssistCell: UITableViewCell, WEImageViewProtocol, WERecentButtonsViewDelegate
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var timeElapsedLabel                     : UILabel!
    @IBOutlet weak var priceLabel                           : UILabel!
    @IBOutlet weak var distanceLabel                        : UILabel!
    @IBOutlet weak var wrapper                              : UIView!
    @IBOutlet weak var headerLabel                          : WEHeader!
    @IBOutlet weak var contentLabel                         : UILabel!
    @IBOutlet weak var portraitView                         : WEImageView!
    @IBOutlet weak var lvLabel                              : WEContentLabel!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var genderImage                          : UIImageView!
    @IBOutlet weak var banner                               : UIView!
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    //----------------------------------------------------------------------------------------------------------
    // Buttons
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var buttonsView                          : WERecentButtonsView!
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var audioLengthCons                      : NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    private var favor                                       : PFObject!
    private var row                                         : Int!
    private var userToPass                                  : PFUser!
    var vc                                                  : CurrentSwitcher!
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        buttonsView.delegate = self
        portraitView.delegate = self
        configLooks()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForReuse()
    //----------------------------------------------------------------------------------------------------------
    {
        self.priceLabel.text = ""
        self.timeElapsedLabel.text = ""
        self.genderImage.image = nil
        self.portraitView.image = nil
        self.lvLabel.text = ""
        self.lvLabel.hidden = true
        self.audioView.hidden = true
        self.contentLabel.text = ""
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
        
        portraitView.layer.borderWidth                      = 3
        portraitView.layer.borderColor                      = Constants.Color.Border.CGColor
        portraitView.layer.cornerRadius                     = portraitView.layer.frame.height/2
        
        banner.backgroundColor                              = Constants.Color.Banner
        banner.alpha                                        = 0.85
        wrapper.alpha                                       = 0.85
    
        headerLabel.addBottomBorderWithHeight(0.3, color: Constants.Color.Border)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor: PFObject?, row: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        if let favor = favor {
            self.favor = favor
            self.row = row
            
            let status = favor[Constants.Favor.Status] as! Int
            buttonsView.takerState(status)
            
            var user : PFUser = favor[Constants.Favor.CreatedBy] as! PFUser
            userToPass = user
            portraitView.receiveUser()
            user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user {
                    var image = user[Constants.User.Portrait] as! PFFile
                    image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            self.portraitView.image = UIImage(data: data!)
                        }
                    })
                    self.nameLabel.text = user[Constants.User.Nickname] as? String
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
                }
            })
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile {
                self.audioView.hidden = false
                self.headerLabel.hidden = true
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
                    self.headerLabel.hidden = false
                    self.contentLabel.hidden = false
                    self.contentLabel.text = content
                }
            }
            
            if let price = favor[Constants.Favor.Price] as? Int {
                // if bidId exists means user have interested on this before
                if let bidId = NSUserDefaults.standardUserDefaults().stringForKey(favor.objectId!) {
                    let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                    query.fromLocalDatastore()
                    query.getObjectInBackgroundWithId(bidId, block: { (object, error) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if let object = object {
                                if object[Constants.FavorUserPivotTable.Active] as! Bool {
                                    if let bidPrice = object[Constants.FavorUserPivotTable.Price] as? Int {
                                        self.priceLabel.text = "\(bidPrice)"
                                    } else {
                                        self.priceLabel.text = "\(price)"
                                    }
                                } else {
                                    self.priceLabel.text = "\(price)"
                                }
                            }
                        }
                    })
                } else {
                    self.priceLabel.text = "\(price)"
                }
            }
            
            if let address = favor[Constants.Favor.Address] as? String {
                PFGeoPoint.geoPointForCurrentLocationInBackground({ (location, error) -> Void in
                    if error == nil {
                        let location2 = favor[Constants.Favor.Location] as? PFGeoPoint
                        let distance : Double = location!.distanceInMilesTo(location2)
                        self.distanceLabel.text = "\(distance.roundTo1) miles"
                    }
                })
            }
            
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func passUser() -> PFUser?
    //----------------------------------------------------------------------------------------------------------
    {
        return userToPass
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
                ProgressHUD.showError("You have already reviewed this favor")
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
                    favor[Constants.Favor.Status] = 3
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.row)
                                vc.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: self.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
                                vc.favors.removeObjectAtIndex(self.row)
                                vc.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: self.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
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
                ProgressHUD.showError("You have already reported this favor")
            } else {
                if let vc = self.vc {
                    vc.selectedIndex = self.row
                    vc.performSegueWithIdentifier("report", sender: vc)
                }
            }
        }
    }
    
}
