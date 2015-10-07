//
//  ChatnamesView.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var resultSearchController = UISearchController()
    var filteredNames = [String]()
    var users = [PFUser]()
    var sections = NSMutableArray()
    let collation = UILocalizedIndexedCollation.currentCollation() as! UILocalizedIndexedCollation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "People"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ChatPeopleCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleCell")
        tableView.registerNib(UINib(nibName: "ChatPeopleStaticCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleStaticCell")
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        self.loadPeople()   
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? YALFoldingTabBarController)!.tabBarView.hidden = true
    }
    
//    func filterContentForSearchText(searchText: String) {
//        self.filteredNames = self.names.filter({ (name: String) -> Bool in
//            return name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
//        })
//    }
    
    func loadPeople() {
        let query = PFQuery(className: Constants.People.Name)
        query.whereKey(Constants.People.User1, equalTo: PFUser.currentUser()!)
        query.includeKey(Constants.People.User2)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects as? [PFObject] {
                self.users.removeAll(keepCapacity: false)
                for people in objects {
                    let user = people[Constants.People.User2] as! PFUser
                    self.users.append(user)
                }
                self.setObjects(self.users)
                self.tableView.reloadData()
            }
        }
    }
    
    func loadUser() {
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let objects = objects as? [PFUser] {
                self.users.removeAll(keepCapacity: false)
                self.users = objects
                println("count of users \(self.users.count)")
                self.setObjects(self.users)
                self.tableView.reloadData()
            }
        })
    }
    
    func setObjects(objects: NSArray) {
        sections.removeAllObjects()
        let sectionTitleCount = self.collation.sectionTitles.count
        sections = NSMutableArray(capacity: sectionTitleCount)
        for index in 0...sectionTitleCount {
            sections.addObject(NSMutableArray())
        }
        let sorted = objects.sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in
            let user1 = obj1 as! PFUser
            let user2 = obj2 as! PFUser
            let name1 = user1[Constants.User.Nickname] as! String
            let name2 = user2[Constants.User.Nickname] as! String
            return name1.compare(name2)
        }
        for object in sorted as! [PFUser] {
            let section = self.collation.sectionForObject(object, collationStringSelector: "fullname")
            sections[section].addObject(object)
        }
    }
    
    func fullname() -> String{
        return "name"
    }
    
    // MARK: - TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.resultSearchController.active {
            return 1
        } else {
            return self.sections.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filteredNames.count
        } else {
            if section == 0 {
                return 2
            } else {
                return self.sections[section].count
            }
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            if self.sections[section].count != 0 {
                return self.collation.sectionTitles[section] as? String
            }
            return ""
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject] {
        return self.collation.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.collation.sectionForSectionIndexTitleAtIndex(index)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.resultSearchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleCell", forIndexPath: indexPath) as! ChatPeopleCell
            cell.userName.text = filteredNames[indexPath.row]
            return cell
        } else {
            if indexPath.section == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleStaticCell") as! ChatPeopleStaticCell!
                switch indexPath.row {
                case 0:
                    cell.detailLabel.text = "Add New Friend"
                    cell.badgeLabel.text = ""
                case 1:
                    cell.detailLabel.text = "Friend Requests"
                default:
                    break
                }
                return cell
            }

            var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleCell") as! ChatPeopleCell!
            let userstemp = sections[indexPath.section] as! NSMutableArray
            let user = userstemp[indexPath.row] as? PFUser
            cell.bindData(user)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("AddFriend", sender: self)
            case 1:
                performSegueWithIdentifier("FriendRequests", sender: self)
            default:
                break
            }
        } else {
            let profileView = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileOthers") as! ProfileOthersView
            let userstemp = sections[indexPath.section] as! NSMutableArray
            let user = userstemp[indexPath.row] as? PFUser
            profileView.user = user
            self.navigationController?.pushViewController(profileView, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Search Control Delegates
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
//        filteredNames.removeAll(keepCapacity: false)
//        filterContentForSearchText(searchController.searchBar.text)
//        self.tableView.reloadData()
    }

}
