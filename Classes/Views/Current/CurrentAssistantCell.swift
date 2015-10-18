//
//  CurrentAssistantCell.swift
//  Whistle
//
//  Created by Lu Cao on 7/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class CurrentAssistantCell: UITableViewCell
    
//----------------------------------------------------------------------------------------------------------
{
    
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var portraitView                         : WEImageView!
    @IBOutlet weak var nameLabel                            : UILabel!
    @IBOutlet weak var bannerView                           : UIView!
    @IBOutlet weak var wrapper                              : UIView!
    @IBOutlet weak var genderImage                          : UIImageView!
    @IBOutlet weak var distanceLabel                        : UILabel!
    @IBOutlet weak var priceLabel                           : UILabel!
    @IBOutlet weak var lineLabel                            : UILabel!
    @IBOutlet weak var hireButton                           : UIButton!
    //----------------------------------------------------------------------------------------------------------
    private var favor                                       : PFObject!
    //----------------------------------------------------------------------------------------------------------
    
    // MARK: - Initialization
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
        
        portraitView.layer.borderWidth                      = 3
        portraitView.layer.borderColor                      = Constants.Color.Border.CGColor
        portraitView.layer.cornerRadius                     = portraitView.layer.frame.height/2
        
        bannerView.backgroundColor                          = Constants.Color.Banner
        bannerView.layer.cornerRadius                       = 12
        wrapper.backgroundColor                             = Constants.Color.ContentBackground
        
//        hireButton.layer.cornerRadius                       = 20
//        hireButton.layer.borderColor                        = Constants.Color.Border.CGColor
//        hireButton.layer.borderWidth                        = 0.3
//        hireButton.setTitleColor(Constants.Color.TextLight, forState: .Normal)
    }
    
    func bindData(user: PFUser?, favor: PFObject){
        if let user = user {
            self.portraitView.user = user
            self.favor = favor
            user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
                if let user = user {
                    var file = user[Constants.User.Portrait] as! PFFile
                    file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            self.portraitView.image = UIImage(data: data!)!
                        }
                    })
                    self.nameLabel.text = user[Constants.User.Nickname] as? String
                    self.lineLabel.text = user[Constants.User.Status] as? String
                    let likes = user[Constants.User.Likes] as? Double
                    let favors = user[Constants.User.Favors] as? Double
                    let percentage = (likes!/favors!).roundTo1
                    //            self.ratingLabel.text = "\(Int(likes!)) (\(percentage)))"
                } else {
                    ParseErrorHandler.handleParseError(error)
                }
            })

            if let address = favor[Constants.Favor.Address] as? String {
                PFGeoPoint.geoPointForCurrentLocationInBackground({ (location, error) -> Void in
                    if error == nil {
                        let location2 = favor[Constants.Favor.Location] as? PFGeoPoint
                        let distance : Double = location!.distanceInMilesTo(location2)
                        self.distanceLabel.text = "\(distance.roundTo1) miles"
                    }
                })
            }
            if let price = favor[Constants.Favor.Price] as? Int {
                let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                query.whereKey(Constants.FavorUserPivotTable.Takers, equalTo: user)
                query.whereKey(Constants.FavorUserPivotTable.Favor, equalTo: favor)
                query.whereKey(Constants.FavorUserPivotTable.Active, equalTo: true)
                query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if let object = object {
                            if let bidPrice = object[Constants.FavorUserPivotTable.Price] as? Int {
                                self.priceLabel.text = "\(bidPrice)"
                            } else {
                                self.priceLabel.text = "\(price)"
                            }
                        }
                    }
                })
            }
        } else {
            println("no user loaded")
        }
    }
}
