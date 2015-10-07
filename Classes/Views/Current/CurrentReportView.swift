//
//  CurrentReportView.swift
//  Whistle
//
//  Created by Lu Cao on 8/12/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class CurrentReportView: UIViewController, UITextViewDelegate {
   
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countLabel: WEContentLabel!
    
    var favor: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configLooks()
        configBarButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        textView.resignFirstResponder()
    }
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configBarButton()
    //----------------------------------------------------------------------------------------------------------
    {
        var rightButton = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action:"submit")
        self.navigationItem.rightBarButtonItem             = rightButton
        var leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action:"cancel")
        self.navigationItem.leftBarButtonItem              = leftButton
    }
    
    func configLooks() {
        view.backgroundColor                            = Constants.Color.Background
        var darkBlur                                    = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                                    = UIVisualEffectView(effect: darkBlur)
        blurView.frame                                  = view.bounds
        view.insertSubview(blurView, atIndex: 0)
        
        textView.delegate                               = self
        textView.backgroundColor                        = UIColor.clearColor()
        textView.textContainerInset                     = UIEdgeInsetsMake(10, 8, 10, 8)
        textView.textColor                              = Constants.Color.CellTextReverse
        textView.layer.cornerRadius                     = 8
//        textView.text                                   = Constants.PlaceHolder.NewReport

    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submit() {
        if textView.text == "" {
            ProgressHUD.showError("Please specify your reason")
            return
        }
        if let favor = self.favor {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser {
                let userReport = PFObject(className: Constants.UserReportPivotTable.Name)
                userReport[Constants.UserReportPivotTable.From] = PFUser.currentUser()
                userReport[Constants.UserReportPivotTable.To] = user
                userReport[Constants.UserReportPivotTable.Because] = favor
                userReport[Constants.UserReportPivotTable.Reason] = textView.text
                userReport.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        TSMessage.showNotificationWithTitle("Report", subtitle: "Your Report has been posted on \(user[Constants.User.Nickname] as! String)'s wall", type: TSMessageNotificationType.Success)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
    }
//    
//    func textViewDidBeginEditing(textView: UITextView)
//    {
//        if textView.text == Constants.PlaceHolder.NewReport {
//            textView.text = ""
//            textView.textColor = Constants.Color.CellTextReverse
//        }
//        textView.becomeFirstResponder()
//    }
//    
//    func textViewDidEndEditing(textView: UITextView)
//    {
//        if textView.text == "" {
//            textView.text = Constants.PlaceHolder.NewReport
//            textView.textColor = Constants.Color.CellPlaceHolder
//        }
//        textView.resignFirstResponder()
//    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        let num: Int = count(textView.text)
        if num - range.length + count(text) > Constants.Limit.Reward {
            return false
        } else {
            countLabel.text = "\(num - range.length + count(text))/\(Constants.Limit.Report)"
            return true
        }
    }
}
