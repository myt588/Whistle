//
//  WEAnnotationView.swift
//  Whistle
//
//  Created by Yetian Mao on 7/13/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit
import MapKit

class WEAnnotationView: MKAnnotationView {
    
    var index: Int!
    var gender: Int?
    var user: PFUser!
    
    // Required for MKAnnotationView
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation, reuseIdentifier: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage(named: "clusterSmall")
    }
    
    func setImageView() {
        let width = self.image.size.width
        let imageView = WEProfileView(user: user, userInteraction: false)
        imageView.center = CGPointMake(width/2, width/2)
        self.addSubview(imageView)
    }
}