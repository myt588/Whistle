//
//  ChatPeopleSendRequestView.swift
//  Whistle
//
//  Created by Lu Cao on 8/18/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleViewRequestView: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var portraitView: WEImageView!
    
    var request: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData(request)
    }
    
    @IBAction func accept(sender: UIButton) {
        if let request = request {
            request[Constants.UserRequestPivotTable.Status] = 2
            request.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    let people = PFObject(className: Constants.People.Name)
                    people[Constants.People.User1] = PFUser.currentUser()!
                    people[Constants.People.User2] = request[Constants.UserRequestPivotTable.From] as! PFUser
                    people.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            ProgressHUD.showSuccess("Accept Success")
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func reject(sender: UIButton) {
        if let request = request {
            request[Constants.UserRequestPivotTable.Status] = 1
            request.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    ProgressHUD.showSuccess("Reject Success")
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
    func bindData(request: PFObject?) {
        if let request = request {
            textView.text = request[Constants.UserRequestPivotTable.Message] as? String
            if let user = request[Constants.UserRequestPivotTable.From] as? PFUser {
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
    }
    
}
