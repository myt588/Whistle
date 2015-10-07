//
//  ProfileLvView.swift
//  Whistle
//
//  Created by Lu Cao on 8/12/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

import UIKit

class ProfileLvView: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var lvLabel: UILabel!
    @IBOutlet weak var nextLvLabel: UILabel!
    @IBOutlet weak var levelUpDetailLabel: UILabel!
    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var nextTable: WETable!
    
    private var stepper = StepperView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configLooks()
        configStepper()
        nextTable.delegate = self
        nextTable.dataSource = self
    }
    
    @IBAction func backTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func lvGuideTapped(sender: UIButton) {
        
    }
    
    func configLooks() {
        view.backgroundColor                            = Constants.Color.Background
        var darkBlur                                    = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurView                                    = UIVisualEffectView(effect: darkBlur)
        blurView.frame                                  = view.bounds
        view.insertSubview(blurView, atIndex: 0)
        
        lvLabel.backgroundColor = Constants.Color.CellText
        lvLabel.textColor = Constants.Color.Background
        lvLabel.layer.cornerRadius = 50
        lvLabel.clipsToBounds = true
        
        levelUpDetailLabel.text = "✓ 2/2 Favors Placed\n✩ 1/2 Assists Completed\n✩ 1/3 Friends Added"
        var attributedString1 = NSMutableAttributedString(string: levelUpDetailLabel.text!)
        var paragraphStyle1 = NSMutableParagraphStyle()
        paragraphStyle1.lineSpacing = 15
        attributedString1.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle1, range: NSMakeRange(0, count( levelUpDetailLabel.text!)))
        levelUpDetailLabel.attributedText = attributedString1
        levelUpDetailLabel.sizeToFit()
    }
    
    func configStepper() {
        stepper.numberTotalStep = 5
        stepper.numberCurrent = 2
        stepper.drawStepperInView(stepperView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileNextLvCell", forIndexPath: indexPath) as! ProfileNextLvCell
        
        return cell
    }
}
