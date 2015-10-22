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
        let query1 = PFQuery(className: Constants.People.Name)
        query1.whereKey(Constants.People.User1, equalTo: PFUser.currentUser()!)
        query1.whereKey(Constants.People.User2, equalTo: user!)
        
        let query2 = PFQuery(className: Constants.People.Name)
        query2.whereKey(Constants.People.User2, equalTo: PFUser.currentUser()!)
        query2.whereKey(Constants.People.User1, equalTo: user!)
        
        let query : PFQuery = PFQuery.orQueryWithSubqueries([query1, query2])
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let object = object {
                if sender.state == UIGestureRecognizerState.Began
                {
                    let viewController = ProfileASController()
                    viewController.user = self.user
                    let alert = WEAlertController(view: viewController.view, style: .ActionSheet)
                    self.showAlert(alert)
                }
            }
        }
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        println("picture tapped")
        let query1 = PFQuery(className: Constants.People.Name)
        query1.whereKey(Constants.People.User1, equalTo: PFUser.currentUser()!)
        query1.whereKey(Constants.People.User2, equalTo: user!)
        
        let query2 = PFQuery(className: Constants.People.Name)
        query2.whereKey(Constants.People.User2, equalTo: PFUser.currentUser()!)
        query2.whereKey(Constants.People.User1, equalTo: user!)
        
        let query : PFQuery = PFQuery.orQueryWithSubqueries([query1, query2])
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let base = UIApplication.topViewController() {
                var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ProfileOthers") as! ProfileOthersView
                vc.user = self.user
                if let object = object {
                    vc.isFriend = true
                }
                base.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func showAlert(alert: SimpleAlert.Controller)
    //----------------------------------------------------------------------------------------------------------
    {
        if let vc = UIApplication.topViewController() {
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "Message", style: .Default) { action in
                let user1 = PFUser.currentUser()
                let groupId = StartPrivateChat(user1!, self.user!)
                let chatView = ChatView(with: groupId)
                vc.navigationController?.pushViewController(chatView, animated: true)
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
}










