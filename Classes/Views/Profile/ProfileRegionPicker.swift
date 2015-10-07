//
//  ProfileRegionPicker.swift
//  Whistle
//
//  Created by Yetian Mao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ProfileRegionPicker: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var currentCity: String?
    private var popularCities: NSMutableArray = NSMutableArray()
    
    //----------------------------------------------------------------------------------------------------------
    private let googleAPIKey = "AIzaSyBUdG-LWODBF8OiWvhRy8t0b2KGF69jjpE"
    private let placeAutoCompleteURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    private var results : JSON?
    private var searching: Bool = false
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    private let autoCompleteTextColor = UIColor.blackColor()
    private var autoCompleteAttributes : [String:AnyObject]?
    //----------------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        autoCompleteAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        autoCompleteAttributes![NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 15)
        fetchData()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func reverseGeocode(lat : Double, lng : Double) {
    //----------------------------------------------------------------------------------------------------------
        LocationManager.sharedInstance.reverseGeocodeLocationUsingGoogleWithLatLon(latitude: lat, longitude: lng) {
            (reverseGecodeInfo, placemark, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.currentCity = reverseGecodeInfo!.valueForKey("locality") as? String
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchData() {
        println("2")
        let query = PFQuery(className: Constants.Region.Name)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects {
                println("3")
                self.popularCities.removeAllObjects()
                self.popularCities.addObjectsFromArray(objects)
                println("city count \(objects.count)")
                self.reverseGeocode(currentLocation!.latitude, lng: currentLocation!.longitude)
            } else {
                println("network error")
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func fetchData(searchText : String) {
    //----------------------------------------------------------------------------------------------------------
        var request = HTTPTask()
        var dic = ["input": searchText, "types": "(regions)", "key": googleAPIKey]
        
        if count(searchText) > 0 {
            request.GET(placeAutoCompleteURL, parameters: dic) { (response) -> Void in
                if let err = response.error {
                    println("error : \(err.localizedDescription)")
                }
                if let data = response.responseObject as? NSData {
                    let json = JSON(data: data)
                    //println(json)
                    self.results = json["predictions"]
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    // MARK: - LocationSearchView (UITableViewDataSource / UITableViewDelegate)
    //----------------------------------------------------------------------------------------------------------
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //----------------------------------------------------------------------------------------------------------
        if searching {
            return 1
        } else {
            return 2
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //----------------------------------------------------------------------------------------------------------
        if searching {
            if let results = results {
                println(results.count)
                return results.count
            } else {
                return 0
            }
        } else {
            if section == 0 {
                return 1
            } else {
                return popularCities.count
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching {
            return nil
        }
        if section == 0 {
            return "Current Location"
        } else {
            return "Popular Cities"
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //----------------------------------------------------------------------------------------------------------
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if searching {
            if let results = results {
                let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFontOfSize(15.0)]
                let autoCompleteString = results[indexPath.row]["description"].string
                let str = NSString(string: autoCompleteString!)
                let range = str.rangeOfString(self.searchBar.text, options: .CaseInsensitiveSearch)
                var attString = NSMutableAttributedString(string: autoCompleteString!, attributes: attrs)
                attString.addAttributes(autoCompleteAttributes!, range: range)
                cell.textLabel?.attributedText = attString
            }
        } else {
            if indexPath.section == 0 {
                cell.textLabel?.text = currentCity
                return cell
            } else {
                if let city = popularCities[indexPath.row] as? PFObject {
                    cell.textLabel?.text = city[Constants.Region.City] as? String
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var region = ""
        if searching {
            if let results = results {
                region = results[indexPath.row]["description"].string!
            }
        } else {
            if indexPath.section == 0 {
                region = currentCity!
            } else {
                if let city = popularCities[indexPath.row] as? PFObject {
                    region = city[Constants.Region.City] as! String
                }
            }
        }
        if let user = PFUser.currentUser() {
            user[Constants.User.Region] = region
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    // MARK: - LocationSearchView (UISearchBarDelegate)
    //----------------------------------------------------------------------------------------------------------
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    //----------------------------------------------------------------------------------------------------------
        if (searchText == "") {
            searching = false
            self.tableView.reloadData()
        } else {
            searching = true
            fetchData(searchText)
        }
    }
    
}
