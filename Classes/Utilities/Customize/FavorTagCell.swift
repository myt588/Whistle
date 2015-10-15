//
//  FavorTagCell.swift
//  
//
//  Created by Lu Cao on 10/14/15.
//
//

import UIKit

class FavorTagCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dot: UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dot.layer.cornerRadius = 3
        dot.clipsToBounds = true
        label.textColor = Constants.Color.CellText
    }

}
