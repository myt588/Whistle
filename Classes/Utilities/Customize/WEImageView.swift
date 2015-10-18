//
//  WEImageView.swift
//  Whistle
//
//  Created by Lu Cao on 7/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import ParseUI
import Parse
import UIKit

//----------------------------------------------------------------------------------------------------------
class WEImageView: PFImageView
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser?
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        
        self.contentMode = UIViewContentMode.ScaleAspectFill
        
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        self.addGestureRecognizer(gesture)
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        self.addGestureRecognizer(tap)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func longPressed(sender: UILongPressGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        if sender.state == UIGestureRecognizerState.Began
        {
            let viewController = ProfileASController()
            viewController.user = user
            let alert = WEAlertController(view: viewController.view, style: .ActionSheet)
            showAlert(alert)
        }
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        println("picture tapped")
        if let base = UIApplication.topViewController()
        {
            var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ProfileOthers") as! ProfileOthersView
            vc.user = self.user
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func showAlert(alert: SimpleAlert.Controller)
    //----------------------------------------------------------------------------------------------------------
    {
        if let vc = UIApplication.topViewController() {
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel) { action in
                })
            alert.addAction(SimpleAlert.Action(title: "Chat", style: .Default) { action in
                })
            alert.addAction(SimpleAlert.Action(title: "Add Friend", style: .Default) { action in
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
}










