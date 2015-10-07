//
//  FavorView.swift
//  Whistle
//
//  Created by Lu Cao on 6/24/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//
//  TO DO
//  MapAnnotationCustomization Based on user lvl
//  Navigation bar changed after tap into profile view                      Check
//  Adding Filters to fetch data from server                                Check
//  WEImageView add enable on which views should be able to tap into profileothersview

//----------------------------------------------------------------------------------------------------------
import UIKit
import MapKit
import AVFoundation
import Foundation
import Parse
//----------------------------------------------------------------------------------------------------------

var mainFavors : NSMutableArray = NSMutableArray()
var filteredMain : NSMutableArray = NSMutableArray()
var edge: Edges?
var skip: Int!
var mainIndex: Int = 0 {
    didSet {
        if mainIndex > mainFavors.count - 1 {
            mainIndex = 0
        }
        if mainIndex < 0 {
            mainIndex = mainFavors.count - 1
        }
    }
}
// filter
var didSetFilter: Bool = false
var gender: Int?
var distance: Double?
var sortBy: Int?
var currentLocation: PFGeoPoint?

//----------------------------------------------------------------------------------------------------------
class FavorView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, YALTabBarInteracting, UIGestureRecognizerDelegate, TSMessageViewProtocol, FBClusteringManagerDelegate, WEImageViewProtocol, FavorDetailScrollDelegate
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Map
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var mapView                              : MKMapView!
    @IBOutlet weak var searchButton                         : WEMapButton!
    @IBOutlet weak var refreshButton                        : WEMapButton!
    @IBOutlet weak var centerOnUserButton                   : WEMapButton!
    @IBOutlet weak var listButton                           : WEMapButton!
    @IBOutlet weak var loadingLabel                         : WEContentLabel!
    @IBOutlet weak var circularProgress                     : KYCircularProgress!
    @IBOutlet weak var progressLabel                        : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Table
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var detailView                           : UIView!
    //----------------------------------------------------------------------------------------------------------
    // Portrait
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portraitView                         : UIView!
    @IBOutlet weak var portraitImageView                    : WEImageView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var bannerView                           : UIView!
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    //----------------------------------------------------------------------------------------------------------
    // Constraints
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var mapViewHeightConstraint              : NSLayoutConstraint!
    @IBOutlet weak var mapViewBottomConstraint              : NSLayoutConstraint!
    @IBOutlet weak var tableTopToMapConstraint              : NSLayoutConstraint!
    @IBOutlet weak var tableTopToLayoutConstraint           : NSLayoutConstraint!
    @IBOutlet weak var portraitViewTopConstraint            : NSLayoutConstraint!
    @IBOutlet weak var portraitViewNewTopConstraint         : NSLayoutConstraint!
    @IBOutlet weak var portraitViewCenterConstraint         : NSLayoutConstraint!
    @IBOutlet weak var portraitViewOffConstraint            : NSLayoutConstraint!
    @IBOutlet weak var audioLengthCons                      : NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var timer                                       : NSTimer?
    private var manager                                     : CLLocationManager!
    private var isCenteredOnUserLocation                    = false
    private var annotations                                 = [FBAnnotation]()
    private var tableView                                   : FavorDetailTable?
    private var clusteringManager                           : FBClusteringManager?
    private var progress                                    : UInt8 = 0
    private var progressFirer                               : NSTimer!
    //----------------------------------------------------------------------------------------------------------
    private var displayerMode                               : Int = 0   // 0: all map; 1: Splitted; 2: all table
    private var mapViewOriginalFrame                        : CGRect?
    private var detailViewOriginalFrame                     : CGRect?
    private var portraitViewOriginalFrame                   : CGRect?
    //----------------------------------------------------------------------------------------------------------
    private var isAnimatingDisplay                          = true
    private var didLayoutSubviews                           = false
    private var mapChangedByUserGesture                     = false
    private var canSwipeIndex                               = true
    private var didLoadFavor                                = false
    //----------------------------------------------------------------------------------------------------------
    private var didSelectFavor                              = false
    //----------------------------------------------------------------------------------------------------------
    private var transitionOperator                          = WESlideTransition()
    private var isSearchHidden                              = true
    //----------------------------------------------------------------------------------------------------------
    private var userToPass                                  : PFUser?
    //----------------------------------------------------------------------------------------------------------
    private var canExpand                                   = true
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        configContainerView()
        configMapView()
        configureCircularProgress()
        addGestures()
        portraitImageView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadScene", name: "loadFavors", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "favorPicked", name: "favorPicked", object: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(animated)
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
        view.backgroundColor = Constants.Color.Main
        didLoadFavor = false
        (tabBarController as? YALFoldingTabBarController)?.tabBarView.hidden = false
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        configShapes()
        if !didLayoutSubviews {
            //--------------------------------------------------------------------------------------------------
            // Setup Defaults
            //--------------------------------------------------------------------------------------------------
            self.mapViewOriginalFrame = CGRectMake(0, 0, view.bounds.width, view.bounds.height/2)
            self.detailViewOriginalFrame = CGRectMake(0, view.bounds.height/2, view.bounds.width, view.bounds.height/2)
            self.portraitViewOriginalFrame = self.portraitView.frame
            isAnimatingDisplay = false
            //--------------------------------------------------------------------------------------------------
            didLayoutSubviews = !didLayoutSubviews
        }
        
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    @IBAction func searchButtonTapped(sender: WEMapButton)
    //----------------------------------------------------------------------------------------------------------
    {
        let alert = WEAlertController(title: nil, message: nil, style: .ActionSheet)
        alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
        alert.addAction(SimpleAlert.Action(title: "All Gender", style: .Default) { action in
            gender = nil
            if let edge = edge {
                self.loadFavors(edge)
            }
        })
        alert.addAction(SimpleAlert.Action(title: "Females Only", style: .Default) { action in
            gender = 0
            if let edge = edge {
                self.loadFavors(edge)
            }
        })
        alert.addAction(SimpleAlert.Action(title: "Males Only", style: .Default) { action in
            gender = 1
            if let edge = edge {
                self.loadFavors(edge)
            }
        })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    @IBAction func refreshButtonTapped(sender: WEMapButton)
    //----------------------------------------------------------------------------------------------------------
    {
        loadFavors(mapView.edgePoints())
    }
    
    //----------------------------------------------------------------------------------------------------------
    @IBAction func listButtonTapped(sender: WEMapButton)
    //----------------------------------------------------------------------------------------------------------
    {

    }

    //----------------------------------------------------------------------------------------------------------
    @IBAction func centerMapOnUserButtonTapped(sender: WEMapButton)
    //----------------------------------------------------------------------------------------------------------
    {
        centerMapOnUser()
    }
    
    // MARK: - User interactions
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        var swipeRight              = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeRight.direction        = UISwipeGestureRecognizerDirection.Right
        detailView.addGestureRecognizer(swipeRight)
        portraitImageView.addGestureRecognizer(swipeRight)
        
        var swipeLeft               = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeLeft.direction         = UISwipeGestureRecognizerDirection.Left
        detailView.addGestureRecognizer(swipeLeft)
        portraitImageView.addGestureRecognizer(swipeLeft)
        
        var swipeUp                 = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeUp.direction           = UISwipeGestureRecognizerDirection.Up
        portraitImageView.addGestureRecognizer(swipeUp)
        
        var swipeDown               = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeDown.direction         = UISwipeGestureRecognizerDirection.Down
        portraitImageView.addGestureRecognizer(swipeDown)
        
        var panGesture              = UIPanGestureRecognizer(target: self, action: "respondToGestures:")
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
        
        var pinchGesture            = UIPinchGestureRecognizer(target: self, action: "respondToGestures:")
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(pinchGesture)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func respondToGestures(gesture: UIGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if displayerMode == 2 { break }
                if !canSwipeIndex { break }
                mainIndex++
                switchFavor(mainFavors[mainIndex] as? PFObject)
            case UISwipeGestureRecognizerDirection.Left:
                if displayerMode == 2 { break }
                if !canSwipeIndex { break }
                mainIndex--
                switchFavor(mainFavors[mainIndex] as? PFObject)
            case UISwipeGestureRecognizerDirection.Up:
                if displayerMode != 2 { println("by gesture up"); changeDisplayMode(2) }
            case UISwipeGestureRecognizerDirection.Down:
                println("by gesture down")
                displayerMode == 2 ? changeDisplayMode(1) : changeDisplayMode(0)
            default:
                break
            }
        }
        if let panGesture = gesture as? UIPanGestureRecognizer {
            mapChangedByUserGesture = true
        }
        
        if let pinchGesture = gesture as? UIPinchGestureRecognizer {
            mapChangedByUserGesture = true
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func extraLeftItemDidPressed()
    //----------------------------------------------------------------------------------------------------------
    {
        performSegueWithIdentifier("mainToNew", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func extraRightItemDidPressed()  // Did press
    //----------------------------------------------------------------------------------------------------------
    {
        if !didSelectFavor {
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Please select a favor first.", type: TSMessageNotificationType.Warning)
            return
        }
        if let favor = mainFavors[mainIndex] as? PFObject {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser {
                if user.objectId == PFUser.currentUser()?.objectId {
                    TSMessage.showNotificationWithTitle("Warning", subtitle: "You can not pick your own favor", type: TSMessageNotificationType.Warning)
                    return
                }
            }
        }
        progress = 0
        progressLabel.text = "Hold To Interest"
        circularProgress.alpha = 0.95
        progressFirer = NSTimer.scheduledTimerWithTimeInterval(0.005, target: self, selector: Selector("updateProgress"), userInfo: nil, repeats: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func extraRightItemLongPressed() // Did release
    //----------------------------------------------------------------------------------------------------------
    {
        if !didSelectFavor {
            return
        }
        if let favor = mainFavors[mainIndex] as? PFObject {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser {
                if user.objectId == PFUser.currentUser()?.objectId {
                    return
                }
            }
        }
        progress = 0
        circularProgress.progress = 0
        circularProgress.alpha = 0
        progressFirer.invalidate()
    }
    
    //----------------------------------------------------------------------------------------------------------
    func updateProgress()
    //----------------------------------------------------------------------------------------------------------
    {
        progress = progress &+ 1
        let normalizedProgress = Double(progress) / 255.0
        circularProgress.progress = normalizedProgress
        if normalizedProgress == 1 {
            progressFirer.invalidate()
            progressLabel.text = "Interested"
            bounceView(progressLabel)
            fadeOutView(circularProgress, 1)
            isInterested(true)
            if let favor = mainFavors[mainIndex] as? PFObject {
                let relationTable = PFObject(className: Constants.FavorUserPivotTable.Name)
                relationTable[Constants.FavorUserPivotTable.Takers] = PFUser.currentUser()
                relationTable[Constants.FavorUserPivotTable.Favor] = favor
                relationTable[Constants.FavorUserPivotTable.Active] = false
                if self.tableView?.priceLabel.text?.toInt() != favor[Constants.Favor.Price] as? Int {
                    relationTable[Constants.FavorUserPivotTable.Price] = self.tableView?.priceLabel.text?.toInt()
                }
                relationTable.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        TSMessage.showNotificationWithTitle("Interested", subtitle: "Successfully interested the favor.", type: TSMessageNotificationType.Success)
                        favor[Constants.Favor.Status] = 1
                        favor.saveInBackground()
                    } else {
                        ParseErrorHandler.handleParseError(error)
                        TSMessage.showNotificationWithTitle("Interest Failed", subtitle: "There is some problem occured,\nPlease try again.", type: TSMessageNotificationType.Error)
                    }
                })
            }
        }
    }
    
    func interestState(favor: PFObject) {
        let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
        query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
        query.whereKey(Constants.FavorUserPivotTable.Takers, equalTo: PFUser.currentUser()!)
        query.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
            if count == 0 {
                self.isInterested(false)
            } else {
                self.isInterested(true)
            }
        })
    }
    
    func isInterested(isInterested: Bool) {
        let tabBarController = self.tabBarController as? YALFoldingTabBarController
        let tabBarRightItem = tabBarController?.tabBarView.extraRightButton
        tabBarRightItem?.clipsToBounds = false
        
        if !isInterested {
            tabBarRightItem?.setImage(UIImage(named: "tab_interest"), forState: .Normal)
            tabBarRightItem?.enabled = true
        } else {
            let oldImage = tabBarRightItem?.imageView?.image
            let tintedImage = oldImage?.imageWithRenderingMode(.AlwaysTemplate)
            tabBarRightItem!.tintColor = UIColor.yellowColor()
            tabBarRightItem?.setImage(tintedImage, forState: .Normal)
            tabBarRightItem?.enabled = false
            bounceView(tabBarRightItem!.imageView!)
        }
    }

    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func loadFavors(edge: Edges)
    //----------------------------------------------------------------------------------------------------------
    {
        var hud = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.TriplePulse, tintColor: Constants.Color.Banner, size: 35)
        hud.frame = loadingLabel.frame
        hud.alpha = 0.85
        view.addSubview(hud)
        hud.startAnimating()
        let favorQuery : PFQuery = PFQuery(className: Constants.Favor.Name)
        
        // filters
        if let gender = gender {
            let query = PFUser.query()
            query?.whereKey(Constants.User.Gender, equalTo: gender)
            favorQuery.whereKey(Constants.Favor.CreatedBy, matchesQuery: query!)
        }
        
        let ne = PFGeoPoint(latitude: edge.ne.latitude, longitude: edge.ne.longitude)
        let sw = PFGeoPoint(latitude: edge.sw.latitude, longitude: edge.sw.longitude)
        favorQuery.whereKey(Constants.Favor.Location, withinGeoBoxFromSouthwest: sw, toNortheast: ne)
        favorQuery.selectKeys([
            Constants.Favor.Location,
            Constants.Favor.Status,
            Constants.Favor.CreatedBy,
            Constants.Favor.Price
            ])
        favorQuery.limit = Constants.Favor.MapPaginationLimit
        favorQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            hud.removeFromSuperview()
            if let objects = objects {
                mainFavors.removeAllObjects()
                mainFavors.addObjectsFromArray(objects)
                println("\(objects.count) favor loaded")
                NSNotificationCenter.defaultCenter().postNotificationName("loadFavors", object: nil)
            } else {
                ParseErrorHandler.handleParseError(error)
                TSMessage.showNotificationWithTitle("Connection Error", subtitle: "Please check your internet connection", type: TSMessageNotificationType.Error)
            }
        }
    }
    
    
    //----------------------------------------------------------------------------------------------------------
    func switchFavor(favor: PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        println("by gesture swipe")
        if let favor = favor {
            if favor.isDataAvailable() {
                println("fetched")
                self.interestState(favor)
                if self.displayerMode == 1 {
                    self.tableView!.bindData(favor)
                    UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.bannerView.alpha = 0
                        self.detailView.alpha = 0
                        }, completion: { (finished: Bool) -> Void in
                            self.configBanner(favor)
                            self.centerMapOnFavor()
                    })
                    UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.bannerView.alpha = 1
                        self.detailView.alpha = 1
                        }, completion: { (finished: Bool) -> Void in
                    })
                } else {
                    self.tableView!.bindData(favor)
                    self.configBanner(favor)
                    self.centerMapOnFavor()
                    self.changeDisplayMode(1)
                }
                return
            }
            println("fetching")
            canSwipeIndex = false
            var hud = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.NineDots, tintColor: Constants.Color.Banner, size: 35)
            hud.frame = loadingLabel.frame
            hud.alpha = 0.85
            view.addSubview(hud)
            hud.startAnimating()
            favor.fetchInBackgroundWithBlock({ (favor, error) -> Void in
                println("fetching finished")
                hud.removeFromSuperview()
                self.canSwipeIndex = true
                if let favor = favor {
                    mainFavors.replaceObjectAtIndex(mainIndex, withObject: favor)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.interestState(favor)
                        if self.displayerMode == 1 {
                            self.tableView!.bindData(favor)
                            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.bannerView.alpha = 0
                                self.detailView.alpha = 0
                                }, completion: { (finished: Bool) -> Void in
                                    self.configBanner(favor)
                                    self.centerMapOnFavor()
                            })
                            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                                self.bannerView.alpha = 1
                                self.detailView.alpha = 1
                                }, completion: { (finished: Bool) -> Void in
                            })
                        } else {
                            self.tableView!.bindData(favor)
                            self.configBanner(favor)
                            self.centerMapOnFavor()
                            self.changeDisplayMode(1)
                        }
                    }
                } else {
                    ParseErrorHandler.handleParseError(error)
                    TSMessage.showNotificationWithTitle("Interest Failed", subtitle: "There is some problem occured,\nPlease try again.", type: TSMessageNotificationType.Error)
                }
            })
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func loadScene()
    //----------------------------------------------------------------------------------------------------------
    {
        addAnnotations()
        mapView(mapView, regionDidChangeAnimated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func favorPicked()
    //----------------------------------------------------------------------------------------------------------
    {
        self.tableView!.bindData(mainFavors[mainIndex] as? PFObject)
        configBanner(mainFavors[mainIndex] as? PFObject)
        centerMapOnFavor()
        changeDisplayMode(1)
        println("picked")
        didSelectFavor = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        view.backgroundColor                                        = Constants.Color.Background
        portraitView.backgroundColor                                = UIColor.clearColor()
        
        listButton.layer.cornerRadius = 30
        centerOnUserButton.layer.cornerRadius = 20
        refreshButton.layer.cornerRadius = 20
        searchButton.layer.cornerRadius = 20
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configShapes()
    //----------------------------------------------------------------------------------------------------------
    {
        portraitImageView.layer.borderColor                         = Constants.Color.Border.CGColor
        portraitImageView.layer.borderWidth                         = 3
        portraitImageView.layer.cornerRadius                        = portraitImageView.frame.height/2
        portraitImageView.alpha                                     = 1
        nameLabel.textColor                                         = Constants.Color.TextLight
        nameLabel.shadowOffset                                      = CGSizeMake(0, -1)
        nameLabel.layer.cornerRadius                                = 8
        bannerView.backgroundColor                                  = Constants.Color.Banner
        bannerView.alpha                                            = 0.85
    }
    
    //----------------------------------------------------------------------------------------------------------
    func toggleButtonHidden()
    //----------------------------------------------------------------------------------------------------------
    {
        var buttons = [searchButton, refreshButton, centerOnUserButton, listButton]
        for element in buttons {
            element.alpha = 0
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func toggleButtonAppear()
    //----------------------------------------------------------------------------------------------------------
    {
        var buttons = [searchButton, refreshButton, centerOnUserButton, listButton]
        for element in buttons {
            element.alpha = 1
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func changeDisplayMode(mode: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        if isAnimatingDisplay { return }
        
        var tabBarHeight = YALTabBarViewDefaultHeight
        
        switch displayerMode {
        case 0:
            self.isAnimatingDisplay                                 = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.mapViewBottomConstraint.active                 = false
                self.mapView.frame                                  = self.mapViewOriginalFrame!
                self.mapViewHeightConstraint.active                 = true
                
                self.portraitViewOffConstraint.active               = false
                self.portraitView.alpha                             = 1
                self.portraitView.frame.origin.x                    = self.view.frame.origin.x
                self.portraitViewCenterConstraint.active            = true
                
                self.detailView.alpha                               = 1
                
                self.bannerView.hidden                              = false
                
                self.didSelectFavor                                 = true
                
                self.toggleButtonAppear()
                
                }, completion: {
                    (finished: Bool) -> Void in
                    self.displayerMode                              = 1
                    self.isAnimatingDisplay                         = false
                    self.tableView?.setTopMargin1()
                    self.tableView?.scrollToTop()
            })
        case 1:
            self.isAnimatingDisplay                                 = true
            if mode == 0 {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.mapViewHeightConstraint.active             = false
                    self.mapView.frame                              = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                    self.mapViewBottomConstraint.active             = true
                    
                    self.portraitViewCenterConstraint.active        = false
                    self.portraitView.alpha                         = 0
                    self.portraitView.frame                         = self.portraitViewOriginalFrame!
                    self.portraitViewOffConstraint.active           = true
                    
                    self.detailView.alpha                           = 0
                    
                    self.bannerView.hidden                          = true
                    
                    self.didSelectFavor                             = false
                    
                    self.toggleButtonAppear()
                    
                    }, completion: {
                        (finished: Bool) -> Void in
                        self.displayerMode = 0
                        self.isAnimatingDisplay                     = false
                })
            }
            if mode == 2 {
                canExpand = false
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.tableTopToMapConstraint.active             = false
                    self.detailView.alpha                           = 1
                    self.detailView.frame                           = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                    self.tableTopToLayoutConstraint.active          = true
                    
                    self.portraitViewTopConstraint.active           = false
                    self.portraitView.layer.frame.origin.y          = self.view.layer.frame.origin.y
                    self.portraitViewNewTopConstraint.active        = true
                    
                    self.tableView?.setTopMargin2()
                    
                    self.toggleButtonHidden()
                    
                    }, completion: {
                        (finished: Bool) -> Void in
                        self.displayerMode                          = 2
                        self.isAnimatingDisplay                     = false
                        
                })
            }
        case 2:
            self.isAnimatingDisplay                                 = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                self.portraitViewNewTopConstraint.active            = false
                self.portraitView.frame                             = self.portraitViewOriginalFrame!
                self.portraitView.frame.origin.x                    = self.view.frame.origin.x
                self.portraitViewTopConstraint.active               = true
                
                self.tableTopToLayoutConstraint.active              = false
                self.detailView.frame                               = self.detailViewOriginalFrame!
                self.tableTopToMapConstraint.active                 = true
                
                self.tableView?.setTopMargin1()
                
                self.toggleButtonAppear()
                
                }, completion: {
                    (finished: Bool) -> Void in
                    self.displayerMode                              = 1
                    self.isAnimatingDisplay                         = false
                    self.canExpand                                  = true
            })
            
        default:
            return
        }
    }
    
    // MapView
    //----------------------------------------------------------------------------------------------------------
    func configMapView()
    //----------------------------------------------------------------------------------------------------------
    {
        mapView.delegate                                            = self
        mapView.rotateEnabled                                       = false
        manager                                                     = CLLocationManager()
        manager.delegate                                            = self
        manager.desiredAccuracy                                     = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        } else {
            TSMessage.showNotificationWithTitle("Error", subtitle: "Whistle needs access to the location service.", type: TSMessageNotificationType.Error)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func centerMapOnUser()
    //----------------------------------------------------------------------------------------------------------
    {
        let latitude                                                = manager.location.coordinate.latitude
        let longitude                                               = manager.location.coordinate.longitude
        let location: CLLocationCoordinate2D                        = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance                        = 200
        let coordinateRegion                                        = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        currentLocation = PFGeoPoint(latitude: latitude, longitude: longitude)
        mapView.setRegion(coordinateRegion, animated: true)
        mapChangedByUserGesture = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func centerMapOnFavor()
    //----------------------------------------------------------------------------------------------------------
    {
        let location: CLLocationCoordinate2D                        = annotations[mainIndex].coordinate
        let regionRadius: CLLocationDistance                        = 100
        let coordinateRegion                                        = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addAnnotations()
    //----------------------------------------------------------------------------------------------------------
    {
        var index = 0
        annotations.removeAll(keepCapacity: false)
        mapView.removeAnnotations(mapView.annotations)
        for favor in mainFavors {
            let PFLocation = favor[Constants.Favor.Location] as! PFGeoPoint
            let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: PFLocation.latitude, longitude: PFLocation.longitude)
            var annotation = FBAnnotation()
            annotation.coordinate = location
            
            switch favor[Constants.Favor.Status] as! Int {
            case 0:
                annotation.imageName = "map_regular_pin"
            case 1:
                annotation.imageName = "map_interested_pin"
            case 2:
                annotation.imageName = "map_processing_pin"
            default:
                break
            }
            
            annotation.index = index
            annotations.append(annotation)
            index = index + 1
        }
        clusteringManager = nil
        clusteringManager = FBClusteringManager()
        clusteringManager!.addAnnotations(annotations)
        
    }
    
    //----------------------------------------------------------------------------------------------------------
    private func configureCircularProgress()
    //----------------------------------------------------------------------------------------------------------
    {
        circularProgress.colors = [UIColor(rgba: 0xA6E39D11), UIColor(rgba: 0xAEC1E355), UIColor(rgba: 0xAEC1E3AA), UIColor(rgba: 0xF3C0ABFF)]
        circularProgress.lineWidth = 8.0
        circularProgress.alpha = 0
        circularProgress.layer.cornerRadius = 75
//        circularProgress.backgroundColor = Constants.Color.Background
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = circularProgress.bounds
        blurView.layer.cornerRadius = 75
        blurView.clipsToBounds = true
        circularProgress.insertSubview(blurView, atIndex: 0)
    }
    
    // BannerView
    //----------------------------------------------------------------------------------------------------------
    func configBanner(favor: PFObject?) {
    //----------------------------------------------------------------------------------------------------------
        if let favor = favor {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser {
                userToPass = user
                portraitImageView.receiveUser()
                user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                    if let user = user {
                        if let image = user[Constants.User.Portrait] as? PFFile {
                            image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                if let data = data {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.portraitImageView.image = UIImage(data: data)
                                    }
                                } else {
                                    ParseErrorHandler.handleParseError(error)
                                }
                            })
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.nameLabel.text = user[Constants.User.Nickname] as? String
                        }
                    }
                })
            }
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile {
                self.audioView.hidden = false
                audio.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if let data = data {
                        let audioManager = AudioManager()
                        let name = audioNameWithDate()
                        audioManager.saveAudio(data, name: name)
                        let url = audioManager.audioURLWithName(name)
                        self.audioView.contentURL = url
                        var asset = AVURLAsset(URL: audioManager.audioURLWithName(name), options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
                        var duration: CMTime = asset.duration
                        var seconds = Int(CMTimeGetSeconds(duration))
                        self.audioLengthCons.constant = 50 + CGFloat(seconds)*1.67
                    } else {
                        ParseErrorHandler.handleParseError(error)
                    }
                })
            } else {
                self.audioView.hidden = true
            }
        } else {
            TSMessage.showNotificationWithTitle("No Favor", subtitle: "Please wait a little and refresh.", type: TSMessageNotificationType.Error)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    // TableView
    //----------------------------------------------------------------------------------------------------------
    func configContainerView()
    //----------------------------------------------------------------------------------------------------------
    {
        detailView.userInteractionEnabled = true
        tableView = childViewControllers.first as? FavorDetailTable
        tableView?.delegate = self
        tableView?.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
    //----------------------------------------------------------------------------------------------------------
        if !isCenteredOnUserLocation
        {
            centerMapOnUser()
            isCenteredOnUserLocation = true
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    //----------------------------------------------------------------------------------------------------------
    {
        var reuseId = ""
        if annotation.isKindOfClass(FBAnnotationCluster) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
            return clusterView
        } else {
            reuseId = "Pin"
            if !(annotation is FBAnnotation) {
                return nil
            }
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? WEAnnotationView
            annotationView = WEAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            if let annotationView = annotationView {
                annotationView.canShowCallout = false
                let temp = annotation as! FBAnnotation
                annotationView.index = temp.index
                if let favor = mainFavors[temp.index] as? PFObject {
                    let user = favor[Constants.Favor.CreatedBy] as! PFUser
                    user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                        if let user = user {
                            if let image = user[Constants.User.Thumbnail] as? PFFile {
                                image.getDataInBackgroundWithBlock { (data, error) -> Void in
                                    if let data = data {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            annotationView.setImageView(UIImage(data: data)!)
                                        }
                                    } else {
                                        println("can't load image")
                                        ParseErrorHandler.handleParseError(error)
                                    }
                                }
                            }
                        }
                    })
                }
            } else {
                println("annotation error")
                var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinColor = .Green
                return pinView
            }
            return annotationView
        }
    }

    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!)
    //----------------------------------------------------------------------------------------------------------
    {
        if !(view is WEAnnotationView) {
            return
        }
        mapView.deselectAnnotation(view.annotation, animated: true)
        mainIndex = (view as! WEAnnotationView).index
        switchFavor(mainFavors[mainIndex] as? PFObject)
    }
    
    // MARK: - Map View Delegate
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        if mainFavors.count != 0 {
            NSOperationQueue().addOperationWithBlock({
                let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
                let scale:Double = mapBoundsWidth / mapRectWidth
                let annotationArray = self.clusteringManager!.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
                self.clusteringManager!.displayAnnotations(annotationArray, onMapView:self.mapView)
            })
        }
        
        if mapChangedByUserGesture {
            mapChangedByUserGesture = false
            edge = mapView.edgePoints()
            loadFavors(mapView.edgePoints())
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!)
    //----------------------------------------------------------------------------------------------------------
    {
        if !didLoadFavor {
            edge = mapView.edgePoints()
            loadFavors(mapView.edgePoints())
            didLoadFavor = true
        }
    }
    
    // MARK: - UIGesture Delegate
    //----------------------------------------------------------------------------------------------------------
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    //----------------------------------------------------------------------------------------------------------
    {
        return true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat
    //----------------------------------------------------------------------------------------------------------
    {
        return 1.0
    }

    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
    
    //----------------------------------------------------------------------------------------------------------
    func passUser() -> PFUser?
    //----------------------------------------------------------------------------------------------------------
    {
        return userToPass
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tabBarViewDidExpanded()
    //----------------------------------------------------------------------------------------------------------
    {
        let tabBarController = self.tabBarController as? YALFoldingTabBarController
        addBadge(tabBarController!, "123", "234", "345", "")
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tabBarViewWillCollapse()
    //----------------------------------------------------------------------------------------------------------
    {
        let tabBarController = self.tabBarController as? YALFoldingTabBarController
    }
    
    // MARK: - Navigations
    //----------------------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        if segue.identifier == "FavorView_To_FavorListTable" {
            var vc = segue.destinationViewController as! FavorListTable
        }
    }
    
    func expand() {
        if !canExpand { return }
        if displayerMode != 1 { return }
        changeDisplayMode(2)
    }
    
    func shrink() {
        if displayerMode == 1 {
            changeDisplayMode(0)
        } else if displayerMode == 2{
            canExpand = false
            changeDisplayMode(1)
        }
    }
}











