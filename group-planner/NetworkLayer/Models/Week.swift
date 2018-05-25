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
    
    var monday: Date! {
        return sunday.nDayFromNow(n: 1)
    }
    
    var tuesday: Date! {
        return sunday.nDayFromNow(n: 2)
    }
    
    var wednesday: Date! {
        return sunday.nDayFromNow(n: 3)
    }
    
    var thursday: Date! {
        return sunday.nDayFromNow(n: 4)
    }
    
    var friday: Date! {
        return sunday.nDayFromNow(n: 5)
    }
    
    init(date: Date) {
        sunday = date.previous(.sunday, considerToday: true).startOfDay()
        saturday = date.next(.saturday, considerToday: true).endOfDay()
    }
    
    var description: String {
        return "\(sunday.description)\n\(saturday.description)"
    }
}
