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
    static let HIDE_ANIMATION_DURATION: Double = 0.4
    
    static let TOP_OFFSET: CGFloat = 8.0
    static let PERC_TIMEMARK_HEIGHT: CGFloat = 0.03
    static let PERC_TIMEMARK_GAP: CGFloat = 0.15
    
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
    
    // Maps user to day in week, day in week maps to list of eventviews
    var usersEVMap: [String:[Int:[EventView]]] = [String:[Int:[EventView]]]()
    
    // Stores the userIds of users' events that are supposed to be hidden
    var hiddenUsers: [String] = [String]()
    var profilePage: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func loadEvents(inWeek week: Week, completion: GTLRCalendarEventsResult? = nil) {
        GGLAPIClient.shared.fetchEvents(minDate: week.sunday, maxDate: week.saturday)
        { (ticket, events, error) in
            if let events = events {
                self.renderEvents(events: events)
            }
            
            completion?(ticket, events, error)
        }
    }
    
    
    func loadEvents(ofUsers users: [User], week: Week, completion: GTLRCalendarEventsResult? = nil) {
        GGLAPIClient.shared.fetchEvents(ofUsers: users, minDate: week.sunday, maxDate: week.saturday) { (map, error) in
            if let map = map {
                self.renderEvents(usersMap: map)
            }
        }
    }
    
    
    // Render the events of that week
    func renderEvents(usersMap: [String:[GTLRCalendar_Event]]) {
        discardAllEventViews()
        let timeMark = timemarkViews[0]
        let width = timeMark.frame.width * TimeMarkView.PERC_WIDTH_LINE
        let x = timeMark.frame.width - width
        
        let colors = UIUtility.colors
        var i = 0
        
        for (userId, events) in usersMap {
            let color = colors[i % colors.count]
            
            for event in events {
                let startDate = event.start!.dateTime ?? event.start!.date!
                let localStartDate = Utility.convertDateToLocal(date: startDate.date)
                let calendar = Calendar.current
                var components = calendar.dateComponents([.month, .day, .weekday, .hour, .minute],
                                                         from: localStartDate)
                
                if !startDate.date.withinDates(minDate: currentShownWeek.sunday,
                                               maxDate: currentShownWeek.saturday) {
                    continue
                }
                
                let weekday = components.weekday!
                let startHour = components.hour!
                let startMin = components.minute!
                
                if let endDate = event.end?.dateTime {
                    var components = calendar.dateComponents([.weekday, .hour, .minute],
                                                             from: endDate.date)
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
                    
                    var eventView: EventView!
                    // Create a disabled text event view for users that are not
                    // the current user
                    if let user = User.current(),
                        user.objectId! != userId {
                        eventView = EventView(frame: frame, event: event, disableText: true)
                    }
                    else {
                        eventView = EventView(frame: frame, event: event)
                    }
                    eventView.isHidden = true
                    addSubview(eventView)
                    eventView.setFontColor(UIColor.purple)
                    eventView.setShadeColor(color)
                    
                    eventViewsMap[weekday]!.append(eventView)
                    if let map = usersEVMap[userId] {
                        if let _ = map[weekday] {
                            usersEVMap[userId]![weekday]!.append(eventView)
                        }
                        else {
                            usersEVMap[userId]![weekday] = [EventView]()
                            usersEVMap[userId]![weekday]!.append(eventView)
                        }
                    }
                    else {
                        usersEVMap[userId] = [Int:[EventView]]()
                        usersEVMap[userId]![weekday] = [EventView]()
                        usersEVMap[userId]![weekday]!.append(eventView)
                    }
                }
            }
            i += 1
        }
        
        switchToDay(weekday: currentRenderedDay)
    }
    
    
    // Render the events of that week
    func renderEvents(events: [GTLRCalendar_Event]) {
        discardAllEventViews()
        let timeMark = timemarkViews[0]
        let width = timeMark.frame.width * TimeMarkView.PERC_WIDTH_LINE
        let x = timeMark.frame.width - width
        
        for event in events {
            let startDate = event.start!.dateTime ?? event.start!.date!
            let localStartDate = Utility.convertDateToLocal(date: startDate.date)
            let calendar = Calendar.current
            var components = calendar.dateComponents([.month, .day, .weekday, .hour, .minute],
                                                     from: localStartDate)
            
            if !startDate.date.withinDates(minDate: currentShownWeek.sunday,
                                           maxDate: currentShownWeek.saturday) {
                continue
            }
            
            let weekday = components.weekday!
            let startHour = components.hour!
            let startMin = components.minute!
            
            if let endDate = event.end?.dateTime {
                var components = calendar.dateComponents([.weekday, .hour, .minute],
                                                         from: endDate.date)
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
                let eventView = EventView(frame: frame, event: event)
                eventView.isHidden = true
                addSubview(eventView)
                eventView.setFontColor(UIColor.purple)
                eventView.setShadeColor(UIColor.blue)
                
                eventViewsMap[weekday]!.append(eventView)
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
        
        // Shows all events of the users on that day, except of the users
        // that are supposed to be hidden
        
        if profilePage {
            let newEventViews = eventViewsMap[weekday]!
            for eventView in newEventViews {
                UIUtility.hideViewWithAnimation(view: eventView,
                                                duration: CalendarView.HIDE_ANIMATION_DURATION,
                                                hidden: false)
            }
        }
        else {
            for (userId, evMap) in usersEVMap {
                if !hiddenUsers.contains(userId) {
                    let eventViews = evMap[weekday]
                    if let eventViews = eventViews {
                        for eventView in eventViews {
                            UIUtility.hideViewWithAnimation(view: eventView,
                                                            duration: CalendarView.HIDE_ANIMATION_DURATION,
                                                            hidden: false)
                        }
                    }
                }
            }
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
    
    
    func hideUsersEvents(userId: String, hide: Bool) {
        guard usersEVMap[userId] != nil else {return}
        let eventViews = usersEVMap[userId]![currentRenderedDay]
        if let eventViews = eventViews {
            for eventView in eventViews {
                UIUtility.hideViewWithAnimation(view: eventView, duration: CalendarView.HIDE_ANIMATION_DURATION,
                                                hidden: hide)
            }
        }
    }
    
    
    func discardAllEventViews() {
        usersEVMap.removeAll()
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
        timeLabel.font = UIFont.systemFont(ofSize: 10.0)
        timeLabel.textAlignment = .right
        timeLabel.minimumScaleFactor = 0.1
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = .byClipping
        timeLabel.textColor = .lightGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor,
                                      constant: TimeMarkView.LABEL_LINE_OFFSET).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: self.widthAnchor,
                                         multiplier: TimeMarkView.PERC_WIDTH_DATE).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        timeLabel.sizeToFit()
    }
    
    func setupLine() {
        line.backgroundColor = .lightGray
        line.translatesAutoresizingMaskIntoConstraints = false
        line.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: TimeMarkView.PERC_WIDTH_LINE).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EventView: UIView {
    static let CONTAINER_OFFSET: CGFloat = 2.0
    static let ALPHA_COMPONENT: CGFloat = 0.1
    static let FONT_SIZE: CGFloat = 12.0
    static let TOP_OFFSET: CGFloat = 3.0
    static let LEFT_OFFSET: CGFloat = 6.0
    static let RIGHT_OFFSET: CGFloat = 3.0
    static let BOTTOM_OFFSET: CGFloat = 3.0
    
    var container: UIView!
    var titleLabel: UILabel?
    var locationLabel: UILabel?
    var descriptionLabel: UILabel?
    var googleEvent: GTLRCalendar_Event!
    
    init(frame: CGRect, event: GTLRCalendar_Event, disableText: Bool = false) {
        super.init(frame: frame)
        
        self.googleEvent = event
        setupContainer()
        
        if let text = event.summary,
            !disableText {
            setupTitleLabel(text)
        }
        if let text = event.location,
            !disableText {
            setupLocationLabel(text)
        }
        if let text = event.descriptionProperty,
            !disableText {
            setupDescriptionLabel(text)
        }
    }
    
    func setupContainer() {
        container = UIView()
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let offset = EventView.CONTAINER_OFFSET
        container.topAnchor.constraint(equalTo: self.topAnchor, constant: offset).isActive = true
        container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -offset).isActive = true
        container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -offset).isActive = true
        container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: offset).isActive = true
    }
    
    func setupTitleLabel(_ text: String) {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: EventView.FONT_SIZE, weight: .bold)
        label.text = text
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                       constant: EventView.LEFT_OFFSET).isActive = true
        self.trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor,
                                       constant: EventView.RIGHT_OFFSET).isActive = true
        
        label.topAnchor.constraint(equalTo: self.topAnchor,
                                   constant: EventView.TOP_OFFSET).isActive = true
        
        self.titleLabel = label
    }
    
    func setupLocationLabel(_ text: String) {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: EventView.FONT_SIZE, weight: .regular)
        label.text = text
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                       constant: EventView.LEFT_OFFSET).isActive = true
        self.trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor,
                                       constant: EventView.RIGHT_OFFSET).isActive = true
        
        var topA: NSLayoutAnchor<NSLayoutYAxisAnchor>!
        if let top = titleLabel {
            topA = top.bottomAnchor
        }
        else {
            topA = self.topAnchor
        }
        label.topAnchor.constraint(equalTo: topA, constant: EventView.TOP_OFFSET).isActive = true
        
        self.locationLabel = label
    }
    
    func setupDescriptionLabel(_ text: String) {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: EventView.FONT_SIZE, weight: .regular)
        label.text = text
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                       constant: EventView.LEFT_OFFSET).isActive = true
        self.trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor,
                                       constant: EventView.RIGHT_OFFSET).isActive = true
        
        var topA: NSLayoutAnchor<NSLayoutYAxisAnchor>!
        if let top = locationLabel {
            topA = top.bottomAnchor
        }
        else if let top = titleLabel {
            topA = top.bottomAnchor
        }
        else {
            topA = self.topAnchor
        }
        label.topAnchor.constraint(equalTo: topA, constant: EventView.TOP_OFFSET).isActive = true
        self.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor,
                                     constant: EventView.BOTTOM_OFFSET).isActive = true
        
        self.descriptionLabel = label
    }
    
    func setShadeColor(_ color: UIColor) {
        container.backgroundColor = color.withAlphaComponent(EventView.ALPHA_COMPONENT)
    }
    
    func setFontColor(_ color: UIColor) {
        if let label = titleLabel {
            label.textColor = color
        }
        if let label = locationLabel {
            label.textColor = color
        }
        if let label = descriptionLabel {
            label.textColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
