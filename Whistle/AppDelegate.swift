//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse
import Firebase

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var coordinate: CLLocationCoordinate2D!
    var posted: Bool = false
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set Status Style
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // set Navigation bar style
        UINavigationBar.appearance().barTintColor = Constants.Color.NavigationBar
        UINavigationBar.appearance().tintColor = Constants.Color.NavigationBarTint
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Constants.Color.NavigationBarTint, NSFontAttributeName: UIFont(name: "Arial", size: 21.5)!]
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AbrahamLincoln", size: 20)!], forState: UIControlState.Normal)
        
        
        Firebase.defaultConfig().persistenceEnabled = true
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        //Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        // Parse.setApplicationId("MHrxkvFSQ1xvMYKqFQPNNH9Z24AnvnGP1kF7HWjF",
        //            clientKey: "8Q3nFWXrVK6RYbvaaYi2BPV4R2tC2hlgxsMEFYi1")
        Parse.setApplicationId("mdn4JJVIMiBzPSnljttOhPjghYeUCifvI6LAc2XW",
            clientKey: "hd8kSjDEnHlVEyQxCuv4f4VOYugdUSZYNKgL5oAe")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFTwitterUtils.initializeWithConsumerKey("cQAFPzeIRWcCtBED3Lt7Yemhu",
            consumerSecret:"2ILmbqrY6VmU3IacjqFERGoKZt7DGXiZepQhHLeC0bQemhjxuv")
        // ****************************************************************************
        
        // PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        defaultACL.setPublicWriteAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Active {
            println("active")
        } else {
            if userInfo["type"] as! String == "chat" {
//                let tabBarController = self.window?.rootViewController as! TabBarController
//                let nav = tabBarController.selectedViewController as! UINavigationController
//                let groupId = userInfo["groupId"] as! String
//                let chatView = ChatView(with: groupId)
//                nav.pushViewController(chatView, animated: true)
            }
        }
        //PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        let installation = PFInstallation.currentInstallation()
        if installation.badge != 0 {
            installation.badge = 0
        }
        installation.saveInBackground()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        locationManagerStart()
        FBSDKAppEvents.activateApp()
    }
    
    //MARK: Location manager methods
    
    func locationManagerStart() {
        if self.locationManager == nil
        {
            locationManager                                                     = CLLocationManager()
            locationManager.delegate                                            = self
            locationManager.desiredAccuracy                                     = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            println("enable location service")
            ProgressHUD.showError("Please enable location service in the setting to start use our App")
        }
    }
    
    func locationManagerStop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.coordinate = newLocation.coordinate
        if !posted
        {
            NSNotificationCenter.defaultCenter().postNotificationName("currentLocationFound", object: nil)
            posted = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("location manager error")
    }
    
}


