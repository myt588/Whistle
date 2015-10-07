//
//  ChatPeopleCell.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import Parse

class ChatPeopleCell: UITableViewCell {

    @IBOutlet weak var portrait: WEImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        portrait.layer.borderWidth = 2
        portrait.layer.borderColor = Constants.Color.Border.CGColor
        portrait.layer.cornerRadius = 25
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(user: PFUser?){
        if let user = user {
            userName.text = user[Constants.User.Nickname] as? String
            if let thumbnail = user[Constants.User.Thumbnail] as? PFFile {
                thumbnail.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if let data = data {
                        self.portrait.image = UIImage(data: data)
                    }
                })
            }
        }
    }

}
