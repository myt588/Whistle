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

protocol ProfileScrollDelegate {
    func expand()
    func shrink()
}

//----------------------------------------------------------------------------------------------------------
class ProfileFavorsTable: UITableViewController, UIScrollViewDelegate
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var favors : NSMutableArray                                 = NSMutableArray()
    var pointNow : CGPoint?
    var totalEarned : Int                                       = Int()
    var totalSpent : Int                                        = Int()
    var delegate : ProfileScrollDelegate?
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "loadFavors", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool) {
    //----------------------------------------------------------------------------------------------------------
        super.viewWillAppear(animated)
        if let user = PFUser.currentUser() {
            loadFavors()
        }
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.contentInset                                  = UIEdgeInsetsMake(35, 0, YALTabBarViewDefaultHeight + 30, 0)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func loadFavors()
    //----------------------------------------------------------------------------------------------------------
    {
        let favorQuery : PFQuery = PFQuery(className: Constants.Favor.Name)
        favorQuery.whereKey(Constants.Favor.CreatedBy, equalTo: PFUser.currentUser()!)
        favorQuery.whereKey(Constants.Favor.Status, containedIn: [
            Status.OwnerConfirmed.hashValue
            ])
        
        let assistQuery : PFQuery = PFQuery(className: Constants.Favor.Name)
        assistQuery.whereKey(Constants.Favor.AssistedBy, equalTo: PFUser.currentUser()!)
        assistQuery.whereKey(Constants.Favor.Status, containedIn: [
            Status.OwnerConfirmed.hashValue
            ])
        
        let query : PFQuery = PFQuery.orQueryWithSubqueries([favorQuery, assistQuery])
        query.orderByDescending(Constants.Favor.UpdatedAt)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.favors.removeAllObjects()
                self.favors.addObjectsFromArray(objects!)
                println("favor count \(self.favors.count)")
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
        return favors.count + 2
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //----------------------------------------------------------------------------------------------------------
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileFavorCell", forIndexPath: indexPath) as! ProfileFavorCell
        
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
                cell.vc = self
            } else if indexPath.row != favors.count+1 {
                cell.bindData(favor, previousFavor: nil)
                cell.vc = self
            }
        }
        
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //----------------------------------------------------------------------------------------------------------
    {
        if indexPath.row == 0 {
            return 23
        } else if indexPath.row == favors.count + 1 {
            return 30
        } else {
            return 130
        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //----------------------------------------------------------------------------------------------------------
    {
        println(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > pointNow?.y {
//            delegate?.expand()
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < -50) {
//            delegate?.shrink()
        }
    }
    
}









