//
//  FavorListTable.swift
//  Whistle
//
//  Created by Lu Cao on 7/2/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
import ParseUI
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class FavorListTable: UITableViewController, TSMessageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var isLoadingMore                           : Bool = false {
        didSet {
            if isLoadingMore {
                tableView.contentInset                  = UIEdgeInsetsMake(0, 0, 50, 0)
                loadMoreIcon.frame                      = CGRectMake(loadMoreView.frame.size.width - 60, 0, 50, 50)
                loadMoreIcon.image                      = UIImage(named: "favor_loading_more")
            } else {
                tableView.contentInset                  = UIEdgeInsetsMake(0, 0, 0, 0)
                loadMoreIcon.frame                      = CGRectMake(loadMoreView.frame.size.width - 60, 0, 50, 50)
                loadMoreIcon.image                      = UIImage(named: "favor_load_more")
            }
        }
    }
    private var dataLoaded                              : Bool = false
    private var rc                                      = YALSunnyRefreshControl()
    private var transitionOperator                      = WESlideTransition()
    private var loadMoreView                            = UIView()
    private var loadMoreIcon                            = UIImageView()
    //----------------------------------------------------------------------------------------------------------
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        let tabC = tabBarController as? YALFoldingTabBarController
        tabC?.tabBarView.hidden = true
        tableView.contentInset                          = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.autoresizesSubviews                   = true
        tableView.estimatedRowHeight                    = 180
        self.title                                      = "List of Favors"
        rc = YALSunnyRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "loadFavors")
        if mainFavors == 0 {
            println("no favors at the moment")
        } else {
            println("has favors")
            println(mainFavors.count)
            skip = 0
            fetchData(makeRange())
        }
        loadMoreView = UIView(frame: CGRectMake(0, tableView.contentSize.height, view.frame.width, 50))
        loadMoreIcon = UIImageView(frame: CGRectMake(loadMoreView.frame.size.width - 60, 0, 50, 50))
        loadMoreIcon.image = UIImage(named: "favor_load_more")
        loadMoreView.addSubview(loadMoreIcon)
        tableView.addSubview(loadMoreView)
        loadMoreView.hidden = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
        TSMessage.setDelegate(self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func loadFavors()
    {
        let favorQuery : PFQuery = PFQuery(className: Constants.Favor.Name)
        if distance == nil {
            if let edge = edge {
                let ne = PFGeoPoint(latitude: edge.ne.latitude, longitude: edge.ne.longitude)
                let sw = PFGeoPoint(latitude: edge.sw.latitude, longitude: edge.sw.longitude)
                favorQuery.whereKey(Constants.Favor.Location, withinGeoBoxFromSouthwest: sw, toNortheast: ne)
            } else if let distance = distance {
                favorQuery.whereKey(Constants.Favor.Location, nearGeoPoint: currentLocation!, withinMiles: distance)
            }
        }

        if let sortBy = sortBy {
            switch sortBy {
            case 0:
                favorQuery.orderByDescending(Constants.Favor.CreatedAt)
            case 1:
                favorQuery.orderByDescending(Constants.Favor.Price)
            default:
                break
            }
        }
        
        if let gender = gender {
            let query = PFUser.query()
            query?.whereKey(Constants.User.Gender, equalTo: gender)
            favorQuery.whereKey(Constants.Favor.CreatedBy, matchesQuery: query!)
        }
        
        if let distance = distance {
            favorQuery.whereKey(Constants.Favor.Location, nearGeoPoint: currentLocation!, withinMiles: distance)
        } else {
            favorQuery.whereKey(Constants.Favor.Location, nearGeoPoint: currentLocation!, withinMiles: Constants.Favor.DefaultMileRange)
        }
        
        favorQuery.selectKeys([Constants.Favor.Location, Constants.Favor.Status, Constants.Favor.CreatedBy])
        favorQuery.limit = Constants.Favor.MapPaginationLimit
        favorQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = objects {
                mainFavors.removeAllObjects()
                filteredMain.removeAllObjects()
                if objects.count != 0 {
                    mainFavors.addObjectsFromArray(objects)
                    NSNotificationCenter.defaultCenter().postNotificationName("loadFavors", object: nil)
                    skip = 0
                    self.isLoadingMore = false
                    self.fetchData(self.makeRange())
                } else {
                    self.dataLoaded = false
                    self.tableView.reloadData()
                    TSMessage.showNotificationWithTitle("No More", subtitle: "There isn't any favors at the momement", type: TSMessageNotificationType.Error)
                }
            } else {
                TSMessage.showNotificationWithTitle("No Internet", subtitle: "Please check your internet connection", type: TSMessageNotificationType.Error)
            }
            self.rc.endRefreshing()
            self.loadMoreView.frame = CGRectMake(0, self.tableView.contentSize.height, self.view.frame.width, 50)
            self.loadMoreView.hidden = false
        }
    }
    
    func fetchData(range: NSRange?)
    {
        if let range = range {
            let array = mainFavors.subarrayWithRange(range)
            PFObject.fetchAllInBackground(array, block: { (objects, error) -> Void in
                if let objects = objects as? [PFObject] {
                    var favors = [PFObject]()
                    for index in 0...objects.count-1 {
                        let favor = objects[index]
                        if let address = favor[Constants.Favor.Address] as? String {
                            if let location = currentLocation {
                                let location2 = favor[Constants.Favor.Location] as? PFGeoPoint
                                let distance : Double = location.distanceInMilesTo(location2)
                                favor[Constants.Favor.Distance] = distance.roundTo1
                            } else {
                                println("can't find current location")
                            }
                        }
                        favors.append(favor)
                    }
                    mainFavors.replaceObjectsInRange(range, withObjectsFromArray: favors)
                    skip = skip + range.length
                    self.dataLoaded = true
                    NSNotificationCenter.defaultCenter().postNotificationName("loadFavors", object: nil)
                    self.tableView.reloadData()
                } else {
                    println("network error")
                }
            })
            self.rc.endRefreshing()
            self.loadMoreView.frame = CGRectMake(0, self.tableView.contentSize.height, self.view.frame.width, 50)
            self.loadMoreView.hidden = false
        } else {
            println("end of array")
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func loadMore(edge: Edges?)
    //----------------------------------------------------------------------------------------------------------
    {
        if mainFavors.count == 0 {
            return
        }
    
        let favorQuery : PFQuery = PFQuery(className: Constants.Favor.Name)
        favorQuery.includeKey(Constants.Favor.CreatedBy)
        if let favor = mainFavors[mainFavors.count - 1] as? PFObject {
            favorQuery.whereKey(Constants.Favor.CreatedAt, lessThan: favor.createdAt!)
        }
        if let edge = edge {
            let ne = PFGeoPoint(latitude: edge.ne.latitude, longitude: edge.ne.longitude)
            let sw = PFGeoPoint(latitude: edge.sw.latitude, longitude: edge.sw.longitude)
            favorQuery.whereKey(Constants.Favor.Location, withinGeoBoxFromSouthwest: sw, toNortheast: ne)
        }
        favorQuery.orderByDescending(Constants.Favor.CreatedAt)
        favorQuery.limit = Constants.Favor.TablePaginationLimit
        favorQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = objects {
                if objects.count != 0 {
                    mainFavors.addObjectsFromArray(objects)
                    NSNotificationCenter.defaultCenter().postNotificationName("loadFavors", object: nil)
                    self.tableView.reloadData()
                } else {
                    TSMessage.showNotificationWithTitle("Favors", subtitle: "No more favors currently.", type: TSMessageNotificationType.Message)
                }
            } else {
                TSMessage.showNotificationWithTitle("No Internet", subtitle: "Please check your internet connection", type: TSMessageNotificationType.Error)
            }
            self.refreshControl?.endRefreshing()
            self.loadMoreView.frame = CGRectMake(0, self.tableView.contentSize.height, self.view.frame.width, 50)
            self.loadMoreView.hidden = false
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func makeRange() -> NSRange?
    //----------------------------------------------------------------------------------------------------------
    {
        println(skip)
        println(mainFavors.count)
        if skip >= mainFavors.count {
            return nil
        } else {
            let num = skip + Constants.Favor.TablePaginationLimit
            if num < mainFavors.count {
                return NSMakeRange(skip, Constants.Favor.TablePaginationLimit)
            } else {
                return NSMakeRange(skip, mainFavors.count - skip)
            }
        }
    }
    
    
    //----------------------------------------------------------------------------------------------------------
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
        if isLoadingMore {
            println("tt")
            return mainFavors.count
        } else {
            if dataLoaded {
                return skip
            } else {
                return 0
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //----------------------------------------------------------------------------------------------------------
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavorListCell", forIndexPath: indexPath) as! FavorListCell
        cell.bindData(mainFavors[indexPath.row] as? PFObject, index: indexPath.row)
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        if (scrollView.contentOffset.y > (scrollView.contentSize.height - (scrollView.frame.size.height - 60))) {
            if isLoadingMore {
                loadMore(edge)
            }
            if let range = makeRange() {
                println(range)
                fetchData(range)
            } else {
                println("load More")
                isLoadingMore = true
                loadMore(edge)
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //----------------------------------------------------------------------------------------------------------
    {
        mainIndex = indexPath.row
        NSNotificationCenter.defaultCenter().postNotificationName("favorPicked", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
    
}
