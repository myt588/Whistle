//
//  WEButtons.swift
//  Whistle
//
//  Created by Yetian Mao on 10/29/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class WEShareButton: UIButton {
    
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

class WEReviewButton: UIButton {
    
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

class WEChatButton: UIButton {
    
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
    }
}

