//
//  InitialView.swift
//  ParseStarterProject
//
//  Created by Yetian Mao on 6/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import ParseUI
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class InitialView: UIViewController
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var hud                              : UIView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var myHud                                   = AMTumblrHud()
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLayoutSubviews()
        myHud.frame                                     = hud.frame
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        let user = PFUser.currentUser()
        if user?.objectId != nil {
            if user![Constants.User.Nickname] != nil {
                self.performSegueWithIdentifier("toMain", sender: self)
            } else {
                self.performSegueWithIdentifier("toSetProfile", sender: self)
            }
        } else {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        view.backgroundColor                            = Constants.Color.Background
        myHud.hudColor                                  = Constants.Color.Border
        view.addSubview(myHud)
        myHud.showAnimated(true)
        var darkBlur                        = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                        = UIVisualEffectView(effect: darkBlur)
        blurView.frame                      = view.bounds
        self.view.insertSubview(blurView, atIndex: 0)
    }
}

