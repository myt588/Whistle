//
//  UserDefault.swift
//  Whistle
//
//  Created by Yetian Mao on 11/6/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Parse

class UserDefault {
    
    class func saveBool(key: String, value: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let newKey = "\(PFUser.currentId())_\(key)"
        defaults.setBool(value, forKey: newKey)
    }
    
    class func getBool(key: String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let newKey = "\(PFUser.currentId())_\(key)"
        return defaults.boolForKey(newKey)
    }
}
