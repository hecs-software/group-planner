//
//  CalendarDateView.swift
//  group-planner
//
//  Created by Hoang on 4/27/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class CalendarDateView: UIScrollView {
    static let NUM_WEEKS_PER_BATCH: Int = 10
    
    @IBOutlet weak var contentView: UIView!
    
    var currentShownWeek: Int = 0
    var latestWeek: Int = 0
    var oldestWeek: Int = 0
    
    var oldestDate: Date!
    var latestDate: Date!
    
    var dateVCMap: [Int:DateViewContainer] = [Int:DateViewContainer]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    
    func setupCurrentWeek(delegate: DaySCDelegate) {
        let container = createDateViewContainer()
        container.daySC.delegate = delegate
        setupDateLabelText(dateLabel: container.dateLabel, date: Date())
        container.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(container)
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        oldestDate = Date.today().previous(.sunday)
        latestDate = Date.today().next(.saturday)
        dateVCMap[0] = container
    }
    
    
    func setupDateLabelText(dateLabel: UILabel, date: Date) {
        let sunday = date.previous(.sunday, considerToday: true)
        let saturday = date.next(.saturday, considerToday: true)
        
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
    
    
    func addLaterWeeks(delegate: DaySCDelegate) {
        for _ in 0..<CalendarDateView.NUM_WEEKS_PER_BATCH {
            addLaterWeek(delegate: delegate)
        }
    }
    
    
    func addOlderWeeks(delegate: DaySCDelegate) {
        for _ in 0..<CalendarDateView.NUM_WEEKS_PER_BATCH {
            addOlderWeek(delegate: delegate)
        }
    }
    
    
    func addLaterWeek(delegate: DaySCDelegate) {
        let latestContainer = dateVCMap[latestWeek]!
        let newContainer = createDateViewContainer()
        newContainer.daySC.delegate = delegate
        latestDate = latestDate.startOfDay().nextWeek()
        setupDateLabelText(dateLabel: newContainer.dateLabel, date: latestDate)
        newContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(newContainer)
        newContainer.leadingAnchor.constraint(equalTo: latestContainer.trailingAnchor).isActive = true
        newContainer.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        newContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: newContainer.bottomAnchor).isActive = true
        
        latestWeek += 1
        dateVCMap[latestWeek] = newContainer
        
        let frame = contentView.frame
        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y,
                              width: frame.width + self.frame.width, height: frame.height)
        contentView.frame = newFrame
    }
    
    
    func addOlderWeek(delegate: DaySCDelegate) {
        let oldestContainer = dateVCMap[oldestWeek]!
        let newContainer = createDateViewContainer()
        newContainer.daySC.delegate = delegate
        oldestDate = oldestDate.lastWeek()
        setupDateLabelText(dateLabel: newContainer.dateLabel, date: oldestDate)
        newContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(newContainer)
        oldestContainer.leadingAnchor.constraint(equalTo: newContainer.trailingAnchor).isActive = true
        newContainer.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        newContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: newContainer.bottomAnchor).isActive = true
        
        oldestWeek -= 1
        dateVCMap[oldestWeek] = newContainer
        
        let frame = contentView.frame
        let newFrame = CGRect(x: frame.origin.x - self.frame.width, y: frame.origin.y,
                              width: frame.width + self.frame.width, height: frame.height)
        contentView.frame = newFrame
    }
    
    
    // Create a container for DaySegmentedControl and DateLabel
    // with no contrainst specified
    func createDateViewContainer() -> DateViewContainer {
        let container = DateViewContainer(frame: .zero)
        return container
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentSize = self.contentView.frame.size
    }
}

class DateViewContainer: UIView {
    static let TOP_OFFSET: CGFloat = 4.0
    static let DAYSC_HEIGHT_MUL: CGFloat = 0.40
    static let DAYSC_WIDTH_MUL: CGFloat = 0.915
    static let DATE_LEFT_OFFSET: CGFloat = 36.0
    static let LEFT_OFFSET: CGFloat = 16.0
    static let RIGHT_OFFSET: CGFloat = 16.0
    
    var daySC: DaySCContainer!
    var dateLabel: UILabel!
    
    var laidoutSubviews: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        daySC = DaySCContainer(frame: .zero)
        dateLabel = UILabel(frame: .zero)
        dateLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        daySC.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(daySC)
        self.addSubview(dateLabel)
        
        daySC.heightAnchor.constraint(equalTo: self.heightAnchor,
                                      multiplier: DateViewContainer.DAYSC_HEIGHT_MUL).isActive = true
        self.bottomAnchor.constraint(equalTo: daySC.bottomAnchor).isActive = true
        daySC.widthAnchor.constraint(equalTo: self.widthAnchor,
                                     multiplier: DateViewContainer.DAYSC_WIDTH_MUL).isActive = true
        daySC.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                       constant: DateViewContainer.TOP_OFFSET).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                           constant: DateViewContainer.DATE_LEFT_OFFSET).isActive = true
        self.trailingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor,
                                       constant: DateViewContainer.RIGHT_OFFSET).isActive = true
        daySC.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: DateViewContainer.TOP_OFFSET).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

