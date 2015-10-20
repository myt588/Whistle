//
//  ProfileRateCell.swift
//  Whistle
//
//  Created by Lu Cao on 8/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileRateCell: WECell {

    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Background color views
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var bannerView                           : UIView!
    @IBOutlet weak var wrapperView                          : UIView!
    //----------------------------------------------------------------------------------------------------------
    // Banner
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var nameLabel: WEContentLabel!
    @IBOutlet weak var genderImage                          : UIImageView!
    @IBOutlet weak var portraitView                         : WEImageView!
    //----------------------------------------------------------------------------------------------------------
    // Content
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var rateView                             : RatingView!
    @IBOutlet weak var commentHeader                        : UILabel!
    @IBOutlet weak var contentLabel                         : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        configLooks()
        
        rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
        rateView.displayRating(3.5)
    }
    
    /*
    override func prepareForReuse() {
        self.genderImage.hidden = true
        self.genderImage.image = nil
        self.portraitView.hidden = true
        self.portraitView.image = nil
        self.lvLabel.text = ""
        self.lvLabel.hidden = true
        self.contentLabel.text = ""
    }
    */
    
    // MARK: - Functions
    func configLooks() {
        backgroundColor = UIColor.clearColor()
        
        bannerView.backgroundColor = Constants.Color.Banner
        bannerView.layer.cornerRadius = 8
        wrapperView.backgroundColor = Constants.Color.ContentBackground
        wrapperView.alpha = 0.65
        
        portraitView.layer.borderWidth = 3
        portraitView.layer.borderColor = Constants.Color.Border.CGColor
        portraitView.layer.cornerRadius = 40
    }
    
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(review: PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        if let review = review {
            if let user = review[Constants.UserReviewPivotTable.From] as? PFUser {
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
            }
            self.rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
            self.rateView.displayRating(review[Constants.UserReviewPivotTable.Rating] as! Float)
            self.contentLabel.text = review[Constants.UserReviewPivotTable.Comment] as? String
        }
    }

}

