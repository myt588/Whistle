//
//  CurrentRateView.swift
//  Whistle
//
//  Created by Lu Cao on 8/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class CurrentRateView: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countLabel: WEContentLabel!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    private var rating: Int = 0
    var favor: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLooks()
        configStars()
        configBarButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        textView.resignFirstResponder()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configBarButton()
    //----------------------------------------------------------------------------------------------------------
    {
        var rightButton = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action:"submit")
        self.navigationItem.rightBarButtonItem             = rightButton
        var leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action:"cancel")
        self.navigationItem.leftBarButtonItem              = leftButton
    }
    
    func configLooks() {
        view.backgroundColor                            = Constants.Color.Background
        var darkBlur                                    = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                                    = UIVisualEffectView(effect: darkBlur)
        blurView.frame                                  = view.bounds
        view.insertSubview(blurView, atIndex: 0)
        
        textView.delegate                               = self
        textView.backgroundColor                        = UIColor.clearColor()
        textView.textContainerInset                     = UIEdgeInsetsMake(10, 8, 10, 8)
        textView.textColor                              = Constants.Color.CellTextReverse
        textView.layer.cornerRadius                     = 8
    }
    
    func configStars() {
        var tap1 = UITapGestureRecognizer(target: self, action: "star1Tapped:")
        star1.addGestureRecognizer(tap1)
        var tap2 = UITapGestureRecognizer(target: self, action: "star2Tapped:")
        star2.addGestureRecognizer(tap2)
        var tap3 = UITapGestureRecognizer(target: self, action: "star3Tapped:")
        star3.addGestureRecognizer(tap3)
        var tap4 = UITapGestureRecognizer(target: self, action: "star4Tapped:")
        star4.addGestureRecognizer(tap4)
        var tap5 = UITapGestureRecognizer(target: self, action: "star5Tapped:")
        star5.addGestureRecognizer(tap5)
        var stars = [star1, star2, star3, star4, star5]
        for element in stars {
            element.userInteractionEnabled = true
        }
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submit() {
        if rating == 0 {
            ProgressHUD.showError("Please select a rate!")
            return
        }
        if let favor = self.favor {
            let creator = favor[Constants.Favor.CreatedBy] as! PFUser
            let assistant = favor[Constants.Favor.AssistedBy] as! PFUser
            var user: PFUser
            if PFUser.currentUser()!.objectId == creator.objectId
            {
                user = assistant
            } else {
                user = creator
            }
            let userReview = PFObject(className: Constants.UserReviewPivotTable.Name)
            userReview[Constants.UserReviewPivotTable.From] = PFUser.currentUser()
            userReview[Constants.UserReviewPivotTable.To] = user
            userReview[Constants.UserReviewPivotTable.Because] = favor
            userReview[Constants.UserReviewPivotTable.Comment] = textView.text
            userReview[Constants.UserReviewPivotTable.Rating] = rating
            userReview.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    TSMessage.showNotificationWithTitle("Review", subtitle: "Your review has been posted on \(user[Constants.User.Nickname] as! String)'s wall", type: TSMessageNotificationType.Success)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })

        } 
    }
    
    func star1Tapped(sender: UITapGestureRecognizer) {
        println("1")
        var stars = [star1]
        for element in stars {
            element.image = UIImage(named: "rate_star_fill")
            bounceView(element)
        }
        rating = 1
        var unStars = [star2, star3, star4, star5]
        for element in unStars {
            element.image = UIImage(named: "rate_star_line")
        }
    }
    func star2Tapped(sender: UITapGestureRecognizer) {
        println("2")
        var stars = [star1, star2]
        for element in stars {
            element.image = UIImage(named: "rate_star_fill")
            bounceView(element)
        }
        rating = 2
        var unStars = [star3, star4, star5]
        for element in unStars {
            element.image = UIImage(named: "rate_star_line")
        }
    }
    func star3Tapped(sender: UITapGestureRecognizer) {
        println("3")
        var stars = [star1, star2, star3]
        for element in stars {
            element.image = UIImage(named: "rate_star_fill")
            bounceView(element)
        }
        rating = 3
        var unStars = [star4, star5]
        for element in unStars {
            element.image = UIImage(named: "rate_star_line")
        }
    }
    func star4Tapped(sender: UITapGestureRecognizer) {
        println("4")
        var stars = [star1, star2, star3, star4]
        for element in stars {
            element.image = UIImage(named: "rate_star_fill")
            bounceView(element)
        }
        rating = 4
        var unStars = [star5]
        for element in unStars {
            element.image = UIImage(named: "rate_star_line")
        }
    }
    func star5Tapped(sender: UITapGestureRecognizer) {
        println("5")
        var stars = [star1, star2, star3, star4, star5]
        for element in stars {
            element.image = UIImage(named: "rate_star_fill")
            bounceView(element)
        }
        rating = 5
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        let num: Int = count(textView.text)
        if num - range.length + count(text) > Constants.Limit.Reward {
            return false
        } else {
            countLabel.text = "\(num - range.length + count(text))/\(Constants.Limit.Rate)"
            return true
        }
    }
}
