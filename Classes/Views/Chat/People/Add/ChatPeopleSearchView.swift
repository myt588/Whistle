//
//  ChatnamesView.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleSearchView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var resultSearchController = UISearchController()
    
    var users = [PFUser]()
    
    var selectedIndex : Int?
    
    var showSearchResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ChatPeopleCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleCell")
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            self.tableView.tableHeaderView = controller.searchBar
            controller.searchBar.delegate = self
            controller.searchBar.placeholder = "Search with username / phone / email"
            return controller
        })()
        
        self.tableView.reloadData()
    }

    
    override func viewWillAppear(animated: Bool) {
        if let tabBar = tabBarController as? YALFoldingTabBarController {
            tabBar.tabBarView.hidden = true
        }
        tableView.tableHeaderView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //resultSearchController.active = false
    }
    
    func searchUser(search_lower: String) {
        let user = PFUser.currentUser()
        let query1 = PFQuery(className: PF_BLOCKED_CLASS_NAME)
        query1.whereKey(PF_BLOCKED_USER1, equalTo: user!)
        
        let query2 = PFQuery(className: PF_USER_CLASS_NAME)
        query2.whereKey(PF_USER_OBJECTID, notEqualTo: user!.objectId!)
        query2.whereKey(PF_USER_OBJECTID, doesNotMatchKey: PF_BLOCKED_USERID2, inQuery: query1)
        query2.whereKey(PF_USER_FULLNAME_LOWER, containsString: search_lower)
        query2.limit = 1000
        query2.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects as? [PFUser]{
                self.users.removeAll(keepCapacity: false)
                self.users = objects
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network Error")
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.resultSearchController.active && showSearchResult {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active && showSearchResult {
            return users.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleCell") as! ChatPeopleCell!
        if self.resultSearchController.active && showSearchResult {
            cell.bindData(users[indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        resultSearchController.active = false
        selectedIndex = indexPath.row
        performSegueWithIdentifier("SendFriendRequest", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Search Control Delegates
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text == "" {
            ProgressHUD.showError("Need to enter something")
            return
        }
        searchUser(searchBar.text)
        showSearchResult = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        showSearchResult = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SendFriendRequest" {
            let vc = segue.destinationViewController as! ChatPeopleSendRequestView
            vc.user = users[selectedIndex!]
        }
    }
    
    
    
    
}
