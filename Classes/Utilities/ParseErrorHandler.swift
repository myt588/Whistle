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
    
    private class func handleInvalidSessionTokenError() {
        println("invalid session token error")
            //--------------------------------------
            // Option 1: Show a message asking the user to log out and log back in.
            //--------------------------------------
            // If the user needs to finish what they were doing, they have the opportunity to do so.
            //
            // let alertView = UIAlertView(
            //   title: "Invalid Session",
            //   message: "Session is no longer valid, please log out and log in again.",
            //   delegate: nil,
            //   cancelButtonTitle: "Not Now",
            //   otherButtonTitles: "OK"
            // )
            // alertView.show()
            
            //--------------------------------------
            // Option #2: Show login screen so user can re-authenticate.
            //--------------------------------------
            // You may want this if the logout button is inaccessible in the UI.
            //
            // let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
            // let logInViewController = PFLogInViewController()
            // presentingViewController?.presentViewController(logInViewController, animated: true, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginView
        let rootViewController = UIApplication.rootViewController()
        rootViewController!.presentViewController(viewController, animated: true, completion: nil)
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