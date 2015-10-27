//
//  TabBarController.swift
//  Whistle
//
//  Created by Yetian Mao on 6/30/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class TabBarController : YALFoldingTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let item1 : YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "nearby_icon"),
            leftItemImage: nil,
            rightItemImage: UIImage(named: "tab_new"))
        let item2 : YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "settings_icon"),
            leftItemImage: nil,
            rightItemImage: nil)
        self.leftBarItems = [item1, item2]
        let item3 : YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "chats_icon"),
            leftItemImage: nil,
            rightItemImage: nil)
        let item4 : YALTabBarItem = YALTabBarItem(itemImage: UIImage(named: "profile_icon"),
            leftItemImage: nil,
            rightItemImage: nil)
        self.rightBarItems = [item3, item4]
        self.centerButtonImage = UIImage(named: "tab_plus")

        //customize tabBarView
        self.tabBarView.extraTabBarItemHeight = YALExtraTabBarItemsDefaultHeight
        self.tabBarView.offsetForExtraTabBarItems = YALForExtraTabBarItemsDefaultOffset
        self.tabBarView.backgroundColor = UIColor.clearColor()
        self.tabBarView.tabBarColor = Constants.Color.Main
        self.tabBarViewHeight = YALTabBarViewDefaultHeight
        self.tabBarView.tabBarViewEdgeInsets = YALTabBarViewHDefaultEdgeInsets
        self.tabBarView.tabBarItemsEdgeInsets = YALTabBarViewItemsDefaultEdgeInsets
    }

}
