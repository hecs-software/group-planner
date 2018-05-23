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
    static let VELOCITY_TO_SWITCH: CGFloat = 500
    static let SWITCH_DURATION: Double = 0.2
    
    @IBOutlet weak var contentView: UIView!
    
    weak var cdvDelegate: CalendarDateViewDelegate?
    
    var cvTrailing: NSLayoutConstraint!
    
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
        self.panGestureRecognizer.addTarget(self, action: #selector(snap))
    }
    
    
    func setupContainer() {
        contentView.frame = self.bounds
    }
    
    
    func setupCurrentWeek(delegate: DaySCDelegate) {
        let width = self.frame.width
        let height = self.frame.height
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let container = createDateViewContainer(frame: frame)
        container.daySC.delegate = delegate
        setupDateLabelText(dateView: container, date: Date())
        
        self.addSubview(container)
        
        oldestDate = Date.today().previous(.sunday)
        latestDate = Date.today().next(.saturday)
        dateVCMap[0] = container
        
        self.contentSize.width = self.frame.width
        self.contentSize.height = self.frame.height
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
        let cvFrame = contentView.frame
        let newFrame = CGRect(x: cvFrame.origin.x, y: cvFrame.origin.y,
                              width: cvFrame.width + self.frame.width, height: cvFrame.height)
        contentView.frame = newFrame
        
        let latestContainer = dateVCMap[latestWeek]!
        
        let width = self.frame.width
        let height = self.frame.height
        let x: CGFloat = latestContainer.frame.origin.x + width
        let y: CGFloat = 0.0
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let newContainer = createDateViewContainer(frame: frame)
        newContainer.daySC.delegate = delegate
        
        latestDate = latestDate.startOfDay().nextWeek()
        setupDateLabelText(dateView: newContainer, date: latestDate)
        
        self.addSubview(newContainer)
        latestWeek += 1
        dateVCMap[latestWeek] = newContainer
        
        self.contentSize.width += self.frame.width
    }
    
    
    func addOlderWeek(delegate: DaySCDelegate) {
        let cvFrame = contentView.frame
        let newFrame = CGRect(x: cvFrame.origin.x - self.frame.width, y: cvFrame.origin.y,
                              width: cvFrame.width + self.frame.width, height: cvFrame.height)
        contentView.frame = newFrame
        
        let oldestContainer = dateVCMap[oldestWeek]!
        
        let width = self.frame.width
        let height = self.frame.height
        let x: CGFloat = oldestContainer.frame.origin.x - width
        let y: CGFloat = 0.0
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        let newContainer = createDateViewContainer(frame: frame)
        newContainer.daySC.delegate = delegate
        
        oldestDate = oldestDate.lastWeek()
        setupDateLabelText(dateView: newContainer, date: oldestDate)
        
        self.addSubview(newContainer)
        oldestWeek -= 1
        dateVCMap[oldestWeek] = newContainer
        
        self.contentInset.left += self.frame.width
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
    
    
    @objc func snap(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self)
        var snapRight: Bool = false
        var snapLeft: Bool = false
        if velocity.x < -CalendarDateView.VELOCITY_TO_SWITCH {
            snapRight = true
        }
        if velocity.x > CalendarDateView.VELOCITY_TO_SWITCH {
            snapLeft = true
        }
        
        if sender.state == .ended {
            let x = self.contentOffset.x
            let y = self.contentOffset.y
            let index = CGFloat(calculateCurrentIndex())
            let viewWidth = self.frame.width
            let minX = index * viewWidth
            let maxX = (index + 1) * viewWidth
            
            // Duration of animation
            let duration: Double = CalendarDateView.SWITCH_DURATION
            
            if x > self.contentSize.width - viewWidth { // snap back to the left
                UIView.animate(withDuration: duration, animations:
                    {
                        self.contentOffset = CGPoint(x: minX, y: y)
                })
                return
            }
            
            if x < -self.contentInset.left { // snap back to the right
                UIView.animate(withDuration: duration, animations:
                    {
                        self.contentOffset = CGPoint(x: maxX, y: y)
                })
                return
            }
            
            let swipingRight = sender.translation(in: self).x > 0
            
            let enoughOfRightShown = (maxX - x)/self.frame.width < 0.70
            let enoughOfLeftShown = (maxX - x)/self.frame.width > 0.30
            
            if snapRight { // snap right if swiping left fast enough
                UIView.animate(withDuration: duration, animations:
                    {
                        self.contentOffset = CGPoint(x: maxX, y: y)
                }, completion: { _ in
                    self.snappedToNewWeek(weekIndex: Int(index) + 1)
                })
                return
            }
            if snapLeft { // snap left if swiping right fast enough
                UIView.animate(withDuration: duration, animations:
                    {
                        self.contentOffset = CGPoint(x: minX, y: y)
                }, completion: { _ in
                    self.snappedToNewWeek(weekIndex: Int(index))
                })
                return
            }
            
            // snap right if enough of right is shown, else snap back left
            if !swipingRight {
                if enoughOfRightShown {
                    UIView.animate(withDuration: duration, animations:
                        {
                            self.contentOffset = CGPoint(x: maxX, y: y)
                    }, completion: { _ in
                        self.snappedToNewWeek(weekIndex: Int(index) + 1)
                    })
                } else {
                    UIView.animate(withDuration: duration, animations:
                        {
                            self.contentOffset = CGPoint(x: minX, y: y)
                    })
                }
                return
            }
            else {
                // snap left if enough of left is shown, else snap back right
                if enoughOfLeftShown {
                    UIView.animate(withDuration: duration, animations:
                        {
                            self.contentOffset = CGPoint(x: minX, y: y)
                    }, completion: { _ in
                        self.snappedToNewWeek(weekIndex: Int(index))
                    })
                } else {
                    UIView.animate(withDuration: duration, animations:
                        {
                            self.contentOffset = CGPoint(x: maxX, y: y)
                    })
                }
            }
        }
    }
    
    func calculateCurrentIndex() -> Int {
        let contentOffset = self.contentOffset
        let x = contentOffset.x
        
        let viewWidth = self.frame.width
        let result = x/viewWidth
        let index = floor(result)
        return Int(index)
    }
    
    
    func snappedToNewWeek(weekIndex: Int) {
        currentShownWeek = weekIndex
        let dateView = dateVCMap[weekIndex]
        if let dateView = dateView {
            let week = dateView.week!
            let selectedDay = dateView.daySC.daySC.selectedSegmentIndex + 1
            cdvDelegate?.didSnap(toWeek: week,
                                 dayPicked: selectedDay)
        }
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
    var week: Week!
    
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
    
    deinit {
        print("Deinitializing calendar date view")
    }
}


protocol CalendarDateViewDelegate: class {
    func didSnap(toWeek week: Week, dayPicked: Int)
}


