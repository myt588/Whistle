//
//  FavorDetailTable.swift
//  Whistle
//
//  Created by Lu Cao on 6/24/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------
import UIKit
import Parse
//----------------------------------------------------------------------------------------------------------

protocol FavorDetailScrollDelegate {
    func expand()
    func shrink()
}

//----------------------------------------------------------------------------------------------------------
class FavorDetailTable: UITableViewController, UIScrollViewDelegate
    //----------------------------------------------------------------------------------------------------------
{
    // MARK: - IBOutlets
    
    //----------------------------------------------------------------------------------------------------------
    // Price
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var priceIcon                                    : UIImageView!
    @IBOutlet weak var priceLine                                    : UIView!
    @IBOutlet weak var priceHeader                                  : UILabel!
    @IBOutlet weak var dollarLabel                                  : UILabel!
    @IBOutlet weak var priceLabel                                   : UILabel!
    @IBOutlet weak var plus1Button                                  : UIButton!
    @IBOutlet weak var plus5Button                                  : UIButton!
    @IBOutlet weak var plus10Button                                 : UIButton!
    @IBOutlet weak var clearButton                                  : UIButton!
    @IBOutlet weak var signButton                                   : UIButton!
    //----------------------------------------------------------------------------------------------------------
    // Rewards
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var rewardIcon                                   : UIImageView!
    @IBOutlet weak var rewardLine                                   : UIView!
    @IBOutlet weak var rewardHeader                                 : UILabel!
    @IBOutlet weak var rewardLabel                                  : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Favor
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var favorIcon                                    : UIImageView!
    @IBOutlet weak var favorLine                                    : UIView!
    @IBOutlet weak var favorHeader                                  : UILabel!
    @IBOutlet weak var favorLabel                                   : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Address
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var addressIcon                                  : UIImageView!
    @IBOutlet weak var addressLine                                  : UIView!
    @IBOutlet weak var locationHeader                               : UILabel!
    @IBOutlet weak var addressLabel                                 : UILabel!
    @IBOutlet weak var distanceLabel                                : UILabel!
    //----------------------------------------------------------------------------------------------------------
    // Images
    //----------------------------------------------------------------------------------------------------------
    @IBOutlet weak var imagesIcon                                   : UIImageView!
    @IBOutlet weak var imagesLine                                   : UIView!
    @IBOutlet weak var photosHeader                                 : UILabel!
    @IBOutlet weak var image0                                       : UIImageView!
    @IBOutlet weak var image1                                       : UIImageView!
    @IBOutlet weak var image2                                       : UIImageView!
    @IBOutlet weak var image3                                       : UIImageView!
    @IBOutlet weak var image4                                       : UIImageView!
    @IBOutlet weak var image5                                       : UIImageView!
    @IBOutlet weak var image6                                       : UIImageView!
    @IBOutlet weak var image7                                       : UIImageView!
    @IBOutlet weak var image8                                       : UIImageView!
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Variables
    
    //----------------------------------------------------------------------------------------------------------
    // Parse
    //----------------------------------------------------------------------------------------------------------
    var favor                                                       : PFObject!
    //----------------------------------------------------------------------------------------------------------
    var willAdd                                                     : Bool = true
    //----------------------------------------------------------------------------------------------------------
    // Images
    //----------------------------------------------------------------------------------------------------------
    var images                                                      = [UIImage]()
    var imageViews                                                  = [UIImageView]()
    var imageViewHeight                                             : CGFloat = 100
    //----------------------------------------------------------------------------------------------------------
    //Control
    //----------------------------------------------------------------------------------------------------------
    var noContent                                                   : Bool = false
    var noReward                                                    : Bool = false
    var noImage                                                     : Bool = false
    
    var pointNow : CGPoint?
    var delegate : FavorDetailScrollDelegate?
    
    // MARK: - Initializations
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLoad()
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidLoad()
        addGestures()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidAppear(animated: Bool)
    //----------------------------------------------------------------------------------------------------------
    {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews()
    //----------------------------------------------------------------------------------------------------------
    {
        configShape()
    }
    
    
    // MARK: - IBActions
    @IBAction func addOrSub(sender: UIButton) {
        bounceView(sender)
        if sender.titleLabel!.text == "-" {
            sender.setTitle("+", forState: .Normal)
            willAdd = true
        } else {
            sender.setTitle("-", forState: .Normal)
            willAdd = false
        }
        
    }
    //----------------------------------------------------------------------------------------------------------
    @IBAction func modifyPrice(sender: UIButton)
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.bringSubviewToFront(sender)
        bounceView(sender)
        bounceView(priceLabel)
        if willAdd {
            switch sender.titleLabel!.text! {
            case "C":
                let price = favor[Constants.Favor.Price] as! Int
                priceLabel.text = "\(price)"
            case "10":
                priceLabel.text = "\(priceLabel.text!.toInt()! + 10)"
            case "5":
                priceLabel.text = "\(priceLabel.text!.toInt()! + 5)"
            case "1":
                priceLabel.text = "\(priceLabel.text!.toInt()! + 1)"
            default:
                return
            }
        } else {
            switch sender.titleLabel!.text! {
            case "C":
                let price = favor[Constants.Favor.Price] as! Int
                priceLabel.text = "\(price)"
            case "10":
                priceLabel.text = "\(priceLabel.text!.toInt()! - 10)"
            case "5":
                priceLabel.text = "\(priceLabel.text!.toInt()! - 5)"
            case "1":
                priceLabel.text = "\(priceLabel.text!.toInt()! - 1)"
            default:
                return
            }
        }
        
    }
    
    
    // MARK: - User Interactions
    //----------------------------------------------------------------------------------------------------------
    func addGestures()
    //----------------------------------------------------------------------------------------------------------
    {
        imageViews = [image0, image1, image2, image3, image4, image5, image6, image7, image8]
        for element in imageViews {
            var tap = UITapGestureRecognizer(target: self, action: "respondToTapGesture:")
            element.addGestureRecognizer(tap)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    func respondToTapGesture(sender: UITapGestureRecognizer)
    //----------------------------------------------------------------------------------------------------------
    {
        var imageInfo = JTSImageInfo()
        imageInfo.image = image0.image!
        imageInfo.referenceRect = view.frame
        imageInfo.referenceView = view
        var imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        imageViewer.showFromViewController(self.parentViewController, transition: JTSImageViewControllerTransition._FromOriginalPosition)
    }
    
    
    // MARK: - Functionalities
    //----------------------------------------------------------------------------------------------------------
    func bindData(favor : PFObject?)
    //----------------------------------------------------------------------------------------------------------
    {
        println(index)
        if let favor = favor {
            self.favor = favor
            if let address = favor[Constants.Favor.Address] as? String {
                self.addressLabel.text = address
                let location = CurrentLocation()
                let location2 = favor[Constants.Favor.Location] as? PFGeoPoint
                let distance : Double = location.distanceInMilesTo(location2)
                self.distanceLabel.text = "\(distance.roundTo1) miles"
            }
            
            if let content = favor[Constants.Favor.Content] as? String {
                self.favorLabel.text = content
                self.noContent = false
            } else {
                self.noContent = true
            }
            
            if let reward = favor[Constants.Favor.Reward] as? String {
                self.rewardLabel.text = reward
                self.noReward = false
            } else {
                self.noReward = true
            }
            
            if let price = favor[Constants.Favor.Price] as? Int {
                // if bidId exists means user have interested on this before
                if let bidId = NSUserDefaults.standardUserDefaults().stringForKey(favor.objectId!) {
                    let query = PFQuery(className: Constants.FavorUserPivotTable.Name)
                    //query.fromLocalDatastore()
                    query.getObjectInBackgroundWithId(bidId, block: { (object, error) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            if let object = object {
                                if object[Constants.FavorUserPivotTable.Active] as! Bool {
                                    if let bidPrice = object[Constants.FavorUserPivotTable.Price] as? Int {
                                        //println("1")
                                        self.priceLabel.text = "\(bidPrice)"
                                    } else {
                                        //println("2")
                                        self.priceLabel.text = "\(price)"
                                    }
                                } else {
                                    //println("3")
                                    self.priceLabel.text = "\(price)"
                                }
                            }
                        }
                    })
                } else {
                    //println("4")
                    self.priceLabel.text = "\(price)"
                }
            }
            
            noImage = true
            images = [UIImage]()
            configImageViews()
            if let images = favor[Constants.Favor.Image] as? NSArray {
                noImage = false
                for image in images {
                    image.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            let imagee = UIImage(data: data!)
                            self.images.append(imagee!)
                            if self.images.count == images.count {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.configImageViews()
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
                }
            } else {
                self.noImage = true
                self.tableView.reloadData()
            }
        }
        tableView.setContentOffset(CGPointMake(0, -self.tableView.contentInset.top), animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func configShape()
    //----------------------------------------------------------------------------------------------------------
    {
        var buttonList = [plus1Button, plus5Button, plus10Button, clearButton]
        for element in buttonList {
            element.layer.borderColor                               = Constants.Color.Border.CGColor
            element.layer.borderWidth                               = 0.3
            element.layer.cornerRadius                              = element.layer.frame.height/2
            element.setTitleColor(Constants.Color.CellText, forState: .Normal)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    // Called when in display mode 2
    //----------------------------------------------------------------------------------------------------------
    func setTopMargin2()
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.contentInset                                      = UIEdgeInsetsMake(100, 0, YALTabBarViewDefaultHeight + 30, 0)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // Called when in display mode 1
    //----------------------------------------------------------------------------------------------------------
    func setTopMargin1()
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.contentInset                                      = UIEdgeInsetsMake(35, 0, YALTabBarViewDefaultHeight + 30, 0)
    }
    
    //----------------------------------------------------------------------------------------------------------
    func scrollToTop()
    //----------------------------------------------------------------------------------------------------------
    {
        tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------
    // START: - Images
    //----------------------------------------------------------------------------------------------------------
    func configImageViews()
    //----------------------------------------------------------------------------------------------------------
    {
        imageViews = [image0, image1, image2, image3, image4, image5, image6, image7, image8]
        for (index, element) in enumerate(imageViews) {
            element.layer.borderColor                               = Constants.Color.ContentBackground.CGColor
            element.layer.borderWidth                               = 1
            element.layer.cornerRadius                              = 8
            if index <= images.count-1 {
                element.hidden = false
                element.image = images[index]
            } else {
                element.hidden = true
            }
        }
    }
    //----------------------------------------------------------------------------------------------------------
    // END: - Images
    //----------------------------------------------------------------------------------------------------------
    
    
    // MARK: - Delegations
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    //----------------------------------------------------------------------------------------------------------
    {
        switch section {
        case 0:
            return 1
        case 1:
            return noReward ? 0 : 1
        case 2:
            return noContent ? 0 : 1
        case 3:
            return 1
        case 4:
            return noImage ? 0 : 1
        case 5:
            return noImage ? 1 : 0
        default:
            return 0
        }
    }
    
    //----------------------------------------------------------------------------------------------------------
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //----------------------------------------------------------------------------------------------------------
    {
        switch indexPath.section {
        case 0:                                                     // Price
            return 85
        case 1:                                                     // Reward
            return calculateHeightForString(rewardLabel.text!) + 85
        case 2:                                                     // Favor
            return calculateHeightForString(favorLabel.text!) + 85
        case 3:                                                     // Address
            return calculateHeightForString(addressLabel.text!) + 85
        case 4:                                                     // Images
            var rows: CGFloat?
            switch images.count {
            case 0:
                rows = 0
            case 1...3:
                rows = 1
            case 4...6:
                rows = 2
            case 7...9:
                rows = 3
            default:
                break
            }
            var imageViewsHeight = 30 + imageViewHeight * rows!
            return imageViewsHeight
        default:
            return 44
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if pointNow == nil { return }
        if scrollView.contentOffset.y > pointNow?.y {
            delegate?.expand()
        }
        pointNow = CGPointMake(0, 10000)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < -60) {
            delegate?.shrink()
        }
    }
}










