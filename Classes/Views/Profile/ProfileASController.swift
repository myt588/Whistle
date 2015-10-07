//
//  ContentViewController.swift
//  SheetAlertExample
//
//  Created by Kyohei Ito on 2015/01/09.
//  Copyright (c) 2015年 kyohei_ito. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileASController: UIViewController
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var bg                               : UIView!
    @IBOutlet weak var portrait                         : UIImageView!
    @IBOutlet weak var nameLabel                        : UILabel!
    @IBOutlet weak var lineLabel                        : UILabel!
    @IBOutlet weak var lvLabel                          : WEContentLabel!
    @IBOutlet weak var regionLabel                      : WEContentLabel!
    @IBOutlet weak var genderImage                      : UIImageView!
    @IBOutlet weak var rateView                         : RatingView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var user: PFUser?
    //----------------------------------------------------------------------------------------------------------
    var bgImage = UIImageView()
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    init()
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(nibName: "ProfileASController", bundle: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        
        bgImage = UIImageView(frame: bg.frame)
        bgImage.image = UIImage(named: "Jaychou_fantasy")
        bg.insertSubview(bgImage, atIndex: 0)
        
        bg.backgroundColor = Constants.Color.Background
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = bg.frame
        bg.insertSubview(blurView, atIndex: 1)
        
        portrait.layer.cornerRadius = 60
        lvLabel.addBottomBorderWithHeight(0.3, color: Constants.Color.Border)
        
        bindData()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func bindData()
    //----------------------------------------------------------------------------------------------------------
    {
        if let user = self.user {
            if let image = user[Constants.User.Portrait] as? PFFile {
                image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.portrait.image = UIImage(data: data!)
                            self.bgImage.image = self.portrait.image
                        }
                    }
                })
            }
            nameLabel.text = user[Constants.User.Nickname] as? String
            lineLabel.text = user[Constants.User.Status] as? String
            regionLabel.text = user[Constants.User.Region] as? String
            var genderImageName = (user[Constants.User.Gender] as? String) == "male" ? "profile_male" : "profile_female"
            genderImage.image = UIImage(named: genderImageName)
        } else {

        }
        
        rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
        rateView.displayRating(3.5)
    }
    
}
