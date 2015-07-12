//
//  FavorListCell.swift
//  Whistle
//
//  Created by Lu Cao on 7/2/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//


//----------------------------------------------------------------------------------------------------------
import UIKit
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class FavorListCell: UITableViewCell
//----------------------------------------------------------------------------------------------------------
{

    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portraitView                         : UIImageView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var contentContainerView                 : UIView!
    @IBOutlet weak var audioView                            : FSVoiceBubble!
    @IBOutlet weak var distanceLabel                        : UILabel!
    @IBOutlet weak var priceLabel                           : UILabel!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Initialization
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
        backgroundColor                                         = Constants.Color.Background
        
        portraitView.layer.borderWidth                      = 3
        portraitView.layer.borderColor                      = Constants.Color.Border.CGColor
        portraitView.layer.cornerRadius                     = portraitView.layer.frame.height/2
    
        nameLabel.textColor                                 = Constants.Color.TextLight
        nameLabel.shadowColor                               = Constants.Color.Shadow
        nameLabel.shadowOffset                              = CGSizeMake(0, -1)
        
        contentContainerView.backgroundColor                = Constants.Color.ContentBackground
        contentContainerView.alpha                          = 0.85
        
        audioView.durationInsideBubble                      = true
        audioView.bubbleImage                               = UIImage(named: "fs_cap_bg")
        audioView.waveColor                                 = Constants.Color.Background
        audioView.animatingWaveColor                        = UIColor.grayColor()
        
        priceLabel.textColor                                = Constants.Color.TextLight
        distanceLabel.textColor                             = Constants.Color.TextLight
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configshapes()
    //----------------------------------------------------------------------------------------------------------
    {
        
    }

}
