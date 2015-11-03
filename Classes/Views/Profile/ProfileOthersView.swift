//
//  ProfileView.swift
//  Whistle
//
//  Created by Lu Cao on 6/24/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import Foundation
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileOthersView: UIViewController
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser?
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var bgView                                   : UIView!
    @IBOutlet weak var portraitView                             : UIImageView!
    @IBOutlet weak var nameLabel                                : UILabel!
    @IBOutlet weak var lineLabel                                : UILabel!
    @IBOutlet weak var regionLabel                              : UILabel!
    @IBOutlet weak var rateView                                 : RatingView!
    @IBOutlet weak var totalView                                : UIView!
    @IBOutlet weak var totalRateLabel                           : WEContentLabelWithBackground!
    @IBOutlet weak var overallLabel                             : WEContentLabelWithBackground!
    @IBOutlet weak var regionIcon                               : UIImageView!
    @IBOutlet weak var containerView                            : UIView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var blurView                                        = UIVisualEffectView()
    private var blurImage                                       = UIImageView()
    private var containerViewOriginalFrame                      = CGRectZero
    private var didLayoutSubviews                               = false
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()

        bindData(user)
        if let child = childViewControllers.first as? ProfileRateTable {
            child.user = self.user
        }
        
        configLooks()
        configNavBar()
        addBlurEffect()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = true
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.translucent = false
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        if !didLayoutSubviews {
            portraitView.layer.cornerRadius                     = portraitView.frame.height/2
            blurImage.frame                                     = bgView.bounds
            blurImage.contentMode = UIViewContentMode.ScaleAspectFill
            blurImage.clipsToBounds = true
            blurView.frame                                      = bgView.bounds
            containerViewOriginalFrame                          = containerView.frame
            didLayoutSubviews                                   = !didLayoutSubviews
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        navigationController?.navigationBar.translucent         = true
        bgView.backgroundColor                                  = Constants.Color.NavigationBar
        
        portraitView.layer.borderColor                          = Constants.Color.TextLight.CGColor
        portraitView.layer.borderWidth                          = 2
        
        totalView.alpha                                         = 0.92
        totalView.backgroundColor                               = Constants.Color.Border
        
        totalRateLabel.layer.borderWidth                        = 0
        totalRateLabel.layer.cornerRadius                       = 12
        totalRateLabel.layer.backgroundColor                    = Constants.Color.Border.CGColor
        totalRateLabel.textColor                                = Constants.Color.CellBackground
        overallLabel.layer.borderWidth                          = 0
        overallLabel.layer.cornerRadius                         = 12
        overallLabel.layer.backgroundColor                      = Constants.Color.Border.CGColor
        overallLabel.textColor                                  = Constants.Color.CellBackground
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configNavBar()
    //----------------------------------------------------------------------------------------------------------
    {
        self.navigationItem.rightBarButtonItem                  = UIBarButtonItem(title: "actions", style: .Plain, target: self, action:"action")

    }
    
    func action()
    {
        let alert = WEAlertController(title: "Action", message: "select your action", style: .ActionSheet)
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        alert.addAction(SimpleAlert.Action(title: "Chat", style: .OK) { action in
            let n = self.navigationController?.viewControllers.count
            let vc = self.navigationController?.viewControllers[n!-2] as? UIViewController
            if vc is ChatView
            {
                self.navigationController?.popViewControllerAnimated(true)
                return
            }
            let user1 = PFUser.currentUser()
            let groupId = StartPrivateChat(user1!, self.user!)
            let chatView = ChatView(with: groupId)
            self.navigationController?.pushViewController(chatView, animated: true)
            })
        alert.addAction(SimpleAlert.Action(title: "Block", style: .OK) { action in
            BlockUser(self.user)
            MessageHandler.message(MessageName.Blocked, vc: self)
            self.callSelector("delayedPopToRootViewController", object: self, delay: 1.0)
            })
        alert.addAction(SimpleAlert.Action(title: "Report", style: .OK) { action in
//            let query = PFQuery(className: Constants.UserReportPivotTable.Name)
//            query.whereKey(Constants.UserReportPivotTable.From, equalTo: PFUser.currentUser()!)
//            query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
//                if let object = object {
//                    MessageHandler.message(.HaveReported)
//                } else {
//                    vc.performSegueWithIdentifier("report", sender: vc)
//                }
//            }
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func delayedPopToRootViewController()
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addBlurEffect()
    //----------------------------------------------------------------------------------------------------------
    {
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = bgView.bounds
        blurImage = UIImageView(image: UIImage(named: "user_photo"))
        blurImage.frame = bgView.bounds
        bgView.addSubview(blurImage)
        bgView.addSubview(blurView)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(user: PFUser!)
    //----------------------------------------------------------------------------------------------------------
    {
        let name = user[Constants.User.Nickname] as? String
        self.nameLabel.text = "  \(name!)  "
        
        if let file = user[Constants.User.Portrait] as? PFFile {
            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data {
                    self.portraitView.image = UIImage(data: data)!
                    self.blurImage.image = UIImage(data: data)!
                } else {
                    ParseErrorHandler.handleParseError(error!)
                }
            })
        } else {
            self.portraitView.image = Constants.User.DefaultImage
            self.blurImage.image = Constants.User.DefaultImage
        }
        
        if let status = user[Constants.User.Status] as? String {
            self.lineLabel.text = status
        }
        
        if let region = user[Constants.User.Region] as? String {
            self.regionLabel.text = region
        } 
        
        user.fetchInBackgroundWithBlock { (user, error) -> Void in
            if let user = user as? PFUser
            {
                self.rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
                self.rateView.displayRating(user[Constants.User.Rating] as! Float)
                self.totalRateLabel.text = "\(user[Constants.User.Rates] as! Int) Reviews"
                self.overallLabel.text = "\(user[Constants.User.Rating] as! Float)/5.0"
            }
        }
    }
}
