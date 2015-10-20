//
//  ProfileRateTable.swift
//  Whistle
//
//  Created by Lu Cao on 8/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileRateTable: UITableViewController {
    
    var reviews : NSMutableArray                                 = NSMutableArray()
    var user : PFUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.translucent = false
        tableView.autoresizesSubviews = true
        tableView.estimatedRowHeight = 100
        title = "Ratings"
        load()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func load()
    //----------------------------------------------------------------------------------------------------------
    {
        let query = PFQuery(className: Constants.UserReviewPivotTable.Name)
        query.includeKey(Constants.UserReviewPivotTable.From)
        query.whereKey(Constants.UserReviewPivotTable.To, equalTo: self.user!)
        query.orderByDescending(Constants.Favor.UpdatedAt)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.reviews.removeAllObjects()
                self.reviews.addObjectsFromArray(objects!)
                println("review count \(self.reviews.count)")
                self.tableView.reloadData()
            } else {
                println("network error")
            }
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileRateCell", forIndexPath: indexPath) as! ProfileRateCell
        cell.bindData(reviews[indexPath.row] as? PFObject)
        return cell
    }

}
