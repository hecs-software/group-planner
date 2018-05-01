//
//  Week.swift
//  group-planner
//
//  Created by Hoang on 4/27/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Foundation

struct Week: CustomStringConvertible {
    var sunday: Date!
    var saturday: Date!
    
    init(date: Date) {
        sunday = date.previous(.sunday, considerToday: true).startOfDay()
        saturday = date.next(.saturday, considerToday: true).endOfDay()
    }
    
    var description: String {
        return "\(sunday.description)\n\(saturday.description)"
    }
}
