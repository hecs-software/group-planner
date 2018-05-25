//
//  Utility.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse
import Alamofire


class Utility {
    static let MONTH_MAP = [
        1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June",
        7: "July", 8: "August", 9: "September", 10: "October", 11: "November",
        12: "December"
    ]
    
    static var currentWeekDay: Int {
        get {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday], from: date)
            
            let weekday = components.weekday!
            return weekday
        }
    }
    
    static func maxdateMap(date: Date) -> [Int:Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year!
        let isLeapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
        
        let maxFebruary = isLeapYear ? 29 : 28
        
        return [
            1: 31, 2: maxFebruary, 3: 31, 4: 30, 5: 31, 6: 30,
            7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31
        ]
    }
    
    static func previousMonth(_ month: Int) -> Int {
        return month - 1 == 0 ? 12 : month - 1
    }
    
    static func nextMonth(_ month: Int) -> Int {
        return month + 1 == 13 ? 1 : month + 1
    }
    
    // Return Date range for that week
    // First in tuple is date range, Second is month range
    static func weekDateRange(weekday: Int, day: Int, month: Int) -> ((Int, Int), (Int, Int)) {
        let daysFromSunday = weekday - 1
        let daysUntilSaturday = 7 - weekday
        
        let sundayDate = Utility.nDaysBeforeNow(n: daysFromSunday, day: day, month: month)
        let saturdayDate = Utility.nDaysFromNow(n: daysUntilSaturday, day: day, month: month)
        
        // The week extends to next month
        if saturdayDate < day {
            return ((sundayDate, saturdayDate), (month, nextMonth(month)))
        }
        // The week extends to previous month
        else if sundayDate > day {
            return ((sundayDate, saturdayDate), (previousMonth(month), month))
        }
        
        return ((sundayDate, saturdayDate), (month, month))
    }
    
    static func nDaysFromNow(n: Int, day: Int, month: Int) -> Int {
        let map = maxdateMap(date: Date())
        let maxDate = map[month]!
        if day + n > maxDate {
            return (day + n - maxDate) % maxDate
        }
        else {
            return day + n
        }
    }
    
    static func nDaysBeforeNow(n: Int, day: Int, month: Int) -> Int {
        let map = maxdateMap(date: Date())
        let prev = previousMonth(month)
        let maxDate = map[prev]!
        if day - n < 0 {
            let tmp = n - day
            return maxDate - tmp
        }
        else {
            return day - n
        }
    }
    
    static func convertDateToLocal(date: Date) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateToConvert = dateFormatter.string(from: date)
        let convertedDate = dateFormatter.date(from: dateToConvert)
        
        let timezoneString = TimeZone.current.localizedName(for: .shortDaylightSaving,
                                                            locale: .current)!
        dateFormatter.timeZone = TimeZone(abbreviation: timezoneString)
        let localDateString = dateFormatter.string(from: convertedDate!)
        let localDate = dateFormatter.date(from: localDateString)!
        return localDate
    }
    
    
    static func withinDateRange(currDate: Int, currMonth: Int, begDate: Int,
                                begMonth: Int, endDate: Int, endMonth: Int) -> Bool {
        if begMonth == endMonth {
            if currMonth != begMonth {
                return false
            }
            else if currDate < begDate || currDate > endDate {
                return false
            }
        }
        else {
            if currMonth != begMonth || currMonth != endMonth {
                return false
            }
            else if currMonth == begMonth {
                if currDate < begDate {
                    return false
                }
            }
            else {
                if currDate > endDate {
                    return false
                }
            }
        }
        
        return true
    }
}


class ParseUtility {
    static func getPFFileFromImage(_ image: UIImage, name: String? = nil) -> PFFile {
        let imageData = UIImagePNGRepresentation(image)!
        
        if let name = name {
            return PFFile(name: name, data: imageData)!
        }
        else {
            return PFFile(name: "image.png", data: imageData)!
        }
    }
    
    static func deletePFFile(file: PFFile, completion: ErrorBlock? = nil) {
        let method = HTTPMethod.delete
        let filename = file.name
        
        let config = Parse.currentConfiguration()
        guard config != nil else {return}
        
        let appId = config!.applicationId
        guard appId != nil else {return}
        
        let clientKey = config!.clientKey
        guard clientKey != nil else {return}
        
        let url = URL(string: "http://group-planner.herokuapp.com/parse/files/\(filename)")!
        
        let headers: HTTPHeaders = [
            "X-Parse-Application-Id": appId!,
            "X-Parse-Master-Key": clientKey!
        ]
        
        NetworkUtility.request(url: url, method: method, parameters: nil,
                               headers: headers)
        { error in
            if let error = error {
                completion?(error)
            }
            else {
                completion?(nil)
            }
        }
        
    }
}

class NetworkUtility {
    static func downloadImage(url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        Alamofire.request(url).response {
            response in
            if let data = response.data {
                if let img = UIImage(data: data) {
                    completion(img, nil)
                }
            }
            else if let error = response.error {
                completion(nil, error)
            }
        }
    }
    
    static func request(url: URL, method: HTTPMethod, parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil, completion: JSONResultBlock? = nil) {
        Alamofire.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    completion?(nil, error)
                    break
                case .success:
                    guard let userDictionary = response.result.value as? [String: Any] else {
                        print("Can't parse json")
                        completion?(nil, nil)
                        return
                    }
                    
                    completion?(userDictionary, nil)
                }
        }
        
    }
    
    static func request(url: URL, method: HTTPMethod, parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil, completion: ErrorBlock? = nil) {
        Alamofire.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .response { (response) in
                if let error = response.error {
                    completion?(error)
                }
                else {
                    completion?(nil)
                }
        }
    }
}


class UIUtility {
    static let colors = [UIColor.purple, UIColor.yellow, UIColor.blue, UIColor.brown,
                         UIColor.cyan, UIColor.magenta, UIColor.darkGray, UIColor.green]
    
    static func hideViewWithAnimation(view: UIView, duration: Double, hidden: Bool = true,
                                      completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve,
                          animations:
            {
                view.isHidden = hidden
        }, completion: completion)
    }
}


class Algorithms {
    static func findGoodTimes(intervals: [String:[Int:[DateInterval]]], excludeUsers: [String]) -> [Int:[DateInterval]] {
        let excludeUsersSet = Set<String>(excludeUsers)
        
        // Stores all the DateIntervals merged together from all users
        var mergedIntervals = [Int:[DateInterval]]()
        
        for (userId, dayMap) in intervals {
            if !excludeUsersSet.contains(userId) {
                for (day, dateIntervals) in dayMap {
                    if let _ = mergedIntervals[day] {
                        mergedIntervals[day]?.append(contentsOf: dateIntervals)
                    }
                    else {
                        mergedIntervals[day] = [DateInterval]()
                        mergedIntervals[day]?.append(contentsOf: dateIntervals)
                    }
                }
            }
        }
        
        var results: [Int:[DateInterval]] = [Int:[DateInterval]]()
        for (day, dateIntervals) in mergedIntervals {
            if dateIntervals.count > 0 {
                let start = dateIntervals[0].start.startOfDay()
                let end = dateIntervals[0].start.endOfDay()
                results[day] = Algorithms.findNonOverlaps(intervals: dateIntervals, range: (start, end))
            }
        }
        
        return results
    }
    
    
    static func findNonOverlaps(intervals: [DateInterval], range: (Date, Date)) -> [DateInterval] {
        if intervals.count == 0 {return [DateInterval]()}
        
        let sortedIntervals = intervals.sorted()
        var nonOverlaps = [DateInterval]()
        
        var i = 0
        var maxEnd: Date!
        while i < sortedIntervals.count {
            // There is a non overlap region
            if maxEnd != nil && maxEnd < sortedIntervals[i].start {
                let start = maxEnd!
                let end = sortedIntervals[i].start
                let newInterval = DateInterval(start: start, end: end)
                nonOverlaps.append(newInterval)
            }
            
            let interval = sortedIntervals[i]
            maxEnd = maxEnd != nil ? max(maxEnd, interval.end) : interval.end
            
            i += 1
        }
        
        // maxEnd is now the largest Date in intervals
        let minStart = sortedIntervals[0].start
        
        let startRange = range.0
        let endRange = range.1
        if minStart > startRange {
            let newInterval = DateInterval(start: startRange, end: minStart)
            nonOverlaps.insert(newInterval, at: 0)
        }
        if endRange > maxEnd {
            let newInterval = DateInterval(start: maxEnd, end: endRange)
            nonOverlaps.append(newInterval)
        }
        
        return nonOverlaps
    }
}








