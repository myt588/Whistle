//
//  WEReviewCell.swift
//  Whistle
//
//  Created by Yetian Mao on 10/30/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class WEReviewCell: UITableViewCell
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    
    @IBOutlet weak var portraitView: WEProfileView!
    @IBOutlet weak var nameLabel: WEContentLabel!
    @IBOutlet weak var commentLabel: WEContentLabel!
    @IBOutlet weak var rateView: RatingView!
    @IBOutlet weak var timeLabel: UILabel!

    //----------------------------------------------------------------------------------------------------------
    // Constraints
    //----------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(review: PFObject?)  
    //----------------------------------------------------------------------------------------------------------
    {
        if let review = review {
            if let user = review[Constants.UserReviewPivotTable.From] as? PFUser {
                user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                    if let user = user as? PFUser
                    {
                        self.portraitView.loadImage(user)
                        self.nameLabel.text = user[Constants.User.Nickname] as? String
                    }
                })
            }
            self.rateView.setImagesDeselected("star_empty", partlySelected: "star_half", fullSelected: "star_full")
            self.rateView.displayRating(review[Constants.UserReviewPivotTable.Rating] as! Float)
            self.commentLabel.text = review[Constants.UserReviewPivotTable.Comment] as? String
            self.timeLabel.text = review.updatedAt?.relativeTime
        }
    }
    
    
}
