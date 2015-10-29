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
class WEBlurImageView: PFImageView
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser?
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
    }
    
    init(user: PFUser)
    {
        super.init(image: UIImage(named: "user_photo"))
        loadImage(user)
    }
    
    func loadImage(user: PFUser)
    {
        self.user = user
        var imageFile: PFFile?
        imageFile = user[Constants.User.Portrait] as? PFFile
        if let imageFile = imageFile
        {
            imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data
                {
                    let image = UIImage(data: data)
                    self.presentImageView(image!)
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }
    
    func presentImageView(image: UIImage) {
        let width = self.bounds.width
        let imageView = UIImageView(image: image)
        imageView.userInteractionEnabled = true
        imageView.frame = self.frame
        self.addSubview(imageView)
        var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.frame
        imageView.addSubview(blurView)
    }
    
}










