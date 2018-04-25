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
    @IBOutlet weak var daySC: DaySegmentedControl!

    var buttonBar: UIButton!
    weak var delegate: DaySCDelegate?
    
    var laidoutSubviews: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupListeners()
        setupButtonBar()
    }
    
    func restoreToCurrentDate() {
        let weekday = Utility.currentWeekDay
        daySC.selectedSegmentIndex = weekday - 1
        
        segmentedControlChanged(daySC)
    }
    
    
    func setupListeners() {
        daySC.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    
    func setupButtonBar() {
        buttonBar = UIButton()
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = .orange
        addSubview(buttonBar)
        
        let segmentWidth = daySC.frame.width / CGFloat(daySC.numberOfSegments)
        let x = segmentWidth * CGFloat(Utility.currentWeekDay - 1)
        buttonBar.topAnchor.constraint(equalTo: daySC.bottomAnchor).isActive = true
        buttonBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        buttonBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: x).isActive = true
        buttonBar.widthAnchor.constraint(equalTo: daySC.widthAnchor,
                                         multiplier: 1.0/CGFloat(daySC.numberOfSegments)).isActive = true
    }
    
    @objc func segmentedControlChanged(_ sender: DaySegmentedControl) {
        let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.frame.origin.x = CGFloat(sender.selectedSegmentIndex) * segmentWidth
        }
        delegate?.pickedDay(_sender: daySC, day: daySC.selectedSegmentIndex + 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidoutSubviews {
            restoreToCurrentDate()
            laidoutSubviews = true
        }
    }
}

class DaySegmentedControl: UISegmentedControl {
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    
}

protocol DaySCDelegate: class {
    func pickedDay(_sender: DaySegmentedControl, day: Int)
}
