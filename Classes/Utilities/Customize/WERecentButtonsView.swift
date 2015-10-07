//
//  WERecentButtonsView.swift
//  Whistle
//
//  Created by Lu Cao on 8/12/15.
//  Copyright (c) 2015 LoopCow. All rights reserved.
//

protocol WERecentButtonsViewDelegate
{
    func shareTapped(sender: UIButton!)
    func rateTapped(sender: UIButton!)
    func confirmTapped(sender: UIButton!)
    func cancelTapped(sender: UIButton!)
    func reportTapped(sender: UIButton!)
}


//----------------------------------------------------------------------------------------------------------
class WERecentButtonsView: UIView
//----------------------------------------------------------------------------------------------------------
{
    var delegate : WERecentButtonsViewDelegate?
    
    private var slot1: CGRect = CGRectMake(0, 0, 40, 40)
    private var slot2: CGRect = CGRectMake(50, 0, 40, 40)
    private var slot3: CGRect = CGRectMake(100, 0, 40, 40)
    private var slot4: CGRect = CGRectMake(150, 0, 40, 40)
    private var slot5: CGRect = CGRectMake(200, 0, 40, 40)
    
    
    var share = UIButton()
    var rate = UIButton()
    var confirm = UIButton()
    var cancel = UIButton()
    var report = UIButton()
    
    // MARK: - Init
    //----------------------------------------------------------------------------------------------------------
    required init(coder aDecoder: NSCoder)
    //----------------------------------------------------------------------------------------------------------
    {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
        
        share.setImage(UIImage(named: "favor_buttons_view_share"), forState: .Normal)
        share.addTarget(self, action: "shareTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        rate.setImage(UIImage(named: "favor_buttons_view_rate"), forState: .Normal)
        rate.addTarget(self, action: "rateTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        confirm.setImage(UIImage(named: "favor_buttons_view_confirm"), forState: .Normal)
        confirm.addTarget(self, action: "confirmTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cancel.setImage(UIImage(named: "favor_buttons_view_cancel"), forState: .Normal)
        cancel.addTarget(self, action: "cancelTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        report.setImage(UIImage(named: "favor_buttons_view_report"), forState: .Normal)
        report.addTarget(self, action: "reportTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var buttons = [share, rate, confirm, cancel, report]
        for element in buttons {
            element.backgroundColor = UIColor.clearColor()
            element.layer.borderWidth = 0.5
            element.layer.borderColor = Constants.Color.Border.CGColor
            element.layer.cornerRadius = 20
        }
    }
    
    func takerState(state: Int) {
        var buttons = [share, rate, confirm, cancel, report]
        for element in buttons {
            element.removeFromSuperview()
        }
        switch state {
        case 0, 1, 3:
            share.frame = slot5
            addSubview(share)
        case 2:
            confirm.frame = slot5
            addSubview(confirm)
            share.frame = slot4
            addSubview(share)
        case 4:
            rate.frame = slot5
            addSubview(rate)
            share.frame = slot4
            addSubview(share)
        case 5:
            report.frame = slot5
            addSubview(report)
            share.frame = slot4
            addSubview(share)
        case 6:
            share.frame = slot5
            addSubview(share)
        default:
            break
        }
    }
    
    func ownerState(state: Int) {
        var buttons = [share, rate, confirm, cancel, report]
        for element in buttons {
            element.removeFromSuperview()
        }
        switch state {
        case 0, 1, 2:
            cancel.frame = slot5
            addSubview(cancel)
            share.frame = slot4
            addSubview(share)
        case 3:
            cancel.frame = slot5
            addSubview(cancel)
            confirm.frame = slot4
            addSubview(confirm)
            share.frame = slot3
            addSubview(share)
        case 4:
            rate.frame = slot5
            addSubview(rate)
            share.frame = slot4
            addSubview(share)
        case 5:
            report.frame = slot5
            addSubview(report)
            share.frame = slot4
            addSubview(share)
        case 6:
            share.frame = slot5
            addSubview(share)
        default:
            break
        }
    }
    
    func shareTapped(sender: UIButton!)      { delegate?.shareTapped(sender)   }
    func rateTapped(sender: UIButton!)       { delegate?.rateTapped(sender)    }
    func confirmTapped(sender: UIButton!)    { delegate?.confirmTapped(sender) }
    func cancelTapped(sender: UIButton!)     { delegate?.cancelTapped(sender)  }
    func reportTapped(sender: UIButton!)     { delegate?.reportTapped(sender)  }
    
}










