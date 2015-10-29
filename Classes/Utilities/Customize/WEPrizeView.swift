//
//  WEPrizeView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/28/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class WEPrizeView: UIView
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rewardView: UIImageView!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initializations
    override func awakeFromNib() {
        let prizeView = NSBundle.mainBundle().loadNibNamed("WEPrizeView", owner: self, options: nil)[0] as! UIView
        self.addSubview(prizeView)
        prizeView.frame = self.bounds
        prizeView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - Functions
    func bindData(price: Int)
    {
        if price == 0
        {
            rewardView.hidden = false
            priceLabel.hidden = true
        } else {
            rewardView.hidden = true
            priceLabel.hidden = false
            priceLabel.text = "$\(price)"
        }
    }
    
}



