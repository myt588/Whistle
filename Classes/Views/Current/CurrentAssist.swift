//
//  CurrentAssist.swift
//  Whistle
//
//  Created by Lu Cao on 7/23/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class CurrentAssist: UITableViewController, TSMessageViewProtocol
    //----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    var favors : NSMutableArray = NSMutableArray()
    var selectedIndex : Int!
    var filter : Int = 1
    private var rc = YALSunnyRefreshControl()
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
        //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        tableView.autoresizesSubviews = true
        tableView.estimatedRowHeight = 200
        rc = YALSunnyRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "loadFavors")
        loadFavors()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
        //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
        
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func loadFavors()
        //----------------------------------------------------------------------------------------------------------
    {
        var query : PFQuery?
        switch filter
        {
        case 0:                                 // my favors
            query = queryFavors()
        case 1:                                 // my assists
            query = queryAssists()
        case 2:                                 // my history
            query = queryHistory()
        case 3:                                 // my interest
            query = queryInterested()
        default:
            break
        }
        
        query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects {
                if self.filter != 3 {
                    self.favors.removeAllObjects()
                    self.favors.addObjectsFromArray(objects)
                    self.tableView.reloadData()
                } else {
                    self.favors.removeAllObjects()
                    self.favors.addObjectsFromArray(objects)
                    println("favor count \(self.favors.count)")
                    var sortedArray = sorted(self.favors) {
                        (obj1, obj2) in
                        let p1 = obj1 as! PFObject
                        let p2 = obj2 as! PFObject
                        return (p1.updatedAt!.compare(p2.updatedAt!) == NSComparisonResult.OrderedDescending)
                    }
                    self.favors.removeAllObjects()
                    self.favors.addObjectsFromArray(sortedArray)
                    self.tableView.reloadData()
                }
            } else {
                TSMessage.showNotificationWithTitle("No Internet", subtitle: "Please check your internet connection", type: TSMessageNotificationType.Error)
            }
            self.rc.endRefreshing()
        })
    }
    
    func queryFavors() -> PFQuery {
        let query = PFQuery(className: Constants.Favor.Name)
        query.whereKey(Constants.Favor.CreatedBy, equalTo: PFUser.currentUser()!)
        query.whereKey(Constants.Favor.Status, containedIn: [0, 1, 2, 3])
        query.orderByDescending(Constants.Favor.UpdatedAt)
        return query
    }
    
    func queryAssists() -> PFQuery {
        let query = PFQuery(className: Constants.Favor.Name)
        query.whereKey(Constants.Favor.AssistedBy, equalTo: PFUser.currentUser()!)
        query.whereKey(Constants.Favor.Status, containedIn: [0, 1, 2])
        query.orderByDescending(Constants.Favor.UpdatedAt)
        return query
    }
    
    func queryHistory() -> PFQuery {
        let favorQuery = PFQuery(className: Constants.Favor.Name)
        favorQuery.whereKey(Constants.Favor.CreatedBy, equalTo: PFUser.currentUser()!)
        favorQuery.whereKey(Constants.Favor.Status, containedIn: [4, 5])
        
        let assistQuery = PFQuery(className: Constants.Favor.Name)
        assistQuery.whereKey(Constants.Favor.AssistedBy, equalTo: PFUser.currentUser()!)
        assistQuery.whereKey(Constants.Favor.Status, containedIn: [3, 4, 5])
        
        let query : PFQuery = PFQuery.orQueryWithSubqueries([favorQuery, assistQuery])
        query.includeKey(Constants.Favor.CreatedBy)
        query.includeKey(Constants.Favor.AssistedBy)
        query.orderByDescending(Constants.Favor.UpdatedAt)
        //query.fromLocalDatastore()
        return query
    }
    
    func queryInterested() -> PFQuery {
        let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
        query.includeKey(Constants.FavorUserPivotTable.Favor)
        query.whereKey(Constants.FavorUserPivotTable.Takers, equalTo: PFUser.currentUser()!)
        query.orderByDescending(Constants.Favor.UpdatedAt)
        return query
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
        return favors.count
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        //----------------------------------------------------------------------------------------------------------
    {
        let assistCell = tableView.dequeueReusableCellWithIdentifier("CurrentAssistCell", forIndexPath: indexPath) as! CurrentAssistCell
        let favorCell = tableView.dequeueReusableCellWithIdentifier("CurrentFavorCell", forIndexPath: indexPath) as! CurrentFavorCell
        let favor = favors[indexPath.row] as! PFObject
        let user = PFUser.currentUser()
        if favor.parseClassName == Constants.Favor.Name {
            if (favor[Constants.Favor.CreatedBy] as! PFUser) == user {
                favorCell.bindData(favor)
                switch favor[Constants.Favor.Status] as! Int {
                case 1:
                    favorCell.statusButton.tag = indexPath.row
                    favorCell.statusButton.addTarget(self, action: "showTakers:", forControlEvents: .TouchUpInside)
                case 2:
                    favorCell.statusButton.tag = indexPath.row
                    favorCell.statusButton.addTarget(self, action: "toOwnerProfile:", forControlEvents: .TouchUpInside)
                default:
                    break
                }
                return favorCell
            } else {
                assistCell.bindData(favor)
                return assistCell
            }
        } else {
            assistCell.bindData(favor[Constants.FavorUserPivotTable.Favor] as? PFObject)
            return assistCell
        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
        //----------------------------------------------------------------------------------------------------------
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func toOwnerProfile(sender: UIButton!)
        //----------------------------------------------------------------------------------------------------------
    {
        self.selectedIndex = sender.tag
        performSegueWithIdentifier("Current_to_Profile", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func showTakers(sender: UIButton!)
        //----------------------------------------------------------------------------------------------------------
    {
        self.selectedIndex = sender.tag
        performSegueWithIdentifier("Current_To_Assistant", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
        //----------------------------------------------------------------------------------------------------------
    {
        if segue.identifier == "Current_To_Assistant" {
            var assistantsTable = segue.destinationViewController as! CurrentAssistantTable
            assistantsTable.bindData(favors[selectedIndex] as? PFObject)
        }
        
        if segue.identifier == "Current_to_Profile" {
            var profileView = segue.destinationViewController as! ProfileView
            if let favor = favors[selectedIndex] as? PFObject {
                profileView.user = favor[Constants.Favor.CreatedBy] as? PFUser
            } else {
                println("favor nil")
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

