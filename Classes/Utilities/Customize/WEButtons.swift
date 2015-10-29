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
                }
            }
        }
    }
}

class WEConfirmButton: UIButton {
    
    var favor: PFObject?
    var vc: CurrentSwitcher!
    var index: Int!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(favor: PFObject, vc: CurrentSwitcher, index: Int) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.favor = favor
        self.vc = vc
        self.index = index
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        if let vc = self.vc {
            let alert = WEAlertController(title: "Confirm", message: "Are you sure that your favor is successfully delivered", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 3
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.index)
                                vc.tableView.reloadData()
                                MessageHandler.message(MessageName.Confirmed)
                            })
                        } else {
                            ParseErrorHandler.handleParseError(error)
                        }
                    })
                }
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

class WECancelButton: UIButton {
    
    var favor: PFObject?
    var vc: CurrentSwitcher!
    var index: Int!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(favor: PFObject, vc: CurrentSwitcher, index: Int) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.favor = favor
        self.vc = vc
        self.index = index
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        if let vc = self.vc {
            let alert = WEAlertController(title: "Cancel", message: "Are you certain?", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "OK", style: .OK) { action in
                if let favor = self.favor {
                    favor[Constants.Favor.Status] = 5
                    favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                vc.favors.removeObjectAtIndex(self.index)
                                vc.tableView.reloadData()
                            })
                        } else {
                            ParseErrorHandler.handleParseError(error)
                        }
                    })
                }
                })
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

class WEChatButton: UIButton {
    
    var user: PFUser?
    var vc: CurrentSwitcher!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    init(user: PFUser, vc: CurrentSwitcher) {
        super.init(frame: CGRectMake(0, 0, 50, 50))
        self.user = user
        self.vc = vc
        self.addTarget(self, action: "action", forControlEvents: .TouchUpInside)
    }
    
    func action()
    {
        println("chat")
    }
}

