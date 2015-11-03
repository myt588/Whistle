//
//  WEFoiceBubble.swift
//  Whistle
//
//  Created by Lu Cao on 7/16/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

class WEVoiceBubble : FSVoiceBubble {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius                                = 12.5
        backgroundColor                                   = Constants.Color.CellText
        alpha                                             = 0.85
        clipsToBounds                                     = true
        durationInsideBubble                              = true
        bubbleImage                                       = nil
        waveColor                                         = Constants.Color.Background
        animatingWaveColor                                = UIColor.grayColor()
    }
}

class WEVoiceBar : FSVoiceBubble {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor                                   = Constants.Color.CellText
        alpha                                             = 1
        clipsToBounds                                     = true
        durationInsideBubble                              = true
        bubbleImage                                       = UIImage(named: "voicebar")
        waveColor                                         = Constants.Color.Background
        animatingWaveColor                                = UIColor.grayColor()
    }
}