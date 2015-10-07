//
//  ChatPeopleSendRequestView.swift
//  Whistle
//
//  Created by Lu Cao on 8/18/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleSendRequestView: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var portraitView: WEImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        bindData(self.user)
    }
    
    override func viewDidAppear(animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        textView.resignFirstResponder()
    }
    
    @IBAction func sendFriendRequest(sender: UIButton) {
        let friendRequest = PFObject(className: Constants.UserRequestPivotTable.Name)
        friendRequest[Constants.UserRequestPivotTable.From] = PFUser.currentUser()!
        friendRequest[Constants.UserRequestPivotTable.To] = self.user!
        friendRequest[Constants.UserRequestPivotTable.Message] = textView.text
        friendRequest.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                ProgressHUD.showSuccess("Friend Request Sent")
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func bindData(user: PFUser?){
        if let user = user {
            nameLabel.text = user[Constants.User.Nickname] as? String
            if let thumbnail = user[Constants.User.Thumbnail] as? PFFile {
                thumbnail.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if let data = data {
                        self.portraitView.image = UIImage(data: data)
                    }
                })
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        let num: Int = count(textView.text)
        if num - range.length + count(text) > Constants.Limit.Reward {
            return false
        } else {
            countLabel.text = "\(num - range.length + count(text))/\(Constants.Limit.Rate)"
            return true
        }
    }

}
