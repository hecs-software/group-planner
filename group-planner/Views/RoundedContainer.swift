//
//  RoundedContainer.swift
//  group-planner
//
//  Created by Hoang on 5/21/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit


class RoundedContainer: UIView {
    var laidoutSubviews: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidoutSubviews {
            self.cornerRadiusWithShadow(radius: 30)
            laidoutSubviews = true
        }
    }
}
