//
//  PhoneLoginView.swift
//  ParseStarterProject
//
//  Created by Yetian Mao on 6/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
import Bolts
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class PhoneLoginView: UIViewController, TSMessageViewProtocol
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var titleLabel                       : WEContentLabel!
    @IBOutlet weak var backButton                       : UIButton!
    @IBOutlet weak var textField                        : UITextField!
    @IBOutlet weak var sendCodeButton                   : UIButton!
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var questionLabel                    : UILabel!
    @IBOutlet weak var subtitleLabel                    : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    //----------------------------------------------------------------------------------------------------------
    private var phoneNumber                             : String
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initialized
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        phoneNumber = ""
        super.init(coder: aDecoder)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        configLooks()
        step1()
        self.editing = true
        TSMessage.setDelegate(self)
        TSMessage.setDefaultViewController(self)
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewWillAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - IBActions
    //----------------------------------------------------------------------------------------------------------
    @IBAction func backButtonTapped(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        editing = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------
    @IBAction func didTapSendCodeButton()
    //----------------------------------------------------------------------------------------------------------
    {
        if phoneNumber == "" {
            if count(textField.text) != 10 {
                TSMessage.showNotificationWithTitle("Phone Login", subtitle: "You must enter a 10-digit US phone number including area code.", type: TSMessageNotificationType.Error)
                return step1()
            }
            self.editing = false
            let params = ["phoneNumber" : textField.text, "login" : true]
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
                    TSMessage.showNotificationWithTitle("Login Error", subtitle: description, type: TSMessageNotificationType.Error)
                    return self.step1()
                }
                return self.step2()
            }
        } else {
            if let text = textField?.text, let code = text.toInt() {
                if count(text) == 4 {
                    return doLogin(phoneNumber, code: code)
                }
            }
            TSMessage.showNotificationWithTitle("Code Entry", subtitle: "You must enter the 4 digit code texted to your phone number.", type: TSMessageNotificationType.Error)
        }
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        view.backgroundColor                            = Constants.Color.Background
        var darkBlur                                    = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                                    = UIVisualEffectView(effect: darkBlur)
        blurView.frame                                  = view.bounds
        view.insertSubview(blurView, atIndex: 0)
        sendCodeButton.layer.cornerRadius               = 25
        sendCodeButton.backgroundColor                  = Constants.Color.ContentBackground
        sendCodeButton.setTitleColor(Constants.Color.TextLight, forState: .Normal)
        let origImage                               = backButton.imageView?.image
        let tintedImage                             = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        backButton.setImage(tintedImage, forState: .Normal)
        backButton.tintColor                        = Constants.Color.TextLight
        
        titleLabel.addBottomBorderWithHeight(0.3, color: Constants.Color.TextLight)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func step1()
    //----------------------------------------------------------------------------------------------------------
    {
        phoneNumber                                     = ""
        textField.placeholder                           = "123-456-7890"
        questionLabel.text                              = "Please enter your phone number to log in:"
        subtitleLabel.text                              = "This number is limited to 10-digit US numbers."
        sendCodeButton.enabled                          = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func step2()
    //----------------------------------------------------------------------------------------------------------
    {
        phoneNumber                                     = textField.text
        textField.text                                  = ""
        textField.placeholder                           = "1234"
        questionLabel.text                              = "Enter the 4-digit confirmation code:"
        subtitleLabel.text                              = "It was sent in an SMS message to +1" + phoneNumber
        sendCodeButton.enabled                          = true
    }
    
    //----------------------------------------------------------------------------------------------------------
    func doLogin(phoneNumber: String, code: Int)
    //----------------------------------------------------------------------------------------------------------
    {
        self.editing = false
        let params = ["phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
        PFCloud.callFunctionInBackground("logIn", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let description = error?.description {
                self.editing = true
                return self.showAlert("Login Error", message: description)
            }
            if let token = response as? String {
                PFUser.becomeInBackground(token) { (user: PFUser?, error: NSError?) -> Void in
                    if let user = user {
                        ParsePushUserAssign()
                        PFCloud.callFunctionInBackground("deleteSession", withParameters: ["device": PFInstallation.currentInstallation().installationId]) { (message, error) -> Void in
                            if let message: AnyObject = message {
                                println(message)
                            } else {
                                println(error)
                            }
                        }
                        self.performSegueWithIdentifier("phone_to_init", sender: self)
                    } else {
                        TSMessage.showNotificationWithTitle("Login Error", subtitle: "Something happened while trying to log in.\nPlease try again.", type: TSMessageNotificationType.Error)
                        ParseErrorHandler.handleParseError(error)
                        self.editing = true
                        return self.step1()
                    }
                }
            } else {
                self.editing = true
                TSMessage.showNotificationWithTitle("Login Error", subtitle: "Something went wrong.  Please try again.", type: TSMessageNotificationType.Error)
                ParseErrorHandler.handleParseError(error)
                return self.step1()
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func setEditing(editing: Bool, animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        sendCodeButton.enabled                          = editing
        textField.enabled                               = editing
        if editing {
            textField.becomeFirstResponder()
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func showAlert(title: String, message: String)
    //----------------------------------------------------------------------------------------------------------
    {
        return UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // MARK: - Delegates
    //----------------------------------------------------------------------------------------------------------
    func customizeMessageView(messageView: TSMessageView!)
    //----------------------------------------------------------------------------------------------------------
    {
        messageView.alpha = 0.85
    }
}

//----------------------------------------------------------------------------------------------------------
extension PhoneLoginView : UITextFieldDelegate
//----------------------------------------------------------------------------------------------------------
{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.didTapSendCodeButton()
        
        return true
    }
}

