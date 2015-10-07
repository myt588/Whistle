//
//  ProfileSettingTable.swift
//  Whistle
//
//  Created by Yetian Mao on 8/12/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileSettingTable: UITableViewController
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    // Profile Edit
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portrait                         : UIImageView!
    @IBOutlet weak var id                               : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Account
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var phoneKeyLabel                    : UILabel!
    @IBOutlet weak var emailKeyLabel                    : UILabel!
    @IBOutlet weak var facebookKeyLabel                 : UILabel!
    @IBOutlet weak var twitterKeyLabel                  : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Privacy
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var friendConfSwitch                 : UISwitch!
    @IBOutlet weak var publicSwitch                     : UISwitch!
    //----------------------------------------------------------------------------------------------------------
    // Notification
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var whistleNofitySwitch              : UISwitch!
    @IBOutlet weak var chatNotifySwitch                 : UISwitch!
    //----------------------------------------------------------------------------------------------------------
    // Logout
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var logoutButton                     : UIButton!
    //----------------------------------------------------------------------------------------------------------
    private var user                                    : PFUser!
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let user = PFUser.currentUser() {
            self.user = user
            self.title = "Settings"
            bindData()
        } else {
            
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning()
    //----------------------------------------------------------------------------------------------------------
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    // Navigation Bar Button
    //----------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    @IBAction func logoutButtonTapped(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        println("dd")
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                println("log out failed, \(error)")
            } else {
                mainFavors.removeAllObjects()
                edge = nil
                mainIndex = 0
                // filter
                gender = nil
                distance = nil
                sortBy = nil
                currentLocation = nil
                LoginView()
            }
        }
    }
    
    func setEmail(email: String) {
        self.user[Constants.User.Email] = email
        self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                if error.code == 125 {
                    
                }
            } else {
                self.emailKeyLabel.text = email
            }
        })
    }
    
    //----------------------------------------------------------------------------------------------------------
    // END: - Edit Button
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        portrait.layer.borderColor                      = Constants.Color.Border.CGColor
        portrait.layer.borderWidth                      = 2
        portrait.layer.cornerRadius                     = 30
        portrait.backgroundColor                        = Constants.Color.Border
        
        logoutButton.setTitleColor(Constants.Color.CellText, forState: .Normal)
        logoutButton.layer.backgroundColor              = Constants.Color.ContentBackground.CGColor
        logoutButton.layer.cornerRadius                 = 15
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData()
    //----------------------------------------------------------------------------------------------------------
    {
        if let file = user[Constants.User.Portrait] as? PFFile {
            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data {
                    self.portrait.image = UIImage(data: data)!
                }
            })
        }
        
        if let id = user[Constants.User.Id] as? String {
            self.id.text = "Whistle ID: \(id)"
        }
        
        self.phoneKeyLabel.text = user[Constants.User.Phone] as? String
        self.emailKeyLabel.text = user[Constants.User.Email] as? String
        
        if PFFacebookUtils.isLinkedWithUser(user!) {
            self.facebookKeyLabel.text = "linked"
        } else {
            self.facebookKeyLabel.text = "not linked"
        }
        if PFTwitterUtils.isLinkedWithUser(user!) {
            self.twitterKeyLabel.text = "linked"
        } else {
            self.twitterKeyLabel.text = "not linked"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            var vc : ProfileEditSingleView = storyboard?.instantiateViewControllerWithIdentifier("EditSingleSetting") as! ProfileEditSingleView
            vc.type = "Email"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 6 {
            if self.facebookKeyLabel.text == "linked" {
                return
            }
            let permissions = ["public_profile", "user_friends", "email", "user_photos"]
            PFFacebookUtils.linkUserInBackground(self.user, withReadPermissions: permissions, block: { (success, error) -> Void in
                if success {
                    self.facebookKeyLabel.text = "linked"
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
        if indexPath.row == 7 {
            if self.twitterKeyLabel.text == "linked" {
                return
            }
            PFTwitterUtils.linkUser(self.user!, block: { (success, error) -> Void in
                if success {
                    self.twitterKeyLabel.text = "linked"
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }

    
}
