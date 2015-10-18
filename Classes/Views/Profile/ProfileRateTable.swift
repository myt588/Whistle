//
//  ProfileRateTable.swift
//  Whistle
//
//  Created by Lu Cao on 8/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileRateTable: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.translucent = false
        tableView.autoresizesSubviews = true
        tableView.estimatedRowHeight = 100
        
        title = "Ratings"
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileRateCell", forIndexPath: indexPath) as! ProfileRateCell

        return cell
    }

}
