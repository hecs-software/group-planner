//
//  NotificationCell.swift
//  group-planner
//
//  Created by Hoang on 5/14/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    
    var laidoutSubviews: Bool = false
    
    weak var delegate: NotificationCellDelegate? = nil
    
    var groupInv: GroupInvitation? {
        didSet {
            let name = groupInv!.requester.name
            let groupName = groupInv!.group.name
            notificationTextLabel.text = "\(name) has invited you to \(groupName)"
            
            profileImageView.file = groupInv!.requester.profilePicture
            profileImageView.loadInBackground()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        acceptButton.layer.cornerRadius = 10.0
        acceptButton.layer.borderWidth = 1.0
        acceptButton.layer.borderColor = UIColor.black.cgColor
        
        declineButton.layer.borderWidth = 1.0
        declineButton.layer.borderColor = UIColor.black.cgColor
        declineButton.layer.cornerRadius = 10.0
        
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        delegate?.acceptedInvitation(groupInvitation: self.groupInv!)
    }
    
    
    @IBAction func onClickDecline(_ sender: UIButton) {
        delegate?.declinedInvitation(groupInvitation: self.groupInv!)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidoutSubviews {
            let width = profileImageView.frame.width
            profileImageView.layer.cornerRadius = width / 2
            laidoutSubviews = true
        }
    }
}


protocol NotificationCellDelegate: class {
    func acceptedInvitation(groupInvitation inv: GroupInvitation)
    func declinedInvitation(groupInvitation inv: GroupInvitation)
}
