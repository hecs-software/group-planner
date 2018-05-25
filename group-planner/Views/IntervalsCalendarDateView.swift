//
//  IntervalsCalendarDateView.swift
//  group-planner
//
//  Created by Hoang on 5/25/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Foundation
import UIKit

class IntervalsCalendarDateView: UIView {
    var oldestDate: Date!
    var latestDate: Date!

    var dateVC: DateViewContainer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setupCurrentWeek(delegate: DaySCDelegate, currentWeek: Week) {
        let width = self.frame.width
        let height = self.frame.height
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let container = createDateViewContainer(frame: frame)
        
        container.daySC.delegate = delegate
        setupDateLabelText(dateView: container, date: currentWeek.sunday)
        
        self.addSubview(container)
        
        oldestDate = currentWeek.sunday
        latestDate = currentWeek.saturday
        
        dateVC = container
    }
    
    
    func setupDateLabelText(dateView: DateViewContainer, date: Date) {
        let dateLabel = dateView.dateLabel!
        let sunday = date.previous(.sunday, considerToday: true)
        let saturday = date.next(.saturday, considerToday: true)
        
        dateView.week = Week(date: date)
        
        let calendar = Calendar.current
        let begComponents = calendar.dateComponents([.month, .day, .weekday], from: sunday)
        let endComponents = calendar.dateComponents([.month, .day, .weekday], from: saturday)
        
        let begDate = begComponents.day!
        let endDate = endComponents.day!
        let begMonth = begComponents.month!
        let endMonth = endComponents.month!
        
        
        if begMonth == endMonth {
            let monthName = Utility.MONTH_MAP[begMonth]!
            let dateString = "\(monthName) \(begDate) - \(endDate)"
            dateLabel.text = dateString
        }
        else {
            let month1 = Utility.MONTH_MAP[begMonth]!
            let month2 = Utility.MONTH_MAP[endMonth]!
            let dateString = "\(month1) \(begDate) - \(month2) \(endDate)"
            dateLabel.text = dateString
        }
        dateLabel.sizeToFit()
    }
    
    
    // Create a container for DaySegmentedControl and DateLabel
    // with no contrainst specified
    func createDateViewContainer(frame: CGRect? = nil) -> DateViewContainer {
        if let frame = frame {
            let container = DateViewContainer(frame: frame)
            return container
        }
        else {
            let container = DateViewContainer(frame: .zero)
            return container
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
