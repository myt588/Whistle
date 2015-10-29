//
//  WETagCollectionCell.swift
//  Whistle
//
//  Created by Yetian Mao on 10/15/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class WETagCollectionViewCell: UICollectionViewCell {
    
    override var selected: Bool {
        didSet {
            if self.selected {
                // do something
            }
        }
    }
    
    lazy var textContent: UILabel! = {
        let textContent = UILabel(frame: CGRectZero)
        textContent.layer.masksToBounds = true
//        textContent.layer.cornerRadius = 20
//        textContent.layer.borderWidth = 2
//        textContent.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1).CGColor
        textContent.font = UIFont(name: "TimesNewRomanPSMT", size: 16)!
        textContent.textAlignment = NSTextAlignment.Center
        textContent.frame = CGRectMake(textContent.frame.origin.x, textContent.frame.origin.y, textContent.frame.width, textContent.frame.height+7)
        return textContent
        }()
    
    lazy var border: UIView! = {
        let border = UIView(frame: CGRectZero)
        border.backgroundColor = Constants.Color.Background
        return border
    }()
    
    func initContent(tag: Tag) {
        self.contentView.addSubview(textContent)
        textContent.text = tag.textContent
        textContent.sizeToFit()
        textContent.frame.size.width = textContent.frame.size.width
        textContent.frame.size.height = textContent.frame.size.height
        selected = tag.selected
        textContent.backgroundColor = UIColor.clearColor()
        self.textContent.layer.backgroundColor = (self.selected == true) ? colorSelectedTag.CGColor : colorUnselectedTag.CGColor
        self.textContent.textColor = (self.selected == true) ? colorTextSelectedTag : colorTextUnSelectedTag
        
        self.contentView.addSubview(border)
        border.frame = CGRectMake(0, textContent.frame.size.height, textContent.frame.size.width, 3)
        self.border.backgroundColor = (self.selected == true) ? Constants.Color.Main2 : Constants.Color.Background
    }
    
    func initAddButtonContent() {
        self.contentView.addSubview(textContent)
        textContent.text = "+"
        textContent.sizeToFit()
        textContent.frame.size = CGSizeMake(40, 40)
        textContent.backgroundColor = UIColor.clearColor()
        self.textContent.layer.backgroundColor = UIColor.clearColor().CGColor
        self.textContent.textColor = UIColor.whiteColor()
    }
    
    func animateSelection(selection: Bool) {
        selected = selection
        
      self.border.backgroundColor = (self.selected == true) ? Constants.Color.Main2 : Constants.Color.Background
        
        self.textContent.frame.origin = CGPointMake(self.textContent.frame.origin.x, self.textContent.frame.origin.y + 10)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.allZeros, animations: { () -> Void in
            self.textContent.frame.origin = CGPointMake(self.textContent.frame.origin.x, self.textContent.frame.origin.y - 10)
            
            }, completion: nil)
    }
    
    class func contentHeight(content: String) -> CGSize {
        let styleText = NSMutableParagraphStyle()
        styleText.alignment = NSTextAlignment.Center
        let attributs = [NSParagraphStyleAttributeName:styleText, NSFontAttributeName:UIFont.boldSystemFontOfSize(14)]
        let sizeBoundsContent = (content as NSString).boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.size.width,
            UIScreen.mainScreen().bounds.size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributs, context: nil)
        return CGSizeMake(sizeBoundsContent.width, sizeBoundsContent.height + 5)
    }
}



