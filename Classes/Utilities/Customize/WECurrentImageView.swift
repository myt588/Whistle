//
//  WECurrentImageView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/29/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

class WECurrentImageView: WEProfileView {
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.userInteractionEnabled = true
        self.image = UIImage(named: "current_portrait")
        self.borderWidth = 5
    }
    
}
