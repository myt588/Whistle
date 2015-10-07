//
//  ProfileLvGuideView.swift
//  Whistle
//
//  Created by Lu Cao on 8/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileLvGuideView: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: "http://www.baidu.com")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }

    @IBAction func closeTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
