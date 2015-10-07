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
        self.image = UIImage(named: "pin")
    }
    
    func setImageView(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.userInteractionEnabled = true
        imageView.frame = CGRectMake(5, 5, 35, 35)
        imageView.clipsToBounds                          = true
        imageView.layer.borderWidth                      = 3
        imageView.layer.borderColor                      = Constants.Color.Border.CGColor
        imageView.layer.cornerRadius                     = 17.5
        imageView.layer.backgroundColor                  = UIColor.lightGrayColor().CGColor
        
        self.addSubview(imageView)
    }
}