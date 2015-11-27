//
//  ProfileWebView.swift
//  Whistle
//
//  Created by Yetian Mao on 11/18/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileWebView: UIViewController {
    
    private var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        let url = NSURL (string: "http://www.baidu.com")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }
    
}