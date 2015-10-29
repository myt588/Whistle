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
    @IBOutlet weak var audioView                            : WEVoiceBubble!
    @IBOutlet weak var contentLabel                         : UILabel!
    
    @IBOutlet weak var confirmButton                        : UIButton!
    @IBOutlet weak var cancelButton                         : UIButton!
    @IBOutlet weak var chatButton                           : WEChatButton!
    @IBOutlet weak var reviewButton                         : WEReviewButton!
    @IBOutlet weak var shareButton                          : WEShareButton!
    
    var vc                                                  : CurrentSwitcher?
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
        self.chatButton.enabled = false
        self.reviewButton.enabled = false
        self.shareButton.enabled = true
        self.cancelButton.enabled = false
        self.confirmButton.enabled = false
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
    }
    
    func bindData(favor : PFObject?, row: Int, cellType: String)
    {
        if let favor = favor {
            var status = 0
            if cellType == "interest"
            {
                status = 2
            } else {
                status = favor[Constants.Favor.Status] as! Int
            }
            switch status {
            case 0:                                         // No Takers
                self.coutLabel.hidden = true
                self.portraitView.image = UIImage(named: "user_unknown")
                self.portraitView.canTap = false
                self.blurImage.loadImage(PFUser.currentUser()!)
                self.nameLabel.text = "Waiting..."
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
                        self.tag = row
                        self.coutLabel.addGestureRecognizer(tap)
                        self.nameLabel.text = "Please select your assistant..."
                    } else {
                        println("network error")
                    }
                })
            default:
                self.chatButton.enabled = true
                self.reviewButton.enabled = true
                var user: PFUser?
                if cellType == "favor"
                {
                    user = favor[Constants.Favor.AssistedBy] as? PFUser
                } else {
                    user = favor[Constants.Favor.CreatedBy] as? PFUser
                }
                self.chatButton.user = user
                self.chatButton.vc = vc
                self.reviewButton.favor = favor
                if let user = user
                {
                    user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                        if let user = user as? PFUser
                        {
                            var name = user[Constants.User.Nickname] as? String
                            self.coutLabel.hidden = true
                            self.nameLabel.text = "\(name!)"
                            self.portraitView.loadImage(user)
                            self.portraitView.canTap = true
                            self.blurImage.loadImage(user)
                        }
                    })
                }
                
            }
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile {
                self.audioView.hidden = false
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
                    //self.audioLengthCons.constant = 50 + CGFloat(seconds)*1.67
                })
            } else {
                self.audioView.hidden = true
                if let content = favor[Constants.Favor.Content] as? String {
                    self.contentLabel.hidden = false
                    self.contentLabel.text = content
                }
            }
            
            timeElapsedLabel.text = favor.updatedAt?.relativeTime
            
            if let price = favor[Constants.Favor.Price] as? Int {
                self.prizeView.bindData(price)
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func showTakers()
    //----------------------------------------------------------------------------------------------------------
    {
        vc!.selectedIndex = self.tag
        vc!.performSegueWithIdentifier("Current_To_Assistant", sender: self)
    }
    
}


