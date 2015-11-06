//
//  ProfileReviewDetailView.swift
//  
//
//  Created by Lu Cao on 10/30/15.
//
//

import UIKit

class ProfileReviewDetailView: UIViewController {

    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var timeLabel: WEFontTime!
    @IBOutlet weak var portraitView: WEProfileView!
    @IBOutlet weak var nameLabel: WEFontName!
    @IBOutlet weak var commentLabel: WEFontContent!
    
    var review: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment"
        view.backgroundColor = Constants.Color.Background
        bindData()
    }
    
    override func viewDidLayoutSubviews() {
        self.commentLabel.numberOfLines = 0
        self.commentLabel.sizeToFit()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData()
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
            self.ratingView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
            self.ratingView.displayRating(review[Constants.UserReviewPivotTable.Rating] as! Float)
            self.commentLabel.text = review[Constants.UserReviewPivotTable.Comment] as? String
            self.timeLabel.text = review.updatedAt?.relativeTime
        }
    }

}
