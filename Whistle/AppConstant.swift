//
//  AppConstant.swift
//  Whistle
//
//  Created by Yetian Mao on 6/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//
//----------------------------------------------------------------------------------------------------------
import Foundation
//----------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------
struct Constants {
    //----------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    static let DefaultFont                      : String  = "Helvetica-Light"
    static let DefaultContentFont               : String  = "HelveticaNeue-Light"
    //------------------------------------------------------------------------------------------------------
    struct Favor {
        static let DefaultMileRange             : Double = 5
        static let MapPaginationLimit           : Int    = 10
        static let TablePaginationLimit         : Int    = 5
        static let Name                         : String = "Favor"
        static let Content                      : String = "content"
        static let Tag                          : String = "tags"
        static let Location                     : String = "location"
        static let Address                      : String = "address"
        static let Audio                        : String = "audio"
        static let Image                        : String = "image"
        static let Status                       : String = "status" 
        static let PlaceHolder                  : String = "Need a favor? Whistle for help!"
        static let Reward                       : String = "reward"
        static let Price                        : String = "price"
        static let Takers                       : String = "interested_users"
        static let CreatedBy                    : String = "user"
        static let AssistedBy                   : String = "assistedBy"
        static let Distance                     : String = "distance"
        static let UpdatedAt                    : String = "updatedAt"
        static let CreatedAt                    : String = "createdAt"
    }
    //------------------------------------------------------------------------------------------------------
    struct User {
        static let Name                         : String = "User"
        static let Id                           : String = "userId"
        static let Email                        : String = "email"
        static let EmailVerified                : String = "emailVerified"
        static let Phone                        : String = "phone"
        static let PhoneVerified                : String = "phoneVerified"
        static let TwitterId                    : String = "twitterId"
        static let FacebookId                   : String = "facebookId"
        static let ObjectId                     : String = "objectId"
        static let Nickname                     : String = "nickname"
        static let NicknameLower                : String = "nickname_lower"
        static let Portrait                     : String = "portrait"
        static let Thumbnail                    : String = "thumbnail"
        static let Gender                       : String = "gender"
        static let Region                       : String = "region"
        static let Birth                        : String = "birth"
        static let Status                       : String = "status"
        static let Likes                        : String = "likes"
        static let Dislikes                     : String = "dislikes"
        static let Rating                       : String = "rating"
        static let Rates                        : String = "rates"
        static let Favors                       : String = "favors"
        static let Assists                      : String = "assists"
        static let Level                        : String = "level"
        static let UpdatedAt                    : String = "updatedAt"
        static let CreatedAt                    : String = "createdAt"
        static let DefaultImage                 : UIImage = UIImage(named: "default_user_photo")!
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct People {
        static let Name                         : String = "People"
        static let User1                        : String = "user1"
        static let User2                        : String = "user2"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct UserReviewPivotTable {
        static let Name                         : String = "UserReviewPivotTable"
        static let ObjectId                     : String = "objectId"
        static let From                         : String = "from"
        static let To                           : String = "to"
        static let Because                      : String = "because"
        static let Comment                      : String = "comment"
        static let Rating                       : String = "rating"
        static let UpdatedAt                    : String = "updatedAt"
        static let CreatedAt                    : String = "createdAt"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct UserReportPivotTable {
        static let Name                         : String = "UserReportPivotTable"
        static let ObjectId                     : String = "objectId"
        static let From                         : String = "from"
        static let To                           : String = "to"
        static let Because                      : String = "because"
        static let Reason                       : String = "reason"
        static let UpdatedAt                    : String = "updatedAt"
        static let CreatedAt                    : String = "createdAt"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct FavorUserPivotTable {
        static let Name                         : String = "FavorUserPivotTable"
        static let Favor                        : String = "favor"
        static let Takers                       : String = "takers"
        static let Price                        : String = "price"
        static let Active                       : String = "active"
        static let UpdatedAt                    : String = "updatedAt"
        static let CreatedAt                    : String = "createdAt"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct UserRequestPivotTable {
        static let Name                         : String = "UserRequestPivotTable"
        static let From                         : String = "from"
        static let To                           : String = "to"
        static let Message                      : String = "message"
        static let Status                       : String = "status"         // 0 is valid, 1 is rejected, 2 is accepted
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct Image {
        static let Name                         : String = "Image"
        static let File                         : String = "file"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct Recent {
        static let Name                         : String = "Recent"
        static let User                         : String = "user"
        static let GroupId                      : String = "groupId"
        static let Members                      : String = "members"
        static let Description                  : String = "description"
        static let LastUser                     : String = "lastUser"
        static let LastMessage                  : String = "lastMessage"
        static let Counter                      : String = "counter"
        static let UpdatedAction                : String = "updatedAction"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct Region {
        static let Name                         : String = "Region"
        static let City                         : String = "city"
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct Color
    //------------------------------------------------------------------------------------------------------
    {
        //--------------------------------------------------------------------------------------------------
        // Global
        //--------------------------------------------------------------------------------------------------
        static let Main                         : UIColor = UIColor(red:0.02, green:0.67, blue:0.67, alpha:1)
        static let Background                   : UIColor = UIColor(red:0.32, green:0.34, blue:0.39, alpha:1)
        static let ContentBackground            : UIColor = UIColor(red:0.45, green:0.51, blue:0.56, alpha:1)
        static let Shadow                       : UIColor = UIColor(red:0.75, green:0.73, blue:0.71, alpha:1)
        static let TextLight                    : UIColor = UIColor(red:1, green:0.97, blue:0.93, alpha:1)
        static let PlaceHolder                  : UIColor = UIColor(red:0.75, green:0.73, blue:0.71, alpha:1)
        static let Border                       : UIColor = UIColor(red:1, green:0.97, blue:0.93, alpha:1)
        static let Banner                       : UIColor = UIColor(red:0.58, green:0.76, blue:0.81, alpha:1)
        //--------------------------------------------------------------------------------------------------
        // Navigation Bar
        //--------------------------------------------------------------------------------------------------
        static let NavigationBar                : UIColor = Constants.Color.Main
        static let NavigationBarTint            : UIColor = UIColor.whiteColor()
        //--------------------------------------------------------------------------------------------------
        // Table
        //--------------------------------------------------------------------------------------------------
        static let TableBackground              : UIColor = Constants.Color.Background
        static let CellBackground               : UIColor = Constants.Color.Background
        static let CellText                     : UIColor = Constants.Color.TextLight
        static let CellTextReverse              : UIColor = Constants.Color.Background
        static let CellTextShadow               : UIColor = Constants.Color.Shadow
        static let CellPlaceHolder              : UIColor = Constants.Color.PlaceHolder
        //--------------------------------------------------------------------------------------------------
    }

    
    //------------------------------------------------------------------------------------------------------
    struct PlaceHolder
    //----------------------------------------------------------------------------------------------------------
    {
        static let NewFavor                     : String = "Please enter your favor..."
        static let NewReward                    : String = "Please enter your reward..."
        static let NewStatus                    : String = "Please enter your status..."
        static let NewReport                    : String = "Please enter report details..."
    }
    
    //----------------------------------------------------------------------------------------------------------
    struct Limit {
        static let Name                         : Int = 16
        static let Favor                        : Int = 300
        static let Reward                       : Int = 300
        static let Status                       : Int = 100
        static let Report                       : Int = 500
        static let Rate                         : Int = 150
    }
    
    //------------------------------------------------------------------------------------------------------
    struct Radius {
        static let CornerBig                    : CGFloat = 12
        static let BorderWidthMid               : CGFloat = 3
    }
    //------------------------------------------------------------------------------------------------------
    
    //------------------------------------------------------------------------------------------------------
    struct Notification {
        static let SetProfileView               : String = "loadSetProfileView"
        static let UserLoggedOut                : String = "UserLoggedOut"
    }
    //------------------------------------------------------------------------------------------------------
}

