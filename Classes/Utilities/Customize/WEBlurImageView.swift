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
class WEBlurImageView: UIView
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser?
    var imageView: UIImageView!
    var style: UIBlurEffectStyle! = .Light
    var blurView: UIVisualEffectView!
    var shade: UIView!
    var needBlurView: Bool = false
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.imageView = UIImageView(frame: self.frame)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
    
    func addBlur() {
        self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        self.blurView.frame = imageView.frame
        self.imageView.addSubview(blurView)
    }
    
    func addShade() {
        shade = UIView(frame: self.frame)
        shade.alpha = 0.35765
        shade.backgroundColor = UIColor.grayColor()
        self.imageView.addSubview(shade)
    }
    
    func removeShade() {
        shade.removeFromSuperview()
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
                    dispatch_async(dispatch_get_main_queue()) {
                    let image = UIImage(data: data)
                    self.presentImageView(image!)
                    }
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })
        }
    }
    
    func presentImageView(image: UIImage) {
        self.imageView.image = image
        self.imageView.frame = self.frame
        if needBlurView {
            self.addBlur()
        }
    }
    
}










