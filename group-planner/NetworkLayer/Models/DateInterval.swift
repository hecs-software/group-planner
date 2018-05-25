//
//  DateInterval.swift
//  group-planner
//
//  Created by Hoang on 5/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Foundation

struct DateInterval: Comparable, CustomStringConvertible {
    
    var start: Date
    var end: Date
    
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
    
    
    static func < (lhs: DateInterval, rhs: DateInterval) -> Bool {
        return lhs.start != rhs.start ? lhs.start < rhs.start : lhs.end < rhs.end
    }
    
    static func ==(lhs: DateInterval, rhs: DateInterval) -> Bool {
        return lhs.start == rhs.start
    }
    
    var description: String {
        return "From \(start.description) to \(end.description)"
    }
}
