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
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileOthersView: UIViewController, ProfileOthersScrollDelegate
//----------------------------------------------------------------------------------------------------------
{
    
    var user: PFUser?
    var isFriend: Bool = false
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
    @IBOutlet weak var genderIcon                               : UIImageView!
    @IBOutlet weak var containerView                            : UIView!
    @IBOutlet weak var containerCons                            : NSLayoutConstraint!
    @IBOutlet weak var containerNewCons                         : NSLayoutConstraint!
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
        if let child = childViewControllers.first as? ProfileOthersTable {
            child.delegate = self
            child.user = self.user
        }
        if let user = self.user {
            bindData(user)
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
        if isFriend {
            self.navigationItem.rightBarButtonItem                  = UIBarButtonItem(title: "Message", style: .Plain, target: self, action:"action")
        }
    }
    
    func action()
    {
        let user1 = PFUser.currentUser()
        let groupId = StartPrivateChat(user1!, self.user!)
        let chatView = ChatView(with: groupId)
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addBlurEffect()
    //----------------------------------------------------------------------------------------------------------
    {
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = bgView.bounds
        blurImage = UIImageView(image: UIImage(named: "Jaychou_fantasy"))
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
        } else {
            
        }
        
        if let region = user[Constants.User.Region] as? String {
            self.regionLabel.text = region
        } else {
            
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
    
    func expand() {
        if containerCons.active {
            println("Expand")
            var diffY = rateView.frame.origin.y - containerView.frame.origin.y
            self.containerCons.active = false
            self.containerNewCons.active = true
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.containerView.frame = self.view.bounds
                self.totalView.frame.origin = self.containerView.frame.origin
                self.rateView.frame.origin.y = self.containerView.frame.origin.y + diffY
                }, completion: { (finished: Bool) -> Void in
                    
            })
        }
    }
    
    func shrink() {
        
        if containerNewCons.active {
            println("Shrink")
            var diffY = rateView.frame.origin.y - containerView.frame.origin.y
            self.containerNewCons.active = false
            self.containerCons.active = true
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.containerView.frame = self.containerViewOriginalFrame
                self.totalView.frame.origin = self.containerView.frame.origin
                self.rateView.frame.origin.y = self.containerView.frame.origin.y + diffY
                }, completion: { (finished: Bool) -> Void in
                    
            })
        }
    }
    
}
