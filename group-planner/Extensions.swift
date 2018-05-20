//
//  Extensions.swift
//  group-planner
//
//  Created by Hoang on 3/22/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit


extension UIColor {
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a: 1)
    }
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
}


extension UIViewController {
    func displayAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    func displayYesNoAlert(title: String, message: String, yesAction: @escaping (UIAlertAction) -> Void) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesAction))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    /**
     Hide keyboard when clicking outside of the keyboard
     Call this function if you want the view controller to hide keyboard when
     user tapps outside of keyboard region
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /**
     Dismiss keyboard, called by hideKeyboardWhenTappedAround()
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func shadeView(shaded: Bool) {
        DispatchQueue.main.async {
            if shaded {
                let mask = UIView(frame: self.view.frame)
                mask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.view.mask = mask
                self.view.isUserInteractionEnabled = false
            }
            else {
                self.view.mask = nil
                self.view.isUserInteractionEnabled = true
            }
        }
    }
}


extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    func addTopBorder(color: CGColor, borderWidth: CGFloat) {
        let layer = CALayer()
        let width = self.frame.size.width
        layer.frame = CGRect(x: 0, y: 0, width: width, height: borderWidth)
        layer.backgroundColor = color
        self.layer.addSublayer(layer)
    }
}


extension Date {
    func withinDates(minDate: Date, maxDate: Date) -> Bool {
        return minDate.compare(self).rawValue * self.compare(maxDate).rawValue >= 0
    }
    
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: self.startOfDay())!
    }
    
    
    func lastWeek() -> Date {
        var components = DateComponents()
        components.day = -7
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    
    func nextWeek() -> Date {
        var components = DateComponents()
        components.day = 7
        return Calendar.current.date(byAdding: components, to: self)!
    }
    
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}

// MARK: Helper methods
extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute,
                                  relatedBy: self.relation, toItem: self.secondItem,
                                  attribute: self.secondAttribute,
                                  multiplier: multiplier, constant: self.constant)
    }
    
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
