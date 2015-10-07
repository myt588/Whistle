//
//  Location.swift
//  Whistle
//
//  Created by Yetian Mao on 7/14/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

class Location {
    let latitude : Double!
    let longtitude : Double!
    let formattedAddress: String!
    
    init(latitude: Double, longtitude: Double, formattedAddress: String){
        self.latitude = latitude
        self.longtitude = longtitude
        self.formattedAddress = formattedAddress
    }
}