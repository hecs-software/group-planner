//
//  IntervalsCalendarView.swift
//  group-planner
//
//  Created by Hoang on 5/25/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Foundation
import UIKit

class IntervalsCalendarView: UIScrollView {
    static let HIDE_ANIMATION_DURATION: Double = 0.4
    
    static let TOP_OFFSET: CGFloat = 8.0
    static let PERC_TIMEMARK_HEIGHT: CGFloat = 0.03
    static let PERC_TIMEMARK_GAP: CGFloat = 0.15
    
    
    static let DAY_MAP = [
        1,2,3,4,5,6,7
    ]
    
    var currentShownWeek: Week = Week(date: Date())
    
    var laidOutSubviews: Bool = false
    
    // Size of an hour gap
    var hourGap: CGFloat = 0.0
    var currentRenderedDay: Int = {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        
        let weekday = components.weekday!
        return weekday
    }()
    
    static let TIMEMARKS: [String] = [
        "12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM",
        "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM",
        "8 PM", "9 PM", "10 PM", "11 PM", "12 AM"
    ]
    
    var timemarkViews: [TimeMarkView] = [TimeMarkView]()
    var eventViewsMap: [Int:[EventView]] = [
        1: [EventView](), 2: [EventView](), 3: [EventView](), 4: [EventView](),
        5: [EventView](), 6: [EventView](), 7: [EventView]()
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func renderDateIntervals(intervalsMap: [Int:[DateInterval]]) {
        discardAllEventViews()
        let timeMark = timemarkViews[0]
        let width = timeMark.frame.width * TimeMarkView.PERC_WIDTH_LINE
        let x = timeMark.frame.width - width
        
        for (_, intervals) in intervalsMap {
            for interval in intervals {
                let startDate = interval.start
                let localStartDate = Utility.convertDateToLocal(date: startDate)
                let calendar = Calendar.current
                var components = calendar.dateComponents([.month, .day, .weekday, .hour, .minute],
                                                         from: localStartDate)
                
                let weekday = components.weekday!
                let startHour = components.hour!
                let startMin = components.minute!
                
                components = calendar.dateComponents([.weekday, .hour, .minute],
                                                     from: interval.end)
                let endHour = components.hour!
                let endMin = components.minute!
                
                let startTimemark = timemarkViews[startHour]
                var startY = startTimemark.center.y
                let startMinOffset = (CGFloat(startMin) / CGFloat(60)) * hourGap
                startY = startY + startMinOffset
                
                let endTimemark = timemarkViews[endHour]
                var endY = endTimemark.center.y
                let endMinOffset = (CGFloat(endMin) / CGFloat(60)) * hourGap
                endY = endY + endMinOffset
                
                let height = endY - startY
                let frame = CGRect(x: x, y: startY, width: width, height: height)
                let eventView = EventView(frame: frame)
                eventView.isHidden = true
                addSubview(eventView)
                eventView.setFontColor(UIColor.purple)
                eventView.setShadeColor(UIColor.green)
                
                eventViewsMap[weekday]!.append(eventView)
            }
        }
        
        
        // Add the intervals where that day does not have any events
        let dayMap = IntervalsCalendarView.DAY_MAP
        for day in dayMap {
            if let _ = intervalsMap[day] {}
            else {
                let startTimemark = timemarkViews[0]
                let startY = startTimemark.center.y
                
                let endTimemark = timemarkViews[24]
                let endY = endTimemark.center.y
                
                let height = endY - startY
                let frame = CGRect(x: x, y: startY, width: width, height: height)
                let eventView = EventView(frame: frame)
                eventView.isHidden = true
                addSubview(eventView)
                eventView.setFontColor(UIColor.purple)
                eventView.setShadeColor(UIColor.green)
                
                eventViewsMap[day]!.append(eventView)
            }
        }
        
        
        switchToDay(weekday: currentRenderedDay)
    }
    
    
    func switchToDay(weekday: Int) {
        let currentEventViews = eventViewsMap[currentRenderedDay]!
        for eventView in currentEventViews {
            UIUtility.hideViewWithAnimation(view: eventView,
                                            duration: CalendarView.HIDE_ANIMATION_DURATION,
                                            hidden: true)
        }
        
        let newEventViews = eventViewsMap[weekday]!
        for eventView in newEventViews {
            UIUtility.hideViewWithAnimation(view: eventView,
                                            duration: CalendarView.HIDE_ANIMATION_DURATION,
                                            hidden: false)
        }
        currentRenderedDay = weekday
    }
    
    
    func setupTimeMarks() {
        self.contentSize.height = 0
        self.contentSize.height = CalendarView.TOP_OFFSET
        var i = 0
        
        let height = self.frame.height * CalendarView.PERC_TIMEMARK_HEIGHT
        let width = self.frame.width
        let gap_ratio = CalendarView.PERC_TIMEMARK_GAP
        let gap = gap_ratio * self.frame.height
        for time in CalendarView.TIMEMARKS {
            let y = CalendarView.TOP_OFFSET + gap * CGFloat(i)
            let frame = CGRect(x: 0, y: y, width: width, height: height)
            let timeMark = TimeMarkView(frame: frame, time: time)
            addSubview(timeMark)
            timemarkViews.append(timeMark)
            
            i += 1
            
            if i != CalendarView.TIMEMARKS.count - 1 {
                self.contentSize.height += gap
            }
        }
        self.contentSize.height += CalendarView.TOP_OFFSET + height
        self.hourGap = gap
    }
    
    
    func discardAllEventViews() {
        for (_, eventViews) in eventViewsMap {
            var eventViews = eventViews
            let group = DispatchGroup()
            for eventView in eventViews {
                group.enter()
                UIUtility.hideViewWithAnimation(view: eventView,
                                                duration: CalendarView.HIDE_ANIMATION_DURATION,
                                                hidden: true)
                { (success) in
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                for eventView in eventViews {
                    eventView.removeFromSuperview()
                }
                eventViews.removeAll()
            }
            
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidOutSubviews {
            setupTimeMarks()
            laidOutSubviews = true
        }
    }
    
    
    deinit {
        print("Deinitializing calendar view")
    }
    
}
