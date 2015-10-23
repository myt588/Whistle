//
//  ProfileView.swift
//  Whistle
//
//  Created by Lu Cao on 6/24/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//
//  TO DO
//  Add Region Picker                               check
//  Add header and footer to each necessary sections
//  Level System implementation

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileView: UIViewController
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
    @IBOutlet weak var totalEarnLabel                           : WEContentLabelWithBackground!
    @IBOutlet weak var totalSpentLabel                          : WEContentLabelWithBackground!
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
        configLooks()
        addBlurEffect()
        addGesture()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = PFUser.currentUser() {
            self.bindData(user)
        } else {
            var viewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }

    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent         = true
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = false
        
        if let user = PFUser.currentUser() {
            self.bindData(user)
        } else {
            var viewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.translucent         = false
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
    
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    @IBAction func navBarItemRightTapped(sender: UIBarButtonItem)
    //----------------------------------------------------------------------------------------------------------
    {
        performSegueWithIdentifier("profileToSettings", sender: self)
    }
    
    // MARK: - Gestures
    func addGesture() {
        var tapRate = UITapGestureRecognizer(target: self, action: "rateTapped")
        rateView.addGestureRecognizer(tapRate)
    }
    
    func rateTapped() {
        performSegueWithIdentifier("profile_rate", sender: self)
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
        
        rateView.tintColor                                      = Constants.Color.Main
        
        totalView.alpha                                         = 0.92
        totalView.backgroundColor                               = Constants.Color.ContentBackground
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
                    self.portraitView.contentMode = UIViewContentMode.ScaleAspectFill
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
            var tap = UITapGestureRecognizer(target: self, action: "tapToSetStatus")
            self.lineLabel.userInteractionEnabled = true
            self.lineLabel.addGestureRecognizer(tap)
        }
        
        if let region = user[Constants.User.Region] as? String {
            self.regionLabel.text = region
        } else {
            var tap = UITapGestureRecognizer(target: self, action: "tapToSetRegion")
            self.regionLabel.userInteractionEnabled = true
            self.regionLabel.addGestureRecognizer(tap)
        }
        
        user.fetchInBackgroundWithBlock { (user, error) -> Void in
            if let user = user as? PFUser
            {
                self.rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
                self.rateView.displayRating(user[Constants.User.Rating] as! Float)
            }
        }
        if let child = childViewControllers.first as? ProfileFavorsTable {
            self.totalEarnLabel.text = "Total Earned: $\(child.totalEarned)"
            self.totalSpentLabel.text = "Total Spent: $\(child.totalSpent)"
        }
    }
    
    func tapToSetStatus()
    {
        performSegueWithIdentifier("profile_to_status", sender: self)
    }
    
    func tapToSetRegion()
    {
        var vc = storyboard?.instantiateViewControllerWithIdentifier("RegionPicker") as! ProfileRegionPicker
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profile_rate" {
            var rateTable = segue.destinationViewController as! ProfileRateTable
            rateTable.user = PFUser.currentUser()
        }
    }
    
}
