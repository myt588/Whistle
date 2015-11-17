//
//  CurrentReoprtTable.swift
//  
//
//  Created by Lu Cao on 10/28/15.
//
//

import UIKit

class CurrentReoprtTable: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var checkMark1: WETintImageView!
    @IBOutlet weak var checkMark2: WETintImageView!
    @IBOutlet weak var checkMark3: WETintImageView!
    @IBOutlet weak var checkMark4: WETintImageView!
    @IBOutlet weak var checkMark5: WETintImageView!
    @IBOutlet weak var checkMark6: WETintImageView!
    
    @IBOutlet weak var textView: WETextView!
    @IBOutlet weak var countLabel: WEFontIndicator!
    @IBOutlet weak var headerTextLabel: WEFontHeader!
    
    @IBOutlet weak var reason1: WEFontContent!
    @IBOutlet weak var reason2: WEFontContent!
    @IBOutlet weak var reason3: WEFontContent!
    @IBOutlet weak var reason4: WEFontContent!
    @IBOutlet weak var reason5: WEFontContent!
    @IBOutlet weak var reason6: WEFontContent!
    
    
    var favor: PFObject?
    var checkmarks = [WETintImageView]()
    var reasons = [WEFontContent]()
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rightButton = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action:"submit")
        self.navigationItem.rightBarButtonItem = rightButton
        var leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action:"cancel")
        self.navigationItem.leftBarButtonItem = leftButton
        self.title = "Report"
        
        self.headerTextLabel.text = MessageName.ReportTextHeader.rawValue
        self.reason1.text = MessageName.ReportReason1.rawValue
        self.reason2.text = MessageName.ReportReason2.rawValue
        self.reason3.text = MessageName.ReportReason3.rawValue
        self.reason4.text = MessageName.ReportReason4.rawValue
        self.reason5.text = MessageName.ReportReason5.rawValue
        self.reason6.text = MessageName.ReportReason6.rawValue
        
        reasons = [reason1, reason2, reason3, reason4, reason5, reason6]
        checkmarks = [checkMark1, checkMark2, checkMark3, checkMark4, checkMark5, checkMark6]
        textView.delegate = self
        textView.backgroundColor = Constants.Color.ContentBackground
        textView.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8)
        textView.textColor = UIColor.whiteColor()
        textView.layer.cornerRadius = 8
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2...7:
            toggleCheckmark(indexPath.row - 2)
            selectedIndex = indexPath.row - 2
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 2...7:
            toggleCheckmark(indexPath.row - 2)
        default:
            return
        }
    }
    
    func toggleCheckmark(number: Int) {
        bounceView(checkmarks[number])
        checkmarks[number].hidden = !checkmarks[number].hidden
    }
    
    func submit() {
        if textView.text == "" && selectedIndex == nil{
            MessageHandler.message(MessageName.NeedReason, vc: self.navigationController)
            return
        }
        if let favor = self.favor {
            if let user = favor[Constants.Favor.CreatedBy] as? PFUser {
                let userReport = PFObject(className: Constants.UserReportPivotTable.Name)
                userReport[Constants.UserReportPivotTable.From] = PFUser.currentUser()
                userReport[Constants.UserReportPivotTable.To] = user
                userReport[Constants.UserReportPivotTable.Because] = favor
                userReport[Constants.UserReportPivotTable.Reason] = reasons[selectedIndex!].text! + textView.text
                userReport.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        MessageHandler.message(MessageName.Reported)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
