//
//  WECalloutView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import MapKit

class WECalloutView: UICollectionView {
    
    var users = [PFUser]()
    var indexes = [Int]()
    private let reuseIdentifier = "cell"
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.backgroundColor = UIColor.clearColor()
        self.dataSource = self
        self.delegate = self
        self.userInteractionEnabled = true
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.backgroundColor = Constants.Color.Background
        self.layer.cornerRadius                         = 10
        self.dataSource = self
        self.delegate = self
        self.userInteractionEnabled = true
    }
}

extension WECalloutView : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        let user = users[indexPath.item]
        user.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
            if let user = user as? PFUser {
                let imageView = WEProfileView(user: user)
                cell.contentView.backgroundColor = Constants.Color.Background
                cell.contentView.addSubview(imageView)
                imageView.frame = cell.contentView.frame
            }
        })
        return cell
    }
}

extension WECalloutView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.deselectItemAtIndexPath(indexPath, animated: false)
        let index = indexes[indexPath.item]
        NSNotificationCenter.defaultCenter().postNotificationName("calloutSelected", object: nil, userInfo: ["index": index])
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
}

