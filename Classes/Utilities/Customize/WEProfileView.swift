//
//  WEProfileView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/26/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Parse
import UIKit

//----------------------------------------------------------------------------------------------------------
class WEProfileView: UIImageView
//----------------------------------------------------------------------------------------------------------
{
    var user: PFUser!
    var useDefault: Bool = false
    var isWaiting: Bool = false
    var canTap: Bool = true
    var isThumbnail: Bool = false
    var imageView: UIImageView!
    var borderWidth: CGFloat = 3
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.userInteractionEnabled = true
        self.image = UIImage(named: "clusterSmall")
        self.contentMode = UIViewContentMode.ScaleAspectFill
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        self.addGestureRecognizer(tap)
    }
    
    init(user: PFUser, userInteraction: Bool)
    {
        super.init(image: UIImage(named: "clusterSmall"))
        self.contentMode = UIViewContentMode.ScaleAspectFill
        if userInteraction
        {
            self.userInteractionEnabled = true
            var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
            self.addGestureRecognizer(tap)
        }
        loadImage(user)
    }
    
    override func layoutSubviews()
    {
        if self.isWaiting {
            layer.borderColor = UIColor.whiteColor().CGColor
            backgroundColor = Constants.Color.ContentBackground
        }
        else if self.user == nil || useDefault
        {
            layer.borderColor = UIColor.whiteColor().CGColor
        }
        else
        {
            if let gender = user[Constants.User.Gender] as? Int
            {
                if gender == 1
                {
                    layer.borderColor = UIColorFromHex(0x9999FF, alpha: 1).CGColor
                } else {
                    layer.borderColor = UIColorFromHex(0xA43E51, alpha: 0.5).CGColor
                }
            } else {
                layer.borderColor = UIColor.whiteColor().CGColor
            }
        }
        layer.borderWidth = borderWidth
        layer.cornerRadius = self.bounds.size.width / 2
    }
    
    func loadImage(user: PFUser)
    {
        user.fetchIfNeededInBackgroundWithBlock { (user, error) -> Void in
            if let user = user as? PFUser {
                self.user = user
                var imageFile: PFFile?
                if self.isThumbnail {
                    imageFile = user[Constants.User.Thumbnail] as? PFFile
                } else {
                    imageFile = user[Constants.User.Portrait] as? PFFile
                }
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
        }
    }
    
    func tapped() {
        if !canTap
        {
            return
        }
        
        if let base = UIApplication.topViewController()
        {
            var vc = base.storyboard?.instantiateViewControllerWithIdentifier("ProfileOthersView") as! ProfileOthersView
            vc.user = self.user
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func presentImageView(image: UIImage) {
        let width = self.bounds.width
        let userIconWidth = width - borderWidth * 2
        imageView = UIImageView(image: image)
        imageView.userInteractionEnabled = true
        imageView.frame = CGRectMake(0, 0, userIconWidth, userIconWidth)
        imageView.center = CGPointMake(width/2, width/2)
        imageView.clipsToBounds                          = true
        imageView.layer.cornerRadius                     = userIconWidth/2
        self.addSubview(imageView)
    }
    
}











