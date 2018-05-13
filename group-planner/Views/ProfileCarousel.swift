//
//  ProfileCarousel.swift
//  group-planner
//
//  Created by Hoang on 5/13/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class ProfileCarousel: UICollectionView {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in self.subviews {
            if (view.isUserInteractionEnabled &&
                view.point(inside: self.convert(point, to: view), with: event)) {
                return true
            }
        }
        return false
    }
}
