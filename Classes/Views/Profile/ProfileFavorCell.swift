//
//  ProfileFavorCell.swift
//  Whistle
//
//  Created by Lu Cao on 6/28/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------
class ProfileFavorCell: UITableViewCell
//----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var line                                 : UIView!
    @IBOutlet weak var dotBottom                            : UIView!
    @IBOutlet weak var portrait                             : WEImageView!
    @IBOutlet weak var dateLabel                            : UILabel!
    @IBOutlet weak var nameWhistledLabel                    : UILabel!
    @IBOutlet weak var nameAssistedLabel                    : UILabel!
    @IBOutlet weak var priceRightLabel                      : UILabel!
    @IBOutlet weak var priceLeftLabel                       : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Constraints
    //----------------------------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------------------------
    var vc                                                  : ProfileFavorsTable!
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func awakeFromNib()
    //----------------------------------------------------------------------------------------------------------
    {
        super.awakeFromNib()
        configLooks()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func prepareForReuse()
    //----------------------------------------------------------------------------------------------------------
    {
        dateLabel.text = ""
        nameWhistledLabel.text = ""
        nameAssistedLabel.text = ""
        priceLeftLabel.text = ""
        priceRightLabel.text = ""
        dotBottom.hidden = true
        portrait.hidden = false
        line.hidden = false
    }
    
    
    // MARK: - Functions
    //----------------------------------------------------------------------------------------------------------
    func configLooks()
    //----------------------------------------------------------------------------------------------------------
    {
        backgroundColor                                     = UIColor.clearColor()
        
        line.backgroundColor                                = Constants.Color.Border
        dotBottom.backgroundColor                           = Constants.Color.Border
        dotBottom.layer.cornerRadius                        = 7.5
        
        portrait.layer.borderColor                          = Constants.Color.Border.CGColor
        portrait.layer.borderWidth                          = 2
        portrait.layer.cornerRadius                         = 40
        portrait.backgroundColor                            = Constants.Color.Border
        
        dateLabel.textColor                                 = Constants.Color.CellTextReverse
        dateLabel.backgroundColor                           = Constants.Color.CellText
        dateLabel.layer.cornerRadius                        = 7.5
        nameWhistledLabel.textColor                         = Constants.Color.CellText
        nameAssistedLabel.textColor                         = Constants.Color.CellText
    }
    
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor: PFObject, previousFavor: PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        var user = PFUser.currentUser()!
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd"
        self.dateLabel.text = "  \(formatter.stringFromDate(favor.updatedAt!))  "
        if previousFavor != nil {
            if self.dateLabel.text == "  \(formatter.stringFromDate(previousFavor!.updatedAt!))  " {
                self.dateLabel.text = ""
            }
        }
        
        let whislter = favor[Constants.Favor.CreatedBy] as! PFUser
        whislter.fetchIfNeededInBackgroundWithBlock({ (whislter, error) -> Void in
            if let whislter = whislter as? PFUser
            {
                if whislter.objectId == user.objectId
                { // Spent
                    let assistant = favor[Constants.Favor.AssistedBy] as! PFUser
                    assistant.fetchIfNeededInBackgroundWithBlock({ (assistant, error) -> Void in
                        if let assistant = assistant as? PFUser
                        {
                            self.portrait.user = assistant
                            var file = assistant[Constants.User.Portrait] as! PFFile
                            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                if let data = data {
                                    self.portrait.image = UIImage(data: data)!
                                    self.nameWhistledLabel.text = assistant[Constants.User.Nickname] as? String
                                    self.priceRightLabel.text = "Spent $\(favor[Constants.Favor.Price] as! Int)"
                                    self.vc.totalSpent += favor[Constants.Favor.Price] as! Int
                                }
                            })
                        }
                    })
                } else { // Earn
                    self.portrait.user = whislter
                    var file = whislter[Constants.User.Portrait] as! PFFile
                    file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if let data = data {
                            self.portrait.image = UIImage(data: data)!
                            self.nameAssistedLabel.text = whislter[Constants.User.Nickname] as? String
                            self.priceLeftLabel.text = "$\(favor[Constants.Favor.Price] as! Int) Earned"
                            self.vc.totalEarned += favor[Constants.Favor.Price] as! Int
                        }
                    })
                }
            }
        })
    }
    
}
