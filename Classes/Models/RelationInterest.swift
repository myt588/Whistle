//
//  FavorUser.swift
//  Whistle
//
//  Created by Yetian Mao on 11/4/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Parse

class RelationInterest: PFObject {
    
    var favor: PFObject!
    var taker: PFUser!
    var active: Bool!
    var price: Int!
    var target: AnyObject?
    
    class func sendInterest(favor: PFObject, price: Int, block: PFBooleanResultBlock) {
        let relationTable = PFObject(className: Constants.FavorUserPivotTable.Name)
        relationTable[Constants.FavorUserPivotTable.Takers] = PFUser.currentUser()
        relationTable[Constants.FavorUserPivotTable.Favor] = favor
        relationTable[Constants.FavorUserPivotTable.Active] = true
        if price != favor[Constants.Favor.Price] as? Int {
            relationTable[Constants.FavorUserPivotTable.Price] = price
        } else {
            relationTable[Constants.FavorUserPivotTable.Price] = favor[Constants.Favor.Price] as? Int
        }
        relationTable.saveInBackgroundWithBlock(block)
    }
    
    class func saveInterestLocally() {
        let path = NSBundle.mainBundle().pathForResource("TableData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        //tableData = dict!.objectForKey("AppleDevice") as! [String]
    }
    
    func loadGameData() {
        
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        
        let fileManager = NSFileManager.defaultManager()
        
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist") {
                
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        
        var myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            
            //...
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
    }
    
    func saveGameData() {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        
        var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
//        dict.setObject(bedroomFloorID, forKey: BedroomFloorKey)
//        dict.setObject(bedroomWallID, forKey: BedroomWallKey)
        //...
        
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Saved GameData.plist file is --> \(resultDictionary?.description)")
    }
    
}
