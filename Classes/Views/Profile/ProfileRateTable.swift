//
//  ProfileRateTable.swift
//  Whistle
//
//  Created by Lu Cao on 8/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileRateTable: UITableViewController {
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var reviews : NSMutableArray                                 = NSMutableArray()
    var user : PFUser?
    var isPushed : Bool = false
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 150
        self.tableView.autoresizesSubviews = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = "Review"
        
        configLooks()
        self.tableView.registerNib(UINib(nibName: "WEEmptyTableCell", bundle: nil), forCellReuseIdentifier: "WEEmptyTableCell")
        self.tableView.registerNib(UINib(nibName: "WEReviewCell", bundle: nil), forCellReuseIdentifier: "WEReviewCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "load", name: "loadReview", object: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool) {
    //----------------------------------------------------------------------------------------------------------
        super.viewWillAppear(animated)
        if user != nil {
            (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = true
            load()
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.backgroundColor = Constants.Color.TableBackground
        if isPushed {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            tableView.contentInset = UIEdgeInsetsMake(50, 0, YALTabBarViewDefaultHeight + 30, 0)
        }
    }
    
    func setQuery() -> PFQuery {
        let query = PFQuery(className: Constants.UserReviewPivotTable.Name)
        query.includeKey(Constants.UserReviewPivotTable.From)
        query.whereKey(Constants.UserReviewPivotTable.To, equalTo: self.user!)
        query.orderByDescending(Constants.Favor.UpdatedAt)
        query.limit = 5
        return query
    }
    
    //----------------------------------------------------------------------------------------------------------
    func load()
    //----------------------------------------------------------------------------------------------------------
    {
        let query = setQuery()
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
    
    func loadMore()
    {
        if self.reviews.count < 5 {
            return
        }
        let query = setQuery()
        query.whereKey(Constants.UserReviewPivotTable.CreatedAt, lessThan: (reviews.lastObject as! PFObject).createdAt!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                println(objects?.count)
                self.reviews.addObjectsFromArray(objects!)
                println("review count \(self.reviews.count)")
                self.tableView.reloadData()
            } else {
                println("network error")
            }
            self.refreshControl?.endRefreshing()
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
        if reviews.count == 0
        {
            return 1
        }
        return reviews.count
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //----------------------------------------------------------------------------------------------------------
    {
        if reviews.count == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("WEEmptyTableCell", forIndexPath: indexPath) as! WEEmptyTableCell
            cell.bindData(message: "No one has reviewed yet",
                subMessage: "No one ~~~~~",
                image: UIImage(named: "favor_whistle_icon")!)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("WEReviewCell", forIndexPath: indexPath) as! WEReviewCell
        cell.bindData(reviews[indexPath.row] as? PFObject)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if reviews.count == 0 {
            return 
        }
        if let base = UIApplication.topViewController()
        {
            let vc = base.storyboard?.instantiateViewControllerWithIdentifier("ProfileReviewDetailView") as! ProfileReviewDetailView
            vc.review = reviews[indexPath.row] as? PFObject
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    //----------------------------------------------------------------------------------------------------------
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        if (scrollView.contentOffset.y > (scrollView.contentSize.height - (scrollView.frame.size.height - 60))) {
            loadMore()
        }
    }

}
