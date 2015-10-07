//
//  FavorListView.swift
//  Whistle
//
//  Created by Lu Cao on 8/11/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class FavorListView: UIViewController, MXPullDownMenuDelegate
{
    private var tableView               : FavorListTable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var menuList = [
            ["All Gender", "Females Only", "Males Only"],
            ["Most Recent", "Price High to Low", "Distance Near to Far"],
            ["Default Range", "Range 2 mile", "Range 5 miles", "Range 10 miles", "Range 25 miles", "Range 50 miles"]
        ]
        var menu = MXPullDownMenu(array: menuList, selectedColor: Constants.Color.TableBackground)
        menu.frame = CGRectMake(0, 0, menu.frame.width, menu.frame.height)
        menu.delegate = self
        menu.alpha = 0.85
        view.addSubview(menu)
        tableView = childViewControllers.first as? FavorListTable
        
        TSMessage.setDefaultViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.translucent         = false
    }

    @IBAction func leftNavItemTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func PullDownMenu(pullDownMenu: MXPullDownMenu!, didSelectRowAtColumn column: Int, row: Int) {
        if column == 0 {
            switch row {
            case 0:
                gender = nil
            case 1:
                gender = 0
            case 2:
                gender = 1
            default:
                break
            }
            tableView?.loadFavors()
        }
        if column == 1 {
            switch row {
            case 0:
                sortBy = 0
                mainFavors.sortByCreatedAt(.Ascending)
                tableView!.tableView.reloadData()
            case 1:
                mainFavors.sortByPrice(.Ascending)
                tableView!.tableView.reloadData()
                sortBy = 1
            case 2:
                mainFavors.sortByDistance(.Ascending)
                tableView!.tableView.reloadData()
                sortBy = 2
            default:
                break
            }
        }
        if column == 2 {
            switch row {
            case 0:
                distance = Constants.Favor.DefaultMileRange
            case 1:
                distance = 2
            case 2:
                distance = 5
            case 3:
                distance = 10
            case 4:
                distance = 25
            default:
                break
            }
            tableView?.loadFavors()
        }
        
    }

}
