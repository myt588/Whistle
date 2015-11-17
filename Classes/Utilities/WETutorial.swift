//
//  WETutorial.swift
//  Whistle
//
//  Created by Lu Cao on 11/10/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

class WETutorial {
    
    // MARK: - String
    
    private var rightTabButtonText = NSAttributedString(string: "Tap here to post a new favor")
    private var tagBarText = NSAttributedString(string: "Tap or swipe to choose multiple tags")
    
    private var interestText = NSAttributedString(string: "Tap n Hold me to interest favor")
    private var interestedText = NSAttributedString(string: "Favor interested")
    
    private var waitForAssistantText = NSAttributedString(string: "Waiting for assistants")
    private var pickAssistantText = NSAttributedString(string: "Tap to pick an assistant")
    private var confirmButtonText = NSAttributedString(string: "Confirm only after help is delivered")
    
    private var popover = DXPopover()
    
    func dismiss() {
        popover.dismiss()
    }
    
    
    // MARK: - Favor View
    
    func favorViewTutorial(inView: UIView, tagBar: UIView, rightTabButton: UIView) {
        if UserDefault.getBool("favorViewTutorial") { return }
        
        var tagBarPopover = DXPopover()
        tagBarPopover.showAtView(tagBar, withText: tagBarText)
        tagBarPopover.didDismissHandler = {
            var rightTabButtonPopover = DXPopover()
            rightTabButtonPopover.showAtView(rightTabButton, withText: self.rightTabButtonText)
        }
        UserDefault.saveBool("favorViewTutorial", value: true)
    }
    
    func interestTutorial(inView: UIView, status: Int) {
        if UserDefault.getBool("interestTutorial") { return }
        
        var interestButtonPopover = DXPopover()
        var atPoint = CGPointMake(CGRectGetMaxX(inView.frame) - 50, CGRectGetMidY(inView.frame) - 5)
        if status == 0 {            // interest
            interestButtonPopover.showAtPoint(atPoint, popoverPostion: DXPopoverPosition.Up, withText: interestText, inView: inView)
        } else if status == 1 {     // interested
            interestButtonPopover.showAtPoint(atPoint, popoverPostion: DXPopoverPosition.Up, withText: interestedText, inView: inView)
        }
        UserDefault.saveBool("interestTutorial", value: true)
    }
    
    
    // MARK: - Current Cell
    
    func waitForAssistantTutorial(inView: UIView) {
        if UserDefault.getBool("waitForAssistantTutorial") { return }
        
        var waitForAssistantPopover = DXPopover()
        var atPoint = CGPointMake(CGRectGetMidX(inView.frame), CGRectGetMidY(inView.frame) + 25)
        popover.showAtPoint(atPoint, popoverPostion: DXPopoverPosition.Down, withText: waitForAssistantText, inView: inView)
        
        UserDefault.saveBool("waitForAssistantTutorial", value: true)
    }
    
    func pickAssistantTutorial(inView: UIView) {
        if UserDefault.getBool("pickAssistantTutorial") { return }
        
        var pickAssistantPopover = DXPopover()
        var atPoint = CGPointMake(CGRectGetMidX(inView.frame), CGRectGetMidY(inView.frame) + 25)
        popover.showAtPoint(atPoint, popoverPostion: DXPopoverPosition.Down, withText: pickAssistantText, inView: inView)
        UserDefault.saveBool("pickAssistantTutorial", value: true)
    }
    
    func confirmButtonTutorial(inView: UIView) {
        if UserDefault.getBool("confirmButtonTutorial") { return }
        
        var atPoint = CGPointMake(20, CGRectGetMidY(inView.frame) + 55)
        popover.showAtPoint(atPoint, popoverPostion: DXPopoverPosition.Up, withText: confirmButtonText, inView: inView)
        UserDefault.saveBool("confirmButtonTutorial", value: true)
    }
}