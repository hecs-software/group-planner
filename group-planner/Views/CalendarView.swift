//
//  CalendarView.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class CalendarView: UIScrollView {
    
    static let TOP_OFFSET: CGFloat = 8.0
    static let PERC_TIMEMARK_HEIGHT: CGFloat = 0.03
    static let PERC_TIMEMARK_GAP: CGFloat = 0.15
    
    var laidOutSubviews: Bool = false
    
    static let TIMEMARKS: [String] = [
        "12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM",
        "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM",
        "8 PM", "9 PM", "10 PM", "11 PM", "12 AM"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Render the events of that day
    func renderEvents(events: [GTLRCalendar_Events]) {
        
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
            
            i += 1
            
            if i != CalendarView.TIMEMARKS.count - 1 {
                self.contentSize.height += gap
            }
        }
        self.contentSize.height += CalendarView.TOP_OFFSET + height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidOutSubviews {
            setupTimeMarks()
            laidOutSubviews = true
        }
    }
    
}

class TimeMarkView: UIView {
    static let PERC_WIDTH_LINE: CGFloat = 0.85
    static let PERC_WIDTH_DATE: CGFloat = 0.10
    static let LABEL_LINE_OFFSET: CGFloat = 5.0
    
    var timeLabel: UILabel!
    var line: UIView!
    
    init(frame: CGRect, time: String) {
        super.init(frame: frame)
        
        viewInstantiations()
        setupLine()
        setupTimeLabel(time)
    }
    
    func viewInstantiations() {
        timeLabel = UILabel()
        line = UIView()
        
        addSubview(timeLabel)
        addSubview(line)
    }
    
    func setupTimeLabel(_ text: String) {
        timeLabel.text = text
        timeLabel.textAlignment = .right
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.1
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = .byClipping
        timeLabel.textColor = .lightGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: line.leftAnchor, constant: -TimeMarkView.LABEL_LINE_OFFSET).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: TimeMarkView.PERC_WIDTH_DATE).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        timeLabel.sizeToFit()
    }
    
    func setupLine() {
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        line.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: TimeMarkView.PERC_WIDTH_LINE).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EventView: UIView {
    
}
