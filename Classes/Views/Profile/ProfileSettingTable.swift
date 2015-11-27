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
    @IBOutlet weak var portrait                         : WEProfileView!
    @IBOutlet weak var nameLabel                        : WEFontContent!
    //----------------------------------------------------------------------------------------------------------
    // Account
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var phoneKeyLabel                    : UILabel!
    @IBOutlet weak var emailKeyLabel                    : UILabel!
    @IBOutlet weak var facebookKeyLabel                 : UILabel!
    @IBOutlet weak var twitterKeyLabel                  : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Notification
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var whistleNofitySwitch              : UISwitch!
    @IBOutlet weak var chatNotifySwitch                 : UISwitch!
    //----------------------------------------------------------------------------------------------------------
    private var user                                    : PFUser!
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        whistleNofitySwitch.addTarget(self, action: "whistleNotifySwitch:", forControlEvents: UIControlEvents.ValueChanged)
        chatNotifySwitch.addTarget(self, action: "chatNotifySwitch:", forControlEvents: UIControlEvents.ValueChanged)
        let installation = PFInstallation.currentInstallation()
        UserDefault.saveBool(PF_DEFAULT_CHAT_SWITCH, value: installation["chat"] as! Bool)
        UserDefault.saveBool(PF_DEFAULT_WHISTLE_SWITCH, value: installation["whistle"] as! Bool)
        chatNotifySwitch.setOn(UserDefault.getBool(PF_DEFAULT_CHAT_SWITCH), animated: false)
        whistleNofitySwitch.setOn(UserDefault.getBool(PF_DEFAULT_WHISTLE_SWITCH), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let user = PFUser.currentUser() {
            self.user = user
            self.title = "Settings"
            (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = true
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
    
    func setEmail(email: String) {
        self.user[Constants.User.Email] = email
        self.user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                ParseErrorHandler.handleParseError(error)
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
        var switches = [whistleNofitySwitch, chatNotifySwitch]
        for element in switches {
            element.onTintColor = Constants.Color.Main2
            element.tintColor = UIColor.whiteColor()
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData()
    //----------------------------------------------------------------------------------------------------------
    {
        self.portrait.loadImage(user)
        self.portrait.useDefault = true
        self.portrait.canTap = false
        self.nameLabel.text = user[Constants.User.Nickname] as? String
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
    
    func whistleNotifySwitch(switchState: UISwitch) {
        let installation = PFInstallation.currentInstallation()
        installation["whistle"] = switchState.on ? true : false
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                UserDefault.saveBool(PF_DEFAULT_WHISTLE_SWITCH, value: switchState.on)
                println("changed whistle state")
            } else {
                ParseErrorHandler.handleParseError(error)
            }
        }
    }
    
    func chatNotifySwitch(switchState: UISwitch) {
        let installation = PFInstallation.currentInstallation()
        installation["chat"] = switchState.on ? true : false
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                UserDefault.saveBool(PF_DEFAULT_CHAT_SWITCH, value: switchState.on)
                println("changed chat state")
            } else {
                ParseErrorHandler.handleParseError(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            var vc : ProfileEditSingleView = storyboard?.instantiateViewControllerWithIdentifier("EditSingleSetting") as! ProfileEditSingleView
            vc.type = "Email"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 4 {
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
        if indexPath.row == 5 {
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
        if indexPath.row == 6 {
            let blockedView = BlockedView()
            self.navigationController?.pushViewController(blockedView, animated: true)
        }
        if indexPath.row == 16 {
            let webView = ProfileWebView()
            self.navigationController?.pushViewController(webView, animated: true)
        }
        if indexPath.row == 17 {
            let alert = WEAlertController(title: "Logout", message: "Confirm Logout Action", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Cancel", style: .Cancel))
            alert.addAction(SimpleAlert.Action(title: "Log out", style: .OK) { action in
                PFUser.logOutInBackgroundWithBlock { (error) -> Void in
                    if let error = error {
                        println("log out failed, \(error)")
                    } else {
                        PostNotification(NOTIFICATION_USER_LOGGED_OUT)
                        var viewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                }
            })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    
}
