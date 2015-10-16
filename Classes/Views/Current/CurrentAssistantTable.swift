//
//  CurrentAssistantTable.swift
//  Whistle
//
//  Created by Lu Cao on 7/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class CurrentAssistantTable: UITableViewController, TSMessageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    // Parse
    private var favor: PFObject!
    private var pivots : NSMutableArray = NSMutableArray()
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var rc = YALSunnyRefreshControl()
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        tableView.autoresizesSubviews = true
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        rc = YALSunnyRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "loadUsers")
        loadUsers()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor: PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        if let favor = favor {
            self.favor = favor
        } else {
            TSMessage.showNotificationWithTitle("Error", subtitle: "no favor loaded", type: TSMessageNotificationType.Error)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func loadUsers()
    //----------------------------------------------------------------------------------------------------------
    {
        let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
        query.includeKey(Constants.FavorUserPivotTable.Favor)
        query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.pivots.removeAllObjects()
                self.pivots.addObjectsFromArray(objects!)
                self.tableView.reloadData()
            } else {
                TSMessage.showNotificationWithTitle("No Internet", subtitle: "Please check your internet connection", type: TSMessageNotificationType.Error)
            }
            self.rc.endRefreshing()
        }
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return 1
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return pivots.count
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //----------------------------------------------------------------------------------------------------------
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentAssistantCell", forIndexPath: indexPath) as! CurrentAssistantCell
        if let pivot = pivots[indexPath.row] as? PFObject {
            cell.bindData(pivot[Constants.FavorUserPivotTable.Takers] as? PFUser, favor: favor)
            cell.hireButton.tag = indexPath.row
            cell.hireButton.addTarget(self, action: "hire:", forControlEvents: .TouchUpInside)
        } else {
            TSMessage.showNotificationWithTitle("Error", subtitle: "no pivot loaded", type: TSMessageNotificationType.Error)
        }
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    func hire(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        if let pivot = pivots[sender.tag] as? PFObject {
            if let user = pivot[Constants.FavorUserPivotTable.Takers] as? PFUser {
                favor[Constants.Favor.AssistedBy] = user
                favor[Constants.Favor.Status] = 2
                favor.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        if let ownerPrice = self.favor[Constants.Favor.Price] as? Int {
                            if let takerPrice = pivot[Constants.FavorUserPivotTable.Price] as? Int {
                                if ownerPrice != takerPrice {
                                    self.favor[Constants.Favor.Price] = takerPrice
                                    self.favor.saveInBackground()
                                    SendPushNotification2([user.objectId!], "Has hired you")
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                        } else {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        TSMessage.showNotificationWithTitle("Success", subtitle: "Assistant hired successfully.", type: TSMessageNotificationType.Success)
                    } else {
                        TSMessage.showNotificationWithTitle("Error", subtitle: "Something went wrong, please try again.", type: TSMessageNotificationType.Error)
                    }
                })
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
    
}
