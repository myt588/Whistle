//
//  FavorListCell.swift
//  Whistle
//
//  Created by Lu Cao on 7/2/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import AVFoundation
import Foundation
//----------------------------------------------------------------------------------------------------------

class FavorListCell: UITableViewCell, WEImageViewProtocol {
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var timeElapsedLabel                     : UILabel!
    @IBOutlet weak var distanceLabel                        : UILabel!
    @IBOutlet weak var wrapper                              : UIView!
    @IBOutlet weak var favorHeader                          : UILabel!
    @IBOutlet weak var contentLabel                         : UILabel!
    @IBOutlet weak var portraitView                         : WEImageView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var genderImage                          : UIImageView!
    @IBOutlet weak var lvLabel                              : WEContentLabel!
    @IBOutlet weak var banner                               : UIView!
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    @IBOutlet weak var interestButton                       : UIButton!
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var priceLabel                           : UILabel!
    @IBOutlet weak var plus1Button                          : UIButton!
    @IBOutlet weak var plus5Button                          : UIButton!
    @IBOutlet weak var plus10Button                         : UIButton!
    @IBOutlet weak var clearButton                          : UIButton!
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var voiceLengthCons                      : NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    
    private var userToPass                                  : PFUser?
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var price                                       = 0
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        portraitView.delegate = self
        configLooks()
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    @IBAction func modifyPrice(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        bounceView(sender)
        bounceView(priceLabel)
        switch sender.titleLabel!.text! {
        case "C":
            priceLabel.text = "\(price)"
        case "+10":
            priceLabel.text = "\(priceLabel.text!.toInt()! + 10)"
        case "+5":
            priceLabel.text = "\(priceLabel.text!.toInt()! + 5)"
        case "+1":
            priceLabel.text = "\(priceLabel.text!.toInt()! + 1)"
        default:
            return
        }
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
        
//        lvLabel.addBottomBorderWithHeight(0.3, color: Constants.Color.Border)
        
        var buttonList = [plus1Button, plus5Button, plus10Button, clearButton]
        for element in buttonList {
            element.layer.borderColor                               = Constants.Color.Border.CGColor
            element.layer.borderWidth                               = 0.3
            element.layer.cornerRadius                              = element.layer.frame.height/2
            element.setTitleColor(Constants.Color.CellText, forState: .Normal)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor: PFObject?, index: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        if let favor = favor {
            var user : PFUser = favor[Constants.Favor.CreatedBy] as! PFUser
            userToPass = user
            portraitView.receiveUser()
            user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var image = user[Constants.User.Portrait] as! PFFile
                        image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error == nil {
                                self.portraitView.image = UIImage(data: data!)
                            }
                        })
                        self.nameLabel.text = user[Constants.User.Nickname] as? String
                    })
                } else {
                    println(error)
                }
            })

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
                    self.voiceLengthCons.constant = 50 + CGFloat(seconds)*1.67
                })
            } else {
                self.audioView.hidden = true
                if let content = favor[Constants.Favor.Content] as? String {
                    self.favorHeader.hidden = false
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
                                       //println("1")
                                        self.priceLabel.text = "\(bidPrice)"
                                    } else {
                                        //println("2")
                                        self.priceLabel.text = "\(price)"
                                        self.price = price
                                    }
                                } else {
                                    //println("3")
                                    self.priceLabel.text = "\(price)"
                                    self.price = price
                                }
                            }
                        }
                    })
                } else {
                    //println("4")
                    self.priceLabel.text = "\(price)"
                }
            }
            self.distanceLabel.text = "\(favor[Constants.Favor.Distance] as! Double) miles"
            timeElapsedLabel.text = favor.createdAt?.relativeTime
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func passUser() -> PFUser?
    //----------------------------------------------------------------------------------------------------------
    {
        return userToPass
    }
    
}
