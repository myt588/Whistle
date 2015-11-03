//
//  FavorDetailView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/29/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import MapKit
import AVFoundation
import Foundation
import Parse
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class FavorDetailView: UIViewController, MKMapViewDelegate, YALTabBarInteracting, UIGestureRecognizerDelegate, FavorDetailScrollDelegate
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Map
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var mapView                              : MKMapView!
    //----------------------------------------------------------------------------------------------------------
    // Table
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var detailView                           : UIView!
    //----------------------------------------------------------------------------------------------------------
    // Portrait
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portraitView                         : UIView!
    @IBOutlet weak var portraitImageView                    : WEProfileView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var bannerView                           : UIView!
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    @IBOutlet weak var bannerRightView                      : UIView!
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
    private var tableView                                   : FavorDetailTable?
    //----------------------------------------------------------------------------------------------------------
    private var displayerMode                               : Int = 0   // 0: all map; 1: Splitted; 2: all table
    private var mapViewOriginalFrame                        : CGRect?
    private var detailViewOriginalFrame                     : CGRect?
    private var portraitViewOriginalFrame                   : CGRect?
    //----------------------------------------------------------------------------------------------------------
    private var isAnimatingDisplay                          = true
    private var didLayoutSubviews                           = false
    //----------------------------------------------------------------------------------------------------------
    private var canExpand                                   = true
    
    var favor: PFObject!
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        configContainerView()
        configMapView()
        addGestures()
        addAnnotations()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actionCleanup", name: NOTIFICATION_USER_LOGGED_OUT, object: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(animated)
        self.view.backgroundColor = Constants.Color.Background
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() != nil
        {
            tableView!.bindData(favor)
            changeDisplayMode(1)
        } else {
            var viewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
            self.presentViewController(viewController, animated: true, completion: nil)
        }
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
    
    func actionCleanup()
    {

    }

    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        var swipeUp                 = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeUp.direction           = UISwipeGestureRecognizerDirection.Up
        portraitImageView.addGestureRecognizer(swipeUp)
        
        var swipeDown               = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeDown.direction         = UISwipeGestureRecognizerDirection.Down
        portraitImageView.addGestureRecognizer(swipeDown)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func respondToGestures(gesture: UIGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                if displayerMode != 2 { println("by gesture up"); changeDisplayMode(2) }
            case UISwipeGestureRecognizerDirection.Down:
                println("by gesture down")
                displayerMode == 2 ? changeDisplayMode(1) : changeDisplayMode(0)
            default:
                break
            }
        }
    }
    

    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        view.backgroundColor                                        = Constants.Color.Background
        portraitView.backgroundColor                                = UIColor.clearColor()
        self.title = "Detail"
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configShapes()
    //----------------------------------------------------------------------------------------------------------
    {
        nameLabel.shadowOffset                                      = CGSizeMake(0, -1)
        nameLabel.layer.cornerRadius                                = 8
        bannerView.backgroundColor                                  = Constants.Color.Banner
        bannerView.roundCorners(.TopRight | .BottomRight, radius: 8)
        bannerRightView.roundCorners(.TopRight | .BottomRight, radius: 8)
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
    }
    
    //----------------------------------------------------------------------------------------------------------
    func centerMapOnUser()
    //----------------------------------------------------------------------------------------------------------
    {
        let location1                                               = CurrentLocation()
        let location: CLLocationCoordinate2D                        = CLLocationCoordinate2D(latitude: location1.latitude, longitude: location1.longitude)
        let regionRadius: CLLocationDistance                        = 200
        let coordinateRegion                                        = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func centerMapOnFavor()
    //----------------------------------------------------------------------------------------------------------
    {
        let PFlocation                                              = favor[Constants.Favor.Location] as! PFGeoPoint
        let location: CLLocationCoordinate2D                        = CLLocationCoordinate2DMake(PFlocation.latitude, PFlocation.longitude)
        let regionRadius: CLLocationDistance                        = 100
        let coordinateRegion                                        = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addAnnotations()
    //----------------------------------------------------------------------------------------------------------
    {
        let PFLocation = favor[Constants.Favor.Location] as! PFGeoPoint
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: PFLocation.latitude, longitude: PFLocation.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        println(mapView.annotations.count)
    }
    
    // BannerView
    //----------------------------------------------------------------------------------------------------------
    func configBanner(favor: PFObject?) {
    //----------------------------------------------------------------------------------------------------------
        if let favor = favor {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser
            {
                portraitImageView.loadImage(user)
                nameLabel.text = user[Constants.User.Nickname] as? String
            }
            
            if let audio = favor[Constants.Favor.Audio] as? PFFile
            {
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
        configBanner(favor)
        centerMapOnFavor()
    }
    
    //----------------------------------------------------------------------------------------------------------
    // MARK: - Map View Delegate
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    //----------------------------------------------------------------------------------------------------------
    {
        var reuseId = ""
        if annotation is MKPointAnnotation {
            reuseId = "Pin"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? WEAnnotationView
            annotationView = WEAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            if let annotationView = annotationView {
                annotationView.canShowCallout = false
                let user = favor[Constants.Favor.CreatedBy] as! PFUser
                annotationView.user = user
                annotationView.setImageView()
            }
            return annotationView
        }
        return nil
    }
    
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!)
    //----------------------------------------------------------------------------------------------------------
    {
        mapView.deselectAnnotation(view.annotation, animated: true)
        changeDisplayMode(1)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!)
    {
        userLocation.title = ""
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












