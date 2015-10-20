//
//  CurrentView.swift
//  Whistle
//
//  Created by Lu Cao on 7/22/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//
//  TO DO:
//  User Can Only Review and Report Once            Check
//  Report Follow Up Views
//  Visual Effect On Buttons and Other Parts after certain user actions
//  Local Data Store

//----------------------------------------------------------------------------------------------------------
import UIKit
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class CurrentView: UIViewController, CarbonTabSwipeDelegate
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var tabSwipe = CarbonTabSwipeNavigation()
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        
        title = "Current"
        view.backgroundColor = Constants.Color.Background
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.insertSubview(blurView, atIndex: 0)

        var names = ["My Favor", "My Assist", "My Interest", "History"]
        var color = Constants.Color.Main
        tabSwipe = CarbonTabSwipeNavigation().createWithRootViewController(self, tabNames: names, tintColor: color, delegate: self)
        tabSwipe.setNormalColor(UIColor.blackColor())
        tabSwipe.setSelectedColor(UIColor.blackColor())
        tabSwipe.setIndicatorHeight(3)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = PFUser.currentUser() {
            
        } else {
            var viewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = false
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    func tabSwipeNavigation(tabSwipe: CarbonTabSwipeNavigation!, viewControllerAtIndex index: UInt) -> UIViewController!
    //----------------------------------------------------------------------------------------------------------
    {
        switch index {
        case 0:
            var viewController: CurrentSwitcher = storyboard?.instantiateViewControllerWithIdentifier("CurrentSwitcher") as! CurrentSwitcher
            viewController.filter = 0
            return viewController
        case 1:
            var viewController: CurrentSwitcher = storyboard?.instantiateViewControllerWithIdentifier("CurrentSwitcher") as! CurrentSwitcher
            viewController.filter = 1
            return viewController

        case 2:
            var viewController: CurrentSwitcher = storyboard?.instantiateViewControllerWithIdentifier("CurrentSwitcher") as! CurrentSwitcher
            viewController.filter = 2
            return viewController

        case 3:
            var viewController: CurrentSwitcher = storyboard?.instantiateViewControllerWithIdentifier("CurrentSwitcher") as! CurrentSwitcher
            viewController.filter = 3
            return viewController
            
        default:
            var viewController: CurrentSwitcher = storyboard?.instantiateViewControllerWithIdentifier("CurrentSwitcher") as! CurrentSwitcher
            viewController.filter = 0
            return viewController
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tabSwipeNavigation(tabSwipe: CarbonTabSwipeNavigation!, didMoveAtIndex index: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        
    }
    
}
