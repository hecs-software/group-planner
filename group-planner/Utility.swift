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
