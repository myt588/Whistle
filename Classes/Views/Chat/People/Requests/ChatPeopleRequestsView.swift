//
//  ChatnamesView.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleRequestsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [PFObject]()
    var selectedIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Requests"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "ChatPeopleCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleCell")
        loadRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tabBar = tabBarController as? YALFoldingTabBarController {
            tabBar.tabBarView.hidden = true
        }
    }
    
    func loadRequest() {
        let query = PFQuery(className: Constants.UserRequestPivotTable.Name)
        query.whereKey(Constants.UserRequestPivotTable.To, equalTo: PFUser.currentUser()!)
        query.whereKey(Constants.UserRequestPivotTable.Status, notContainedIn: [1, 2])
        query.includeKey(Constants.UserRequestPivotTable.From)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                self.requests.removeAll(keepCapacity: true)
                self.requests = objects
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView Delegates
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleCell") as! ChatPeopleCell!
        var request = requests[indexPath.row]
        cell.bindData(request[Constants.UserRequestPivotTable.From] as? PFUser)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegueWithIdentifier("ViewRequest", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewRequest" {
            let vc = segue.destinationViewController as! ChatPeopleViewRequestView
            vc.request = requests[selectedIndex!]
        }
    }
    
}
