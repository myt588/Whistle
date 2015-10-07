//
//  HelperClasses.swift
//  Whistle
//
//  Created by Yetian Mao on 8/16/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import Foundation

enum Order {
    case Ascending
    case Descending
}

enum Status {
    case NoTaker
    case HasTaker
    case TakerPicked
    case TakerDelivered
    case OwnerConfirmed
    case Cancelled
    case Reported
}