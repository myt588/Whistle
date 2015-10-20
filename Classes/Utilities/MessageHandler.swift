//
//  MessageHandler.swift
//  Whistle
//
//  Created by Yetian Mao on 10/20/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

enum MessageName {
    case SelectFavorFirst
    case CannotSelectOwn
    case Interested
    case NoLocation
    case NoAudioOrText
    case FavorPosted
    case NoCamera
    case CameraAccess
    case Hired
    case Reported
    case Reviewed
    case Confirmed
    case HaveReported
    case HaveReviewed
    case NeedReason
    case NeedRate
}

class MessageHandler {
    
    class func message(name: MessageName, vc: UIViewController? = UIApplication.rootViewController() ) {
        TSMessage.setDefaultViewController(vc)
        switch (name) {
        case MessageName.SelectFavorFirst:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Please select a favor first.", type: .Warning)
        case MessageName.CannotSelectOwn:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "You can not pick your own favor", type: .Warning)
        case MessageName.Interested:
            TSMessage.showNotificationWithTitle("Interested", subtitle: "Successfully interested the favor.", type: .Success)
        case MessageName.NoLocation:
            showMessage(vc, title: "No Location", subtitle: "You need to add a location", type: .Error)
        case MessageName.NoAudioOrText:
            showMessage(vc, title: "Need Data", subtitle: "Need to fill either audio or text to describe the favor.", type: .Error)
        case MessageName.FavorPosted:
            showMessage(vc, title: "Success", subtitle: "Favor posted successfully.", type: .Success)
        case MessageName.NoCamera:
            showMessage(vc, title: "No Camera", subtitle: "This Device has no camera. Opening Photo Library Instead", type: .Error)
        case MessageName.CameraAccess:
            showMessage(vc, title: "An error occurred", subtitle: "Whistle needs access to the camera roll.", type: .Error)
        case MessageName.Hired:
            TSMessage.showNotificationWithTitle("Success", subtitle: "Assistant hired successfully.", type: .Success)
        case MessageName.Reported:
            TSMessage.showNotificationWithTitle("Reported", subtitle: "Your report has been posted", type: .Success)
        case MessageName.Reviewed:
            TSMessage.showNotificationWithTitle("Reviewed", subtitle: "Your review has been posted", type: .Success)
        case MessageName.HaveReported:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "You have already reported this user", type: .Error)
        case MessageName.HaveReviewed:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "You have already reviewed this user", type: .Error)
        case MessageName.NeedReason:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Please specify your reason", type: .Error)
        case MessageName.NeedRate:
            TSMessage.showNotificationWithTitle("Warning", subtitle: "Please specify your rate", type: .Error)
        default:
            break
        }
    }
    
    class func showMessage(vc: UIViewController?, title: String, subtitle: String, type: TSMessageNotificationType)
    {
        TSMessage.showNotificationInViewController(vc, title: title, subtitle: subtitle, image: nil, type: .Error, duration: 2, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
    }
}
