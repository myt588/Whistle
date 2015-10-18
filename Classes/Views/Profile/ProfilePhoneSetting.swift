//
//  ProfilePhoneSetting.swift
//  Whistle
//
//  Created by Yetian Mao on 8/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class ProfilePhoneSetting: UITableViewController, UITextFieldDelegate
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var phoneNumberTextField             : UITextField!
    @IBOutlet weak var verificationTextField            : UITextField!
    @IBOutlet weak var sendButton                       : UIButton!
    //----------------------------------------------------------------------------------------------------------
    
    var verificationCode                                : String!
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        phoneNumberTextField.delegate = self
        verificationCode = ""
        phoneNumberTextField.textColor = UIColor.whiteColor()
        verificationTextField.textColor = UIColor.whiteColor()
        configBarButton()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(true)
        self.title = "Phone Number"
        phoneNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func sendCode(sender: UIButton) {
        if count(phoneNumberTextField.text) != 10 {
            ProgressHUD.showError("You must enter a 10-digit US phone number including area code.")
            return
        }
        self.editing = false
        let params = ["phoneNumber" : phoneNumberTextField.text, "login" : false]
        PFCloud.callFunctionInBackground("sendCode", withParameters: params as [NSObject : AnyObject]) {
            (response: AnyObject?, error: NSError?) -> Void in
            self.editing = true
            if let error = error {
                ParseErrorHandler.handleParseError(error)
                var description = error.description
                if count(description) == 0 {
                    description = "There was a problem with the service.\nTry again later."
                } else if let message = error.userInfo?["error"] as? String {
                    description = message
                }
                ProgressHUD.showError(error.localizedDescription)
            } else {
                if let response = response as? Int {
                    self.verificationCode = "\(response)"
                }
                self.sendButton.titleLabel?.text = "resend"
                ProgressHUD.showSuccess("An four digit verification code has been sent to the following phone number.")
                self.verificationTextField.becomeFirstResponder()
            }
        }
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
            if count(phoneNumberTextField.text) != 10 {
                ProgressHUD.showError("Please enter a valid phone number")
                return
            }
            if verificationTextField.text != verificationCode {
                ProgressHUD.showError("The verification code is incorrect. Please tap resend to redo the process")
                return
            }
            user[Constants.User.Phone] = phoneNumberTextField.text
            user[Constants.User.PhoneVerified] = true
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
        return 2
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        }
        if section == 1 {
            return 30
        }
        return 40
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Phone Number"
        }
        if section == 1 {
            return "Verification Code"
        }
        return ""
    }
}