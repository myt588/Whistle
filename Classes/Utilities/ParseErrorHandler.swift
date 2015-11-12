//
//  ParseErrorHandler.swift
//  Whistle
//
//  Created by Yetian Mao on 7/25/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation
import Parse

class ParseErrorHandler {
    
    class func handleParseError(error: NSError?) {
        TSMessage.setDefaultViewController(UIApplication.rootViewController())
        if let error = error {
            if error.domain != PFParseErrorDomain {
                return
            }
            println("error code: \(error.code)")
            switch (error.code) {
            case PFErrorCode.ErrorInvalidSessionToken.rawValue:
                handleInvalidSessionTokenError()
            case PFErrorCode.ErrorTimeout.rawValue:
                handleTimeOutError()
            case PFErrorCode.ErrorObjectNotFound.rawValue:
                handleObjectNotFoundError()
            case PFErrorCode.ErrorConnectionFailed.rawValue:
                handleConnectionFailedError()
            case PFErrorCode.ErrorCacheMiss.rawValue:
                handleCasheMissError()
            default:
                break
            }
        }
    }
    
    class func LoginUser(vc: UIViewController) {
        var viewController = vc.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
        vc.presentViewController(viewController, animated: true, completion: nil)
    }
    
    private class func handleInvalidSessionTokenError() {
        println("invalid session token error")
        
        if let base = UIApplication.topViewController() {
            let alert = WEAlertController(title: "Invalid Session", message: "Session is no longer valid, please log out and log in again.", style: .Alert)
            alert.addAction(SimpleAlert.Action(title: "Log out", style: .OK) { action in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                var viewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
                base.presentViewController(viewController, animated: true, completion: nil)
            })
            base.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private class func handleTimeOutError() {
        println("connection timeout")
    }
    
    private class func handleObjectNotFoundError() {
        println("No Object Found")
    }
    
    private class func handleConnectionFailedError() {
        println("failed to connect to Parse")
    }
    
    private class func handleCasheMissError() {
        println("Missing Cache")
    }
}