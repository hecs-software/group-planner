//
//  ResultCell.swift
//  group-planner
//
//  Created by Christopher Guan on 5/4/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI

class ResultCell: UITableViewCell {
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkMarkView: UIImageView!
    
    var user: User? {
        didSet {
            nameLabel.text = user!.name
            profileImageView.file = user!.profilePicture
            profileImageView.loadInBackground()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setCheckmarkSelected(isSelected)
        }
    }
    
    var laidoutSubviews: Bool = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        checkMarkView.isHidden = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !laidoutSubviews {
            let width = profileImageView.frame.width
            profileImageView.layer.cornerRadius = width/2
            laidoutSubviews = true
        }
    }
    
    
    func setCheckmarkSelected(_ checked: Bool) {
        if checked {
            checkMarkView.isHidden = false
        }
        else {
            checkMarkView.isHidden = true
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
