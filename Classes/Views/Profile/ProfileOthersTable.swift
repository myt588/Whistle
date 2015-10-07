//
//  ProfileFavorsTable.swift
//  Whistle
//
//  Created by Lu Cao on 6/28/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------

protocol ProfileOthersScrollDelegate {
    func expand()
    func shrink()
}

//----------------------------------------------------------------------------------------------------------
class ProfileOthersTable: UITableViewController, UIScrollViewDelegate
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var reviews : NSMutableArray                                 = NSMutableArray()
    var pointNow : CGPoint?
    var delegate : ProfileOthersScrollDelegate?
    var user : PFUser?
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        /*
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "loadFavors", forControlEvents: UIControlEvents.ValueChanged)
        */
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool) {
    //----------------------------------------------------------------------------------------------------------
        super.viewWillAppear(animated)
        load()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        //        tableView.autoresizesSubviews = true
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor                               = Constants.Color.TableBackground
        tableView.contentInset                                  = UIEdgeInsetsMake(50, 0, YALTabBarViewDefaultHeight + 30, 0)
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
        return reviews.count
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //----------------------------------------------------------------------------------------------------------
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileOthersCell", forIndexPath: indexPath) as! ProfileOthersCell
        cell.bindData(reviews[indexPath.row] as? PFObject)
        
        
        /*
        if indexPath.row == 0 {
        cell.dotBottom.hidden = false
        cell.portrait.hidden = true
        cell.line.hidden = true
        }
        
        if indexPath.row == favors.count + 1 {
        cell.dotBottom.hidden = false
        cell.portrait.hidden = true
        cell.line.hidden = true
        }
        
        if indexPath.row > 0 && indexPath.row < favors.count + 1{
        let favor = favors[indexPath.row-1] as! PFObject
        if indexPath.row > 1 {
        let prevFavor = favors[indexPath.row-2] as! PFObject
        cell.bindData(favor, previousFavor: prevFavor)
        } else if indexPath.row != favors.count+1 {
        cell.bindData(favor, previousFavor: nil)
        }
        }
        */
        
        return cell
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > pointNow?.y {
            delegate?.expand()
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < -60) {
            delegate?.shrink()
        }
    }
    
}









