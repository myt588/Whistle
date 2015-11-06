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

protocol WETagCollectionViewDelegate: UICollectionViewDelegate {
    func tagView(tagView: WETagCollectionView, didSelectItems items: [String])
}

let colorUnselectedTag = UIColor.clearColor()
let colorSelectedTag = UIColor.clearColor()

let colorTextUnSelectedTag = UIColor.whiteColor()
let colorTextSelectedTag = UIColor.whiteColor()

let TagCollectionViewCellIdentifier = "TagCell"

class WETagCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var tagDelegate : WETagCollectionViewDelegate?
    var tags: Array<Tag> = [Tag]()
    var _totalTagsSelected = 0
    
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
    
    var scrollHorizontally: Bool = false
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
        //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clearColor()
        self.registerClass(WETagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCellIdentifier)
        self.userInteractionEnabled = true
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.clearColor()
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
            
            var selectedTags = [String]()
            for tag in self.tags
            {
                if tag.selected
                {
                    selectedTags.append(tag.textContent)
                }
            }
            tagDelegate?.tagView(self, didSelectItems: selectedTags)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: WETagCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(TagCollectionViewCellIdentifier, forIndexPath: indexPath) as? WETagCollectionViewCell
        
        if indexPath.row < tags.count {
            let currentTag = tags[indexPath.row]
            cell?.initContent(currentTag)
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
}

