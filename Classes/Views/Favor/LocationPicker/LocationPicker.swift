//
//  LocationPicker.swift
//  Whistle
//
//  Created by Yetian Mao on 7/5/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import MapKit

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
class LocationPicker : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    var results : JSON?

    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightcons: NSLayoutConstraint!
    @IBOutlet weak var topcons: NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    private let googleAPIKey = "AIzaSyBUdG-LWODBF8OiWvhRy8t0b2KGF69jjpE"
    private let placeAutoCompleteURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    private let placeSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    private var latitude: Double?
    private var longitude: Double?
    private var formattedAddress: String?
    private var annotation                                          = MKPointAnnotation()
    private var mapChangedByUserGesture                             = false
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
    //----------------------------------------------------------------------------------------------------------
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userSearched:", name: "userSearched", object: nil)
        addGestures()
        centerMapOnUser()
    }
    
    // MARK: - NSNotification Passing Data
    //----------------------------------------------------------------------------------------------------------
    func userSearched(notification : NSNotification) {
    //----------------------------------------------------------------------------------------------------------
        if notification.name == "userSearched" {
            let location = notification.object as! Location
            self.latitude = location.latitude
            self.longitude = location.longtitude
            self.formattedAddress = location.formattedAddress
            addAnnotationAndCenterMap(latitude!, lng: longitude!, text: formattedAddress!)
        }
    }
    
    // MARK: - Fetch Data From Google Service
    //----------------------------------------------------------------------------------------------------------
    func fetchData(location : CLLocationCoordinate2D) {
    //----------------------------------------------------------------------------------------------------------
        var request = HTTPTask()
        //println("1")
        var dic = ["location": "\(location.latitude), \(location.longitude)", "radius": "500", "key": googleAPIKey]
        request.GET(placeSearchURL, parameters: dic) { (response) -> Void in
            if let err = response.error {
                println("error : \(err.localizedDescription)")
            }
            if let data = response.responseObject as? NSData {
                let json = JSON(data: data)
                //println(json)
                self.results = json["results"]
                //println(self.results)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - IBAction
    //----------------------------------------------------------------------------------------------------------
    @IBAction func toSearch(sender: UIBarButtonItem) {
    //----------------------------------------------------------------------------------------------------------
        performSegueWithIdentifier("locationToSearch", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    @IBAction func dismissSelf(sender: UIBarButtonItem) {
    //----------------------------------------------------------------------------------------------------------
        if let latitude = self.latitude {
            let locationPicked = Location(latitude: latitude, longtitude: longitude!, formattedAddress: formattedAddress!)
            NSNotificationCenter.defaultCenter().postNotificationName("locationPicked", object: locationPicked)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            println("need to pick location")
            return
        }
    }
    
    // MARK: - User interactions
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        var swipeRight              = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeRight.direction        = UISwipeGestureRecognizerDirection.Right
        //tableView.addGestureRecognizer(swipeRight)
        
        var swipeLeft               = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeLeft.direction         = UISwipeGestureRecognizerDirection.Left
        //tableView.addGestureRecognizer(swipeLeft)
        
        var swipeUp                 = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeUp.direction           = UISwipeGestureRecognizerDirection.Up
        //tableView.addGestureRecognizer(swipeUp)
        
        var swipeDown               = UISwipeGestureRecognizer(target: self, action: "respondToGestures:")
        swipeDown.direction         = UISwipeGestureRecognizerDirection.Down
        //tableView.addGestureRecognizer(swipeDown)
        
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
                println("right")
            case UISwipeGestureRecognizerDirection.Left:
                println("left")
            case UISwipeGestureRecognizerDirection.Up:
                heightcons.active = false
                topcons.active = true
            case UISwipeGestureRecognizerDirection.Down:
                topcons.active = false
                heightcons.active = true
            default:
                break
            }
        }
        if let panGesture = gesture as? UIPanGestureRecognizer {
            mapChangedByUserGesture = true
            annotation.coordinate = mapView.centerCoordinate
        }
        if let pinchGesture = gesture as? UIPinchGestureRecognizer {
            mapChangedByUserGesture = true
            annotation.coordinate = mapView.centerCoordinate
        }
    }
    
    // MapView
    //----------------------------------------------------------------------------------------------------------
    func centerMapOnUser()
    //----------------------------------------------------------------------------------------------------------
    {
        let location = CurrentLocation()
        reverseGeocode(location.latitude, lng: location.longitude, text: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func centerMapOn(lat: Double, lng: Double) {
    //----------------------------------------------------------------------------------------------------------
        let location: CLLocationCoordinate2D                        = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let regionRadius: CLLocationDistance                        = 500
        let coordinateRegion                                        = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        fetchData(location)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func addAnnotationAndCenterMap(lat: Double, lng: Double, text: String) {
    //----------------------------------------------------------------------------------------------------------
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lng)
        annotation.title = "I'm at \(text)"
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        centerMapOn(lat, lng: lng)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func reverseGeocode(lat : Double, lng : Double, text: String?) {
    //----------------------------------------------------------------------------------------------------------
        LocationManager.sharedInstance.reverseGeocodeLocationUsingGoogleWithLatLon(latitude: lat, longitude: lng) {
            (reverseGecodeInfo, placemark, error) -> Void in
            if error == nil {
                //println(reverseGecodeInfo)
                //println(placemark)
                dispatch_async(dispatch_get_main_queue()) {
                    self.latitude = lat
                    self.longitude = lng
                    if let text = text {
                        let temp = text + ", "
                        self.formattedAddress = temp.stringByAppendingString(reverseGecodeInfo!.valueForKey("formattedAddress") as! String)
                        self.addAnnotationAndCenterMap(lat, lng: lng, text: text)
                    } else {
                        self.formattedAddress = reverseGecodeInfo!.valueForKey("formattedAddress") as? String
                        self.addAnnotationAndCenterMap(lat, lng: lng, text: reverseGecodeInfo!.valueForKey("formattedAddress") as! String)
                    }
                }
            }
        }
    }
    
    // MARK: - Table View Delegates & Data Source
    //----------------------------------------------------------------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //----------------------------------------------------------------------------------------------------------
        return 1
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //----------------------------------------------------------------------------------------------------------
        if let results = results {
            println(results.count)
            return results.count + 1
        }
        return 0
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //----------------------------------------------------------------------------------------------------------
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        if let results = results {
            if indexPath.row < results.count {
                let image = UIImage(named: results[indexPath.row]["types"][0].string!)
                if let image = image {
                    cell.imageV.image = image
                } else {
                    cell.imageV.image = UIImage(named: "others")
                }
                
                cell.name.text =  results[indexPath.row]["name"].string
                cell.address.text = results[indexPath.row]["vicinity"].string
                if indexPath.row == 0 {
                    cell.address.text = "Current Area"
                }
            } else {
                cell.name.text = "Search for location"
                cell.address.text = ""
                cell.imageV.image = nil
            }
        }
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //----------------------------------------------------------------------------------------------------------
        if let results = results {
            if indexPath.row < results.count {
                let lat = results[indexPath.row]["geometry"]["location"]["lat"].double
                let lng = results[indexPath.row]["geometry"]["location"]["lng"].double
                let name = results[indexPath.row]["name"].string
                println("called in tableView")
                reverseGeocode(lat!, lng: lng!, text: name)
                //addAnnotationAndCenterMap(lat!, lng: lng!, text: name!)
            } else {
                performSegueWithIdentifier("locationToSearch", sender: self)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Map View Delegate
    //----------------------------------------------------------------------------------------------------------
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
    //----------------------------------------------------------------------------------------------------------
        if mapChangedByUserGesture {
            println("called in mapView")
            reverseGeocode(mapView.centerCoordinate.latitude, lng: mapView.centerCoordinate.longitude, text: nil)
            mapChangedByUserGesture = false
        }
    }
    
    // MARK: - UIGesture Delegate
    //----------------------------------------------------------------------------------------------------------
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //----------------------------------------------------------------------------------------------------------
        return true
    }
    
}
