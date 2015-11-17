//
//  MessageHandler.swift
//  Whistle
//
//  Created by Yetian Mao on 10/20/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

enum MessageName : String {
    case SelectFavorFirst = "Please select a favor first."
    case CannotSelectOwn = "You can not pick your own favor"
    case NoLocation = "You need to add a location"
    case NoAudioOrText = "Need to fill either audio or text to describe the favor."
    case Interested = "Successfully interested the favor."
    case FavorPosted = "Favor posted successfully."
    case NoCamera = "This Device has no camera. Opening Photo Library Instead"
    case CameraAccess = "Whistle needs access to the camera roll."
    case Hired = "Assistant hired successfully."
    case Reported = "Your report has been posted"
    case Reviewed = "Your review has been posted"
    case Confirmed = ""
    case HaveReported = "You have already reported this user"
    case HaveReviewed = "You have already reviewed this user"
    case NeedReason = "Please specify your reason"
    case NeedRate = "Please specify your rate"
    case Blocked = "Successfully blocked"
    case Favor0 = "Waiting for assistants"
    case Favor1 = "Choose an assistant"
    case Favor2 = "I was assisted!"
    case Favor4 = "Favor is Complete"
    case Favor5 = "Favor is Cancelled"
    case CurrentInterest = "I want to assist!"
    case Assist = "Assist!"
    case AssistantHire = "Choose this assistant"
    case CancelFavor = "Confirm to cancel this favor?"
    case AcceptAssist = "Confirm assistance received?"
    case Assisted = "Assistance Complete"
    case AssistCancel = "Assistance Denied"
    case ReviewTextHeader = "Please leave a review"
    case ReportTextHeader = "Please pick your reason"
    case ReportReason1 = "Payment Incomplete"
    case ReportReason2 = "Illegal item involved"
    case ReportReason3 = "Assistance has not been received"
    case ReportReason4 = "Personal harassment"
    case ReportReason5 = "Possible Scam"
    case ReportReason6 = "Violent content"
    
}


class MessageHandler {
    
    class func message(title: String, subtitle: String, vc: UIViewController? = UIApplication.rootViewController(), callback: (Void)->Void) {
        TSMessage.setDefaultViewController(vc)
        TSMessage.showNotificationInViewController(
            vc, title: title, subtitle: subtitle,
            image: nil, type: TSMessageNotificationType.Message, duration: 2,
            callback: callback, buttonTitle: nil,
            buttonCallback: nil, atPosition: TSMessageNotificationPosition.NavBarOverlay,
            canBeDismissedByUser: true
        )
    }
    
    class func message(name: MessageName, vc: UIViewController? = UIApplication.rootViewController() ) {
        TSMessage.setDefaultViewController(vc)
        switch (name) {
        case MessageName.SelectFavorFirst:
            showMessage("Warning", subtitle: name.rawValue, type: .Warning)
        case MessageName.CannotSelectOwn:
            showMessage("Warning", subtitle: name.rawValue, type: .Warning)
        case MessageName.Interested:
            showMessage("Success", subtitle: name.rawValue, type: .Success)
        case MessageName.NoLocation:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.NoAudioOrText:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.FavorPosted:
            showMessage("Success", subtitle: name.rawValue, type: .Success, vc: vc)
        case MessageName.NoCamera:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.CameraAccess:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.Hired:
            showMessage("Success", subtitle: name.rawValue, type: .Success)
        case MessageName.Reported:
            showMessage("Success", subtitle: name.rawValue, type: .Success)
        case MessageName.Reviewed:
            showMessage("Success", subtitle: name.rawValue, type: .Success)
        case MessageName.HaveReported:
            showMessage("Error", subtitle: name.rawValue, type: .Error)
        case MessageName.HaveReviewed:
            showMessage("Error", subtitle: name.rawValue, type: .Error)
        case MessageName.NeedReason:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.NeedRate:
            showMessage("Error", subtitle: name.rawValue, type: .Error, vc: vc)
        case MessageName.Blocked:
            showMessage("Success", subtitle: name.rawValue, type: .Success, vc: vc)
        default:
            break
        }
        
    }
    
    private class func showMessage(title: String, subtitle: String, type: TSMessageNotificationType)
    {
        TSMessage.showNotificationWithTitle(title, subtitle: subtitle, type: type)
    }
    
    private class func showMessage(title: String, subtitle: String, type: TSMessageNotificationType, vc: UIViewController?)
    {
        TSMessage.showNotificationInViewController(
            vc, title: title, subtitle: subtitle,
            image: nil, type: type, duration: 2,
            callback: nil, buttonTitle: nil,
            buttonCallback: nil, atPosition: .NavBarOverlay,
            canBeDismissedByUser: true
        )
    }
    
    
}
