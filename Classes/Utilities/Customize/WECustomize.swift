//
//  WELabels.swift
//  Whistle
//  Custom classes that define the appearances
//  Created by Lu Cao on 7/16/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
// START: - Tables and Cells
//----------------------------------------------------------------------------------------------------------
class WETable: UITableView
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        backgroundColor                             = Constants.Color.TableBackground
//        var darkBlur                                = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        var blurView                                = UIVisualEffectView(effect: darkBlur)
//        backgroundView                              = blurView
        backgroundColor = Constants.Color.Background
        contentInset = UIEdgeInsetsMake(20, 0, YALTabBarViewDefaultHeight, 0)
    }
}

//----------------------------------------------------------------------------------------------------------
class WECell: UITableViewCell
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor                             = UIColor.clearColor()
    }
}

//----------------------------------------------------------------------------------------------------------
class WEHeader: UILabel
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor                                   = Constants.Color.PlaceHolder
        let fontSize                                = font.pointSize
        font                                        = UIFont(name: Constants.DefaultFont, size: fontSize)
        addBottomBorderWithHeight(0.4, color: Constants.Color.PlaceHolder)
    }
}

//----------------------------------------------------------------------------------------------------------
class WEHeaderIcon: UIImageView
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        layer.borderColor                           = Constants.Color.Border.CGColor
//        layer.borderWidth                           = 2
//        layer.cornerRadius                          = 16
//        backgroundColor                             = Constants.Color.Border
//        let origImage                               = image
//        let tintedImage                             = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        image                                       = tintedImage
//        tintColor                                   = Constants.Color.Background
    }
}

//----------------------------------------------------------------------------------------------------------
class WEHeaderLine: UIImageView
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor                             = Constants.Color.Main
    }
}

//----------------------------------------------------------------------------------------------------------
class WEHeaderDot: UIView
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor                             = Constants.Color.Main
        layer.cornerRadius                          = 6
    }
}

//----------------------------------------------------------------------------------------------------------
class WEContentLabel: UILabel
//----------------------------------------------------------------------------------------------------------
{
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor                                   = Constants.Color.CellText
        shadowColor                                 = Constants.Color.CellTextShadow
        shadowOffset                                = CGSizeMake(0, 0.5)
        let fontSize                                = font.pointSize
        font                                        = UIFont(name: Constants.DefaultContentFont, size: fontSize)
    }
}

//----------------------------------------------------------------------------------------------------------
class WEContentLabelWithBackground: UILabel
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        textColor                                   = Constants.Color.CellText
//        shadowColor                                 = Constants.Color.CellTextShadow
//        shadowOffset                                = CGSizeMake(0, 0.5)
//        layer.borderColor                           = Constants.Color.ContentBackground.CGColor
//        layer.borderWidth                           = 2
//        layer.cornerRadius                          = 6
//        layer.backgroundColor                       = Constants.Color.ContentBackground.CGColor
//        let fontSize                                = font.pointSize
//        font                                        = UIFont(name: Constants.DefaultContentFont, size: fontSize)
    }
    
//    override func drawRect(rect: CGRect) {
//        var insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
//    }
}

//----------------------------------------------------------------------------------------------------------
class WETextView: UITextView
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor                                   = Constants.Color.CellText
        backgroundColor                             = UIColor.clearColor()
    }
}

//----------------------------------------------------------------------------------------------------------
class WELvLabel: UILabel
    //----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor                             = Constants.Color.Border
        textColor                                   = Constants.Color.CellTextReverse
        layer.cornerRadius                          = 14
        alpha                                       = 0.95
        clipsToBounds                               = true
    }
}

//----------------------------------------------------------------------------------------------------------
// END: - Tables and Cells
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
class WESwitch: UISwitch
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.anchorPoint                           = CGPointMake(0.3, 0.5)
        transform                                   = CGAffineTransformMakeScale(0.75, 0.75)
    }
}

//----------------------------------------------------------------------------------------------------------
class WEButtonWithImage: UIButton
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor                                   = Constants.Color.Border
        let origImage                               = imageView!.image
        let tintedImage                             = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        setImage(tintedImage, forState: .Normal)
    }
}

//----------------------------------------------------------------------------------------------------------
class WEMapButton: UIButton
//----------------------------------------------------------------------------------------------------------
{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor                                   = Constants.Color.Main
        let origImage                               = imageView!.image
        let tintedImage                             = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        setImage(tintedImage, forState: .Normal)
        
//        var darkBlur                                = UIBlurEffect(style: UIBlurEffectStyle.Light)
//        var blurView                                = UIVisualEffectView(effect: darkBlur)
//        blurView.frame                              = bounds
//        blurView.userInteractionEnabled             = false
//        insertSubview(blurView, atIndex: 0)
//        clipsToBounds = true
        
        alpha = 1
    }
}

class WETintImageView: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tintColor                                   = Constants.Color.Main
        let origImage                               = image
        let tintedImage                             = origImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        image = tintedImage
    }
}

class WEProfileTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 8
        backgroundColor = Constants.Color.ContentBackground
        textColor = UIColor.whiteColor()
    }
}

class WEProfileTextView: UITextView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 8
        backgroundColor = Constants.Color.ContentBackground
        textColor = UIColor.whiteColor()
    }
}












