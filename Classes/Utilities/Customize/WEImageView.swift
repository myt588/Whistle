//
//  WEImageView.swift
//  Whistle
//
//  Created by Lu Cao on 7/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import ParseUI
import Parse
import UIKit

//----------------------------------------------------------------------------------------------------------
class WEImageView: PFImageView
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser?
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        
        self.contentMode = UIViewContentMode.ScaleAspectFill

        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        self.addGestureRecognizer(tap)
    }
    
    func tapped(sender: UITapGestureRecognizer) {
        if let base = UIApplication.topViewController() {
            var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ProfileOthersView") as! ProfileOthersView
            vc.user = self.user
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
}










