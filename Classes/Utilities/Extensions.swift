//
//  Extensions.swift
//  Whistle
//
//  Created by Yetian Mao on 8/16/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation
import MapKit
import Parse


extension String {
    var isEmail: Bool {
        let regex = NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        //        if let swipe = base as? CurrentView {
        //            return swipe.tabSwipeNavigation(swipe.tabSwipe, viewControllerAtIndex: swipe.tabSwipe.currentTabIndex)
        //        }
        return base
    }
}

typealias Edges = (ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D)

extension MKMapView {
    func edgePoints() -> Edges {
        let nePoint = CGPoint(x: self.bounds.maxX, y: self.bounds.origin.y)
        let swPoint = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let neCoord = self.convertPoint(nePoint, toCoordinateFromView: self)
        let swCoord = self.convertPoint(swPoint, toCoordinateFromView: self)
        return (ne: neCoord, sw: swCoord)
    }
}

extension Double {
    var roundTo1:Double {
        let converter = NSNumberFormatter()
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.NoStyle
        formatter.minimumFractionDigits = 1
        formatter.roundingMode = .RoundUp
        formatter.maximumFractionDigits = 1
        if let stringFromDouble =  formatter.stringFromNumber(self) {
            if let doubleFromString = converter.numberFromString( stringFromDouble ) as? Double {
                return doubleFromString
            }
        }
        return 0
    }
}

extension NSDate {
    func yearsFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: date, toDate: self, options: nil).year
    }
    func monthsFrom(date:NSDate)  -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitMonth, fromDate: date, toDate: self, options: nil).month
    }
    func weeksFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitWeekOfYear, fromDate: date, toDate: self, options: nil).weekOfYear
    }
    func daysFrom(date:NSDate)    -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: date, toDate: self, options: nil).day
    }
    func hoursFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
    func minutesFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitMinute, fromDate: date, toDate: self, options: nil).minute
    }
    func secondsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitSecond, fromDate: date, toDate: self, options: nil).second
    }
    var relativeTime: String {
        let now = NSDate()
        if now.yearsFrom(self)   > 0 {
            return now.yearsFrom(self).description  + " year"  + { return now.yearsFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.monthsFrom(self)  > 0 {
            return now.monthsFrom(self).description + " month" + { return now.monthsFrom(self)  > 1 ? "s" : "" }() + " ago"
        }
        if now.weeksFrom(self)   > 0 {
            return now.weeksFrom(self).description  + " week"  + { return now.weeksFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.daysFrom(self)    > 0 {
            if daysFrom(self) == 1 { return "Yesterday" }
            return now.daysFrom(self).description + " days ago"
        }
        if now.hoursFrom(self)   > 0 {
            return "\(now.hoursFrom(self)) hour" + { return now.hoursFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.minutesFrom(self) > 0 {
            return "\(now.minutesFrom(self)) minute" + { return now.minutesFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        if now.secondsFrom(self) > 0 {
            if now.secondsFrom(self) < 15 { return "Just now"  }
            return "\(now.secondsFrom(self)) second" + { return now.secondsFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        return ""
    }
}

/**
rounded corner for only certain sides of the frame
*/
extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

extension UIImage {
    
    var rounded: UIImage {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = size.height < size.width ? size.height/2 : size.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0) }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5) }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0) }
    
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}

//extension NSMutableArray {
//    func sortByCreatedAt(order: Order) {
//        var sortedArray = sorted(mainFavors) {
//            (obj1, obj2) in
//            let p1 = obj1 as! PFObject
//            let p2 = obj2 as! PFObject
//            switch order {
//            case .Ascending:
//                return (p1.updatedAt!.compare(p2.updatedAt!) == NSComparisonResult.OrderedAscending)
//            case .Descending:
//                return (p1.updatedAt!.compare(p2.updatedAt!) == NSComparisonResult.OrderedDescending)
//            }
//        }
//        self.removeAllObjects()
//        self.addObjectsFromArray(sortedArray)
//    }
//    
//    func sortByPrice(order: Order) {
//        var sortedArray = sorted(mainFavors) {
//            (obj1, obj2) in
//            let p1 = obj1 as! PFObject
//            let p2 = obj2 as! PFObject
//            let price1 = p1[Constants.Favor.Price] as? Double
//            let price2 = p2[Constants.Favor.Price] as? Double
//            switch order {
//            case .Ascending:
//                return (price1 > price2)
//            case .Descending:
//                return (price1 < price2)
//            }
//        }
//        self.removeAllObjects()
//        self.addObjectsFromArray(sortedArray)
//    }
//    
//    func sortByDistance(order: Order) {
//        var sortedArray = sorted(mainFavors) {
//            (obj1, obj2) in
//            let p1 = obj1 as! PFObject
//            let p2 = obj2 as! PFObject
//            let item1 = p1[Constants.Favor.Distance] as? Double
//            let item2 = p2[Constants.Favor.Distance] as? Double
//            switch order {
//            case .Ascending:
//                return (item1 > item2)
//            case .Descending:
//                return (item1 < item2)
//            }
//        }
//        self.removeAllObjects()
//        self.addObjectsFromArray(sortedArray)
//    }
//    
//    func filterByGender(gender: Int) -> NSMutableArray {
//        var filteredArray = NSMutableArray()
//        for index in 0...skip - 1 {
//            let object = self[index] as! PFObject
//            if let user = object[Constants.Favor.CreatedBy] as? PFUser {
//                if let genderr = user[Constants.User.Gender] as? Int {
//                    if genderr == gender {
//                        filteredArray.addObject(object)
//                    }
//                }
//            }
//        }
//        return filteredArray
//    }
//}