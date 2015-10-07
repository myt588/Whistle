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
        if let error = error {
            if error.domain != PFParseErrorDomain {
                return
            }
            println(error.code)
            switch (error.code) {
            case PFErrorCode.ErrorInvalidSessionToken.rawValue:
                handleInvalidSessionTokenError()
            case PFErrorCode.ErrorTimeout.rawValue:
                handleTimeOutError()
            case PFErrorCode.ErrorObjectNotFound.rawValue:
                handleObjectNotFoundError()
            case PFErrorCode.ErrorConnectionFailed.rawValue:
                handleConnectionFailedError()
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
    }
    
    private class func handleTimeOutError() {
        println("connection timeout")
        ProgressHUD.showError("Connection Timeout, Please try again")
    }
    
    private class func handleObjectNotFoundError() {
        println("No Object Found")
    }
    
    private class func handleConnectionFailedError() {
        println("failed to connect to Parse")
        ProgressHUD.showError("Network Failed")
    }
}