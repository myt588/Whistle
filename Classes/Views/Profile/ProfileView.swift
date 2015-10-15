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
class ProfileView: UIViewController, ProfileScrollDelegate
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
        if let child = childViewControllers.first as? ProfileFavorsTable {
            child.delegate = self
        }
        configLooks()
        addBlurEffect()
        addGesture()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = PFUser.currentUser() {
            bindData(user)
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
        (tabBarController as? YALFoldingTabBarController)?.tabBarView.hidden = false
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
        
        totalView.alpha                                         = 0.92
        totalView.backgroundColor                               = Constants.Color.Border
        
        totalEarnLabel.layer.borderWidth                        = 0
        totalEarnLabel.layer.cornerRadius                       = 12
        totalEarnLabel.layer.backgroundColor                    = Constants.Color.Border.CGColor
        totalEarnLabel.textColor                                = Constants.Color.CellBackground
        totalSpentLabel.layer.borderWidth                       = 0
        totalSpentLabel.layer.cornerRadius                      = 12
        totalSpentLabel.layer.backgroundColor                   = Constants.Color.Border.CGColor
        totalSpentLabel.textColor                               = Constants.Color.CellBackground
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
        
        rateView.setImagesDeselected("profile_rate_0", partlySelected: "profile_rate_1", fullSelected: "profile_rate_2")
        rateView.displayRating(3.5)
    }
    
    func tapToSetStatus() {
        performSegueWithIdentifier("profile_to_status", sender: self)
    }
    
    func tapToSetRegion() {
        println("tagp")
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
