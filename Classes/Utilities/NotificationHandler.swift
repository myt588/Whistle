//
//  NotificationHandler.swift
//  Whistle
//
//  Created by Yetian Mao on 11/18/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

class NotificationHandler {
    
    
    class func checkNotificationType(type: UIUserNotificationType) -> Bool
    {
        let currentSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        return (currentSettings.types & type) != nil
    }
    
}
