//
//  ProfileChangeStatusTable.swift
//  Whistle
//
//  Created by Lu Cao on 6/29/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class ProfileChangeStatusTable: UITableViewController, UITextViewDelegate
//----------------------------------------------------------------------------------------------------------
{

    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var statusTextView                       : UITextView!
    @IBOutlet weak var wordCount                            : UILabel!
    @IBOutlet weak var greetingLabel                        : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configBarButton()
        configLooks()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(true)
        statusTextView.becomeFirstResponder()
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = false
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configBarButton()
    //----------------------------------------------------------------------------------------------------------
    {
        var button = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action:"submit")
        self.navigationItem.rightBarButtonItem              = button
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        statusTextView.delegate                             = self
    }
    
    //----------------------------------------------------------------------------------------------------------
    func submit()
    //----------------------------------------------------------------------------------------------------------
    {
        if let user = PFUser.currentUser() {
            user[Constants.User.Status] = statusTextView.text
            user.saveEventually({ (success, error) -> Void in
                if success {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    println("network error")
                }
            })
        }
    }

    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return 1
    }

    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return 1
    }
    
    //----------------------------------------------------------------------------------------------------------
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    //----------------------------------------------------------------------------------------------------------
    {
        let num: Int = count(textView.text)
        if num - range.length + count(text) > Constants.Limit.Status {
            return false
        } else {
            wordCount.text = "\(num - range.length + count(text))/\(Constants.Limit.Status)"
            return true
        }
    }

}
