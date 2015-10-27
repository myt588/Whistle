//
//  WEEmptyTableView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/27/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//
//  WEEmptyTableCell.swift
//  Whistle
//
//  Created by Yetian Mao on 10/25/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class WEEmptyTableView: UIView
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var messageLabel: WEFontContent!
    @IBOutlet weak var subMessageLabel: WEFontContent!
    //----------------------------------------------------------------------------------------------------------
    // Constraints
    //----------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
    }
    
    func bindData(message: String = "", subMessage: String = "", image: UIImage = UIImage(named: "favor_whistle_icon")!)
    {
        logoImageView.image = image
        messageLabel.text = message
        subMessageLabel.text = subMessage
    }
    
}


