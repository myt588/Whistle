//
//  HelperMethods.swift
//  Arrived
//
//  Created by Lu Cao on 4/25/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation
import UIKit

// add a leftview which is an icon to a uitextview
func addIconToUITextFieldLeftView(textField: UITextField, imageName: String) {
    var imageView = UIImageView(image: UIImage(named: imageName))
    textField.leftViewMode = .Always
    imageView.frame = CGRect(x: 0, y: 0, width: textField.frame.height*0.8, height: textField.frame.height*0.8)
    textField.leftView = imageView
}

/**
Validate phone number
*/
func phoneNumberValidation(value: String) -> Bool {
    var charcter  = NSCharacterSet(charactersInString: "0123456789").invertedSet
    var filtered:NSString!
    var inputString:NSArray = value.componentsSeparatedByCharactersInSet(charcter)
    filtered = inputString.componentsJoinedByString("")
    return  value == filtered
}

/**
Detect credit card type
*/
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}

func detectCreditCardType(num: String) -> String {
    
    if Regex("^4[0-9]{12}(?:[0-9]{3})?$").test(num) {
        return "Visa"
    } else if Regex("^5[1-5][0-9]{14}$").test(num) {
        return "MasterCard"
    } else if Regex("^3[47][0-9]{13}$").test(num) {
        return "American Express"
    } else if Regex("^6(?:011|5[0-9]{2})[0-9]{12}$").test(num) {
        return "Discover"
    } else if Regex("^(?:2131|1800|35[0-9]{3})[0-9]{11}").test(num) {
        return "JCB"
    } else {
        return "Invalid"
    }
}

func bounceView(myView: UIView) {
    myView.transform = CGAffineTransformMakeScale(0.1, 0.1)
    UIView.animateWithDuration(2.0,
        delay: 0,
        usingSpringWithDamping: 0.2,
        initialSpringVelocity: 6.0,
        options: UIViewAnimationOptions.AllowUserInteraction,
        animations: {
            myView.transform = CGAffineTransformIdentity
        }, completion: nil)
}

func fadeInView(myView: UIView, t: NSTimeInterval) {
    UIView.animateWithDuration(t, animations: {
        myView.alpha = 1.0
    })
}

func fadeOutView(myView: UIView, t: NSTimeInterval) {
    UIView.animateWithDuration(t, animations: {
        myView.alpha = 0
    })
}

func roundedWithWhiteBorder(myView: UIView, width: CGFloat) {
    myView.layer.borderWidth = width
    myView.layer.masksToBounds = true
    myView.layer.borderColor = UIColorFromHex(0xFFFFFF, alpha: 1).CGColor
    myView.layer.cornerRadius = myView.frame.height/2
    myView.clipsToBounds = true
}

func calculateHeightForString(inString:String) -> CGFloat
{
    var messageString = inString
    var attributes = [UIFont(): UIFont.systemFontOfSize(15.0)]
    var attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: attributes)
    var rect:CGRect = attrString!.boundingRectWithSize(CGSizeMake(300.0,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context:nil )//hear u will get nearer height not the exact value
    var requredSize:CGRect = rect
    return requredSize.height  //to include button's in your tableview
    
}

func audioNameWithDate () -> String {
    let now = NSDate()
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    let name = dateFormatter.stringFromDate(now)
    return name
}

func addBlurView(view: UIView) {
    var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurView = UIVisualEffectView(effect: darkBlur)
    blurView.frame = view.bounds
    view.insertSubview(blurView, atIndex: 0)
}

func addBlurView(view: UIView, fromImage: UIImage) {
    var darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    var blurView = UIVisualEffectView(effect: darkBlur)
    blurView.frame = view.bounds
    var blurImage = UIImageView(image: fromImage)
    blurImage.frame = view.bounds
    view.insertSubview(blurImage, atIndex: 0)
    view.insertSubview(blurView, aboveSubview: blurImage)
}

func addBadge(tabBar: YALFoldingTabBarController, left1: String, left2: String, right1: String, right2: String) {
    if let button = tabBar.tabBarView.myButtons[4] as? MIBadgeButton {  // left 1
        button.badgeString = left2
    }
    if let button = tabBar.tabBarView.myButtons[5] as? MIBadgeButton {  // left 2
        button.badgeString = left1
    }
    if let button = tabBar.tabBarView.myButtons[6] as? MIBadgeButton {  // right 1
        button.badgeString = right1
    }
    if let button = tabBar.tabBarView.myButtons[7] as? MIBadgeButton {  // right 2
        button.badgeString = right2
    }
}

func socialShare(#sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
    var sharingItems = [AnyObject]()
    
    if let text = sharingText {
        sharingItems.append(text)
    }
    if let image = sharingImage {
        sharingItems.append(image)
    }
    if let url = sharingURL {
        sharingItems.append(url)
    }
    
    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [
        UIActivityTypeCopyToPasteboard,
        UIActivityTypeAirDrop,
        UIActivityTypeAddToReadingList,
        UIActivityTypeAssignToContact,
        UIActivityTypePostToTencentWeibo,
        UIActivityTypePostToVimeo,
        UIActivityTypePrint,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypePostToWeibo
    ]
    if let vc = UIApplication.topViewController() {
        vc.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func CurrentLocation() -> PFGeoPoint
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    return PFGeoPoint(latitude: app.coordinate.latitude, longitude: app.coordinate.longitude)
}

/*
Image Resizing Techniques: http://bit.ly/1Hv0T6i
*/
func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.drawInRect(CGRect(origin: CGPointZero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
}

