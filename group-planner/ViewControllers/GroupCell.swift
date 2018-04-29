//
//  GroupCell.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    var group: Group!
    @IBOutlet weak var groupNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
