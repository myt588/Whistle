//
//  WEButtons.swift
//  Whistle
//
//  Created by Yetian Mao on 10/29/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class WEButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(5, 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}

class WEShareButton: WEButton {
    
    var favor: PFObject?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(favor: PFObject) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.favor = favor
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        socialShare(sharingText: "llalala", UIImage(named: "favor_map_icon"), NSURL(string: "http://itunes.apple.com/app/"))
    }
}

class WEReviewButton: WEButton {
    
    var favor: PFObject?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(favor: PFObject) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.favor = favor
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        if let favor = favor {
            let query = PFQuery(className: Constants.UserReviewPivotTable.Name)
            query.whereKey(Constants.UserReviewPivotTable.From, equalTo: PFUser.currentUser()!)
            query.whereKey(Constants.UserReviewPivotTable.Because, equalTo: favor)
            query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                if let object = object {
                    MessageHandler.message(.HaveReviewed)
                } else {
                    println("review")
                    if let base = UIApplication.topViewController()
                    {
                        var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ReviewView") as! CurrentRateView
                        var nav = UINavigationController(rootViewController: vc)
                        base.presentViewController(nav, animated: true, completion: nil)
                        vc.favor = favor
                    }
                }
            }
        }
    }
}

class WEReportButton: UIButton {
    
    var favor: PFObject?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(favor: PFObject) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.favor = favor
        
        var image = UIImage(named: "report")
        let origImage = image
        let tintedImage = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        image = tintedImage
        self.setImage(image, forState: .Normal)
        self.tintColor = Constants.Color.Main2
        
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        if let favor = favor {
            let query = PFQuery(className: Constants.UserReportPivotTable.Name)
            query.whereKey(Constants.UserReportPivotTable.From, equalTo: PFUser.currentUser()!)
            query.whereKey(Constants.UserReportPivotTable.Because, equalTo: favor)
            query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                if let object = object {
                    MessageHandler.message(.HaveReported)
                } else {
                    println("report")
                    if let base = UIApplication.topViewController()
                    {
                        var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ReportTable") as! CurrentReoprtTable
                        var nav = UINavigationController(rootViewController: vc)
                        base.presentViewController(nav, animated: true, completion: nil)
                        vc.favor = favor
                    }
                }
            }
        }
    }
}

class WEChatButton: WEButton {
    
    var user: PFUser?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(user: PFUser, vc: CurrentSwitcher) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.user = user
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        println("chat")
        if let base = UIApplication.topViewController()
        {
            let user1 = PFUser.currentUser()
            let groupId = StartPrivateChat(user1!, self.user!)
            let chatView = ChatView(with: groupId)
            base.navigationController?.pushViewController(chatView, animated: true)
        }
    }
}



