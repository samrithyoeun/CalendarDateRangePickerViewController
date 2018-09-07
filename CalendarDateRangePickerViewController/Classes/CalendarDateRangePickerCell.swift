//
//  CalendarDateRangePickerCell.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerCell: UICollectionViewCell {
    
    private let defaultTextColor = UIColor.darkGray
    var highlightedColor = UIColor(red: 15/255.0, green: 147/255.0, blue: 189/255.0, alpha: 1.0)
    private let disabledColor = UIColor.lightGray
    
    var selectedColor: UIColor!
    
    var date: Date?
    var selectedView: UIView?
    var halfBackgroundView: UIView?
    var roundHighlightView: UIView?
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initLabel()
    }
    
    func initLabel() {
        label = UILabel(frame: frame)
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        } else {
            // Fallback on earlier versions
        }
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    func reset() {
        self.backgroundColor = UIColor.clear
        label.textColor = defaultTextColor
        label.backgroundColor = UIColor.clear
        if selectedView != nil {
            selectedView?.removeFromSuperview()
            selectedView = nil
        }
        if halfBackgroundView != nil {
            halfBackgroundView?.removeFromSuperview()
            halfBackgroundView = nil
        }
        if roundHighlightView != nil {
            roundHighlightView?.removeFromSuperview()
            roundHighlightView = nil
        }
    }
    
    func select() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        selectedView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        selectedView?.backgroundColor = selectedColor
        selectedView?.layer.cornerRadius = height / 2
        self.addSubview(selectedView!)
        self.sendSubview(toBack: selectedView!)
        
        label.textColor = UIColor.white
    }
    
    func highlightRight() {
        // This is used instead of highlight() when we need to highlight cell with a rounded edge on the left
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: width / 2, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        
        self.addSubview(halfBackgroundView!)
        self.sendSubview(toBack: halfBackgroundView!)
        label.textColor = UIColor.white
        addRoundHighlightView()
    }
    
    func highlightLeft() {
        // This is used instead of highlight() when we need to highlight the cell with a rounded edge on the right
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        self.addSubview(halfBackgroundView!)
        self.sendSubview(toBack: halfBackgroundView!)
        label.textColor = UIColor.white
        addRoundHighlightView()
    }
    
    func addRoundHighlightView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        roundHighlightView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        roundHighlightView?.backgroundColor = highlightedColor
        roundHighlightView?.layer.cornerRadius = height / 2
        self.addSubview(roundHighlightView!)
        self.sendSubview(toBack: roundHighlightView!)
        label.textColor = UIColor.white
    }
    
    func highlight() {
        self.backgroundColor = highlightedColor
        label.textColor = UIColor.white
    }
    
    func singleDatehighlight() {
        self.backgroundColor = highlightedColor
        label.textColor = UIColor.white
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    func disable() {
        label.textColor = disabledColor
    }
    
}
