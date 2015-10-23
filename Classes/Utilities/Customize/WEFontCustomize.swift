//
//  WEFontCustomize.swift
//  Whistle
//
//  Created by Lu Cao on 10/17/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

class WEFontSubLogo: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextMain
        font = UIFont(name: "HelveticaNeue-Thin", size: 19)
    }
}

class WEFontCopyright: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextCopyright
        font = UIFont(name: "HelveticaNeue-Light", size: 10)
    }
}

class WEFontSignIn: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextMain
        font = UIFont(name: "TimesNewRomanPSMT", size: 19)
    }
}

class WEFontHeader: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextMain
        font = UIFont(name: "AbrahamLincoln", size: 26)
    }
}

class WEFontContent: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = UIColor.whiteColor()
        font = UIFont(name: "MyriadPro-SemiExt", size: 15)
    }
}

class WEFontIndicator: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextIndicator
        font = UIFont(name: "HelveticaNeue-Thin", size: 10)
    }
}

class WEFontInformation: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextIndicator
        font = UIFont(name: "HelveticaNeue-Thin", size: 12)
    }
}

class WEFontName: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = UIColor.whiteColor()
        font = UIFont(name: "Arial", size: 20)
    }
}

class WEFontNameBlack: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = UIColor.blackColor()
        font = UIFont(name: "Arial", size: 20)
    }
}

class WEFontComment: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textColor = Constants.Color.TextCopyright
        font = UIFont(name: "HelveticaNeue-Light", size: 10)
    }
}