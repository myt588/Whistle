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
    
    override func layoutSubviews() {
        
        // adds a white border around the green circle
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 3
        layer.cornerRadius = self.bounds.size.width / 2
    }
    
    func setImageView(image: UIImage) {
        let width = self.image.size.width
        let userIconWidth = width - 6
        let imageView = UIImageView(image: image)
        imageView.userInteractionEnabled = true
        imageView.frame = CGRectMake(0, 0, userIconWidth, userIconWidth)
        imageView.center = CGPointMake(width/2, width/2)
        imageView.clipsToBounds                          = true
//        imageView.layer.borderWidth                      = 3
//        imageView.layer.borderColor                      = Constants.Color.Border.CGColor
        imageView.layer.cornerRadius                     = userIconWidth/2
        imageView.layer.backgroundColor                  = UIColor.lightGrayColor().CGColor
        self.addSubview(imageView)
    }
}