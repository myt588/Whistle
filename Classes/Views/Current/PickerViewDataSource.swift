//
//  PickerViewDataSource.swift
//  Whistle
//
//  Created by Lu Cao on 7/22/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class PickerViewDataSource: UIViewController, AKPickerViewDataSource {

    let titles = ["Tokyo", "Kanagawa", "Osaka", "Aichi", "Saitama", "Chiba", "Hyogo", "Hokkaido", "Fukuoka", "Shizuoka"]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.titles.count
    }

}
