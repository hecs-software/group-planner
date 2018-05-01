//
//  DaySegmentedControl.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import Foundation

class DaySCContainer: UIView {
    static let HEIGHT_MULTIPLIER: CGFloat = 0.90
    
    var laidoutSubviews: Bool = false
    
    var daySC: DaySegmentedControl!
    var buttonBar: UIButton!
    
    weak var delegate: DaySCDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDaySC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func restoreToCurrentDate() {
        let weekday = Utility.currentWeekDay
        daySC.selectedSegmentIndex = weekday - 1
        
        segmentedControlChanged(daySC)
    }
    
    
    func setupDaySC() {
        daySC = DaySegmentedControl(frame: .zero)
        addSubview(daySC)
        
        daySC.translatesAutoresizingMaskIntoConstraints = false
        daySC.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: daySC.trailingAnchor).isActive = true
        daySC.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        daySC.heightAnchor.constraint(equalTo: self.heightAnchor,
                                      multiplier: DaySCContainer.HEIGHT_MULTIPLIER).isActive = true
        
        daySC.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        daySC.selectedSegmentIndex = Utility.currentWeekDay - 1
    }
    
    
    func setupButtonBar() {
        buttonBar = UIButton()
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = .orange
        addSubview(buttonBar)
        
        let segmentWidth = daySC.frame.width / CGFloat(daySC.numberOfSegments)
        let leftOffset = daySC.frame.origin.x
        let x = leftOffset + segmentWidth * CGFloat(Utility.currentWeekDay - 1)
        
        buttonBar.topAnchor.constraint(equalTo: daySC.bottomAnchor).isActive = true
        buttonBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        buttonBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: x).isActive = true
        buttonBar.widthAnchor.constraint(equalTo: daySC.widthAnchor,
                                         multiplier: 1.0/CGFloat(daySC.numberOfSegments)).isActive = true
    }
    
    @objc func segmentedControlChanged(_ sender: DaySegmentedControl) {
        let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
        let leftOffset = sender.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = leftOffset + CGFloat(sender.selectedSegmentIndex) * segmentWidth
        }
        delegate?.pickedDay(_sender: daySC, day: daySC.selectedSegmentIndex + 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidoutSubviews {
            setupButtonBar()
            laidoutSubviews = true
        }
    }
}

class DaySegmentedControl: UISegmentedControl {
    
    static let DAYS = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var i = 0
        for day in DaySegmentedControl.DAYS {
            self.insertSegment(withTitle: day, at: i, animated: true)
            i += 1
        }
        
        self.backgroundColor = .clear
        self.tintColor = .clear
        
        self.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "DINCondensed-Bold", size: 18.0),
            NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ], for: .normal)
        
        self.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "DINCondensed-Bold", size: 18.0),
            NSAttributedStringKey.foregroundColor: UIColor.orange
            ], for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol DaySCDelegate: class {
    func pickedDay(_sender: DaySegmentedControl, day: Int)
}
