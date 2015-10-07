//
//  ChatnamesView.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ChatPeopleAddFromPhoneView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var resultSearchController = UISearchController()
    
    var filteredNames = [String]()
    
    class User: NSObject {
        let name: String
        var section: Int?
        
        init(name: String) {
            self.name = name
        }
    }
    
    class Section {
        var users: [User] = []
        
        func addUser(user: User) {
            self.users.append(user)
        }
    }
    
    let names = [
        "Clementine",
        "Bessie",
        "Yolande",
        "Tynisha",
        "Ellyn",
        "Trudy",
        "Fredrick",
        "Letisha",
        "Ariel",
        "Bong",
        "Jacinto",
        "Dorinda",
        "Aiko",
        "Loma",
        "Augustina",
        "Margarita",
        "Jesenia",
        "Kellee",
        "Annis",
        "Charlena"
    ]
    
    // `UIKit` convenience class for sectioning a table
    let collation = UILocalizedIndexedCollation.currentCollation()
        as! UILocalizedIndexedCollation
    
    // table sections
    var sections: [Section] {
        // return if already initialized
        if self._sections != nil {
            return self._sections!
        }
        
        // create users from the name list
        var users: [User] = names.map { name in
            var user = User(name: name)
            user.section = self.collation.sectionForObject(user, collationStringSelector: "name")
            return user
        }
        
        // create empty sections
        var sections = [Section]()
        for i in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        // put each user in a section
        for user in users {
            sections[user.section!].addUser(user)
        }
        
        // sort each section
        for section in sections {
            section.users = self.collation.sortedArrayFromArray(section.users, collationStringSelector: "name") as! [User]
        }
        
        self._sections = sections
        
        return self._sections!
        
    }
    var _sections: [Section]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add From Phone"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let tabBar = tabBarController as? YALFoldingTabBarController {
            tabBar.tabBarView.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resultSearchController.active = false
    }
    
    func filterContentForSearchText(searchText: String) {
        self.filteredNames = self.names.filter({ (name: String) -> Bool in
            return name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
    
    // MARK: - TableView Delegates
    
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
            return self.sections[section].users.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleAddCell") as! ChatPeopleAddCell!
        if cell == nil {
            tableView.registerNib(UINib(nibName: "ChatPeopleAddCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleAddCell")
            cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleAddCell") as! ChatPeopleAddCell!
        }
        
        if self.resultSearchController.active {
            cell.username.text = filteredNames[indexPath.row]
            return cell
        } else {
            let user = self.sections[indexPath.section].users[indexPath.row]
            cell.username.text = user.name
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        resultSearchController.active = false
        performSegueWithIdentifier("AddFromPhoneRequest", sender: self)
    }
    
    
    // MARK: - Indexing
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sections[section].users.isEmpty {
            return self.collation.sectionTitles[section] as? String
        }
        return ""
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject] {
        return self.collation.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int)
        -> Int {
            return self.collation.sectionForSectionIndexTitleAtIndex(index-1)
    }
    
    // MARK: - Search Control Delegates
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filteredNames.removeAll(keepCapacity: false)
        filterContentForSearchText(searchController.searchBar.text)
        self.tableView.reloadData()
    }
    
}
