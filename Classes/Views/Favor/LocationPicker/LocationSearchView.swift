//
//  LocationSearchView.swift
//  Whistle
//
//  Created by Yetian Mao on 7/5/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import MapKit

//---------------------------------------------------------------------------------------------------------------------------------------------------
class LocationSearchView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
//---------------------------------------------------------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    //----------------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------------
    private let googleAPIKey = "AIzaSyBUdG-LWODBF8OiWvhRy8t0b2KGF69jjpE"
    private let placeAutoCompleteURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    private var results : JSON?
    private var selectedIndex : Int?
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    private let autoCompleteTextColor = UIColor.blackColor()
    private var autoCompleteAttributes : [String:AnyObject]?
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    //----------------------------------------------------------------------------------------------------------
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //----------------------------------------------------------------------------------------------------------
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        //----------------------------------------------------------------------------------------------------------
        
        autoCompleteAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        autoCompleteAttributes![NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 15)
        
        searchBar.becomeFirstResponder()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    //----------------------------------------------------------------------------------------------------------
    func fetchData(searchText : String) {
    //----------------------------------------------------------------------------------------------------------
        var request = HTTPTask()
        var dic = ["input": searchText, "types": "address", "key": googleAPIKey]
        
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
    
    //----------------------------------------------------------------------------------------------------------
    func keyboardWasShown(notification: NSNotification) {
    //----------------------------------------------------------------------------------------------------------
        if isViewLoaded() && view.window != nil {
            let info: Dictionary = notification.userInfo!
            let keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size)!
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            
            tableView.contentInset = contentInsets;
            tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func keyboardWillBeHidden(notification: NSNotification) {
    //----------------------------------------------------------------------------------------------------------
        if isViewLoaded() && view.window != nil {
            self.tableView.contentInset = UIEdgeInsetsZero
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
    }
    
    // MARK: - LocationSearchView (UITableViewDataSource / UITableViewDelegate)
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
            return results.count
        } else {
            return 0
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //----------------------------------------------------------------------------------------------------------
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if let results = results {
            let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFontOfSize(15.0)]
            let autoCompleteString = results[indexPath.row]["description"].string
            let str = NSString(string: autoCompleteString!)
            let range = str.rangeOfString(self.searchBar.text, options: .CaseInsensitiveSearch)
            var attString = NSMutableAttributedString(string: autoCompleteString!, attributes: attrs)
            attString.addAttributes(autoCompleteAttributes!, range: range)
            cell.textLabel?.attributedText = attString
        }
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //----------------------------------------------------------------------------------------------------------
        if let results = results {
            let name = results[indexPath.row]["description"].string
            LocationManager.sharedInstance.geocodeUsingGoogleAddressString(address: name!, onGeocodingCompletionHandler: { (gecodeInfo, placemark, error) -> Void in
                if error == nil {
                    let lat = (gecodeInfo!.objectForKey("latitude") as! NSString).doubleValue
                    let lng = (gecodeInfo!.objectForKey("longitude") as! NSString).doubleValue
                    dispatch_async(dispatch_get_main_queue()) {
                        let locationPicked = Location(latitude: lat, longtitude: lng, formattedAddress: name!)
                        NSNotificationCenter.defaultCenter().postNotificationName("userSearched", object: locationPicked)
                    }
                }
            })
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - LocationSearchView (UISearchBarDelegate)
    //----------------------------------------------------------------------------------------------------------
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    //----------------------------------------------------------------------------------------------------------
        if (searchText == "") {
            tableView.hidden = true
        } else {
            fetchData(searchText)
        }
    }

}










