//
//  ChatAddPeopleCell.swift
//  Whistle
//
//  Created by Lu Cao on 8/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ChatPeopleStaticCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userInteractionEnabled = true
    }

}
