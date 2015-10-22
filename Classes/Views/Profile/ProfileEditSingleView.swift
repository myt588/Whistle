//
//  ProfileEditSingleView.swift
//  Whistle
//
//  Created by Yetian Mao on 8/13/15.
//  Copyright (c) 2015 LoopCow. All rights reservded.
//

import UIKit
import Parse

class ProfileEditSingleView : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField             : UITextField!
    
    var type : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.becomeFirstResponder()
        configBarButton()
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
    func submit()
    //----------------------------------------------------------------------------------------------------------
    {
        if let user = PFUser.currentUser() {
            switch type
            {
            case "ID":
                if textField.text == "" {
                    ProgressHUD.showError("Invalid Id")
                    return
                }
                let query = PFUser.query()
                query?.whereKey(Constants.User.Id, equalTo: textField.text)
                query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    if let error = error {
                        ParseErrorHandler.handleParseError(error)
                        if error.code == 101 {
                            user[Constants.User.Id] = self.textField.text
                            self.save(user)
                        }
                    } else {
                        ProgressHUD.showError("This Id is already taken")
                    }
                })
            case "Name":
                if textField.text == "" {
                    ProgressHUD.showError("Invalid name")
                    return
                }
                user[Constants.User.Nickname] = textField.text
                user[Constants.User.NicknameLower] = textField.text.lowercaseString
                self.save(user)
            case "Email":
                if textField.text.isEmail {
                    let query = PFUser.query()
                    query?.whereKey(Constants.User.Email, equalTo: textField.text)
                    query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                        if let error = error {
                            ParseErrorHandler.handleParseError(error)
                            if error.code == 101 {
                                user[Constants.User.Email] = self.textField.text
                                self.save(user)
                            }
                        } else {
                            ProgressHUD.showError("This email is already bind with another account")
                        }
                    })
                } else {
                    ProgressHUD.showError("Invalid Email Address")
                    return
                }
            default:
                break
            }
        }
    }
    
    func save(user: PFUser) {
        user.saveEventually({ (success, error) -> Void in
            if success {
                println("info changed")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                println("network error")
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! YALFoldingTabBarController).tabBarView.hidden = false
        switch type
        {
        case "ID":
            self.title = "Whistle ID"
        case "Name":
            self.title = "Name"
        case "Email":
            self.title = "Email"
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch type
        {
        case "ID":
            return "Whistle ID"
        case "Name":
            return "Name"
        case "Email":
            return "Email"
        default:
            break
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch type
        {
        case "ID":
            return "The unique ID is used for friend searching and password protection."
        case "Name":
            return "Please type your new nickname."
        case "Email":
            return "Please bind your account with an email address for higher account security"
        default:
            break
        }
        return ""
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let num: Int = count(textField.text)
        var limit = 0
        switch type
        {
        case "ID":
            limit = 15
        case "Name":
            limit = 16
        case "Email":
            limit = 30
        default:
            break
        }
        if num - range.length + count(string) > limit {
            return false
        } else {
            return true
        }
    }
}