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
    var imageView: UIImageView!
    var style: UIBlurEffectStyle! = .Light
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
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
        imageView = UIImageView(frame: self.frame)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.userInteractionEnabled = true
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        var darkBlur = UIBlurEffect(style: style)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.frame
        imageView.addSubview(blurView)
    }
    
}










