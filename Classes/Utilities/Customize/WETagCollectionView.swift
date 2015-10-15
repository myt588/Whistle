//
//  WETagCollectionView.swift
//  Whistle
//
//  Created by Yetian Mao on 10/15/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

struct Tag {
    var selected: Bool
    var isLocked: Bool
    var textContent: String
}

let colorUnselectedTag = UIColor.whiteColor()
let colorSelectedTag = UIColor(red:0.22, green:0.7, blue:0.99, alpha:1)

let colorTextUnSelectedTag = UIColor(red:0.33, green:0.33, blue:0.35, alpha:1)
let colorTextSelectedTag = UIColor.whiteColor()

let TagCollectionViewCellIdentifier = "TagCell"

class WETagCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var tags: Array<Tag> = [Tag]()
    private var _totalTagsSelected = 0
    
    var totalTagsSelected: Int {
        get {
            return self._totalTagsSelected
        }
        set {
            if newValue == 0 {
                self._totalTagsSelected = 0
                return
            }
            self._totalTagsSelected += newValue
            self._totalTagsSelected = (self._totalTagsSelected < 0) ? 0 : self._totalTagsSelected
        }
    }
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.whiteColor()
        self.registerClass(WETagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCellIdentifier)
        self.userInteractionEnabled = true
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.whiteColor()
        self.registerClass(WETagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCellIdentifier)
        self.userInteractionEnabled = true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            if indexPath.row < tags.count {
                return WETagCollectionViewCell.contentHeight(tags[indexPath.row].textContent)
            }
            return CGSizeMake(40, 40)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell: WETagCollectionViewCell? = collectionView.cellForItemAtIndexPath(indexPath) as? WETagCollectionViewCell
        if indexPath.row < tags.count {
            var currentTag = tags[indexPath.row]
            
            if tags[indexPath.row].selected == false {
                tags[indexPath.row].selected = true
                selectedCell?.animateSelection(tags[indexPath.row].selected)
                totalTagsSelected = 1
            }
            else {
                tags[indexPath.row].selected = false
                selectedCell?.animateSelection(tags[indexPath.row].selected)
                totalTagsSelected = -1
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: WETagCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(TagCollectionViewCellIdentifier, forIndexPath: indexPath) as? WETagCollectionViewCell
        
        if indexPath.row < tags.count {
            let currentTag = tags[indexPath.row]
            cell?.initContent(currentTag)
        }
        else {
            cell?.initAddButtonContent()
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
}

