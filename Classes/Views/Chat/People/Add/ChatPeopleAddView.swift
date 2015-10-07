//
//  ChatPeopleAddView.swift
//  Whistle
//
//  Created by Lu Cao on 8/18/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ChatPeopleAddView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleStaticCell") as! ChatPeopleStaticCell!
        if cell == nil {
            tableView.registerNib(UINib(nibName: "ChatPeopleStaticCell", bundle: nil), forCellReuseIdentifier: "ChatPeopleStaticCell")
            cell = tableView.dequeueReusableCellWithIdentifier("ChatPeopleStaticCell") as! ChatPeopleStaticCell!
        }
        switch indexPath.row {
        case 0:
            cell.detailLabel.text = "Search Friend"
            cell.badgeLabel.text = ""
        case 1:
            cell.detailLabel.text = "Add From Facebook"
            cell.badgeLabel.text = ""
        case 2:
            cell.detailLabel.text = "Add From Phone Book"
            cell.badgeLabel.text = ""
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("SearchFriend", sender: self)
        case 2:
            performSegueWithIdentifier("AddFromPhone", sender: self)
        default:
            break
        }
    }
}
