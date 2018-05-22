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
    @IBOutlet weak var acceptIndicator: UIActivityIndicatorView!
    @IBOutlet weak var declineIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cellContainer: RoundedContainer!
    
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
        
        cellContainer.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.setNeedsLayout()
        self.layoutSubviews()
    }
    
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        delegate?.acceptedInvitation(sender: self, groupInvitation: self.groupInv!)
    }
    
    
    @IBAction func onClickDecline(_ sender: UIButton) {
        delegate?.declinedInvitation(sender: self, groupInvitation: self.groupInv!)
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
    func acceptedInvitation(sender: NotificationCell, groupInvitation inv: GroupInvitation)
    func declinedInvitation(sender: NotificationCell, groupInvitation inv: GroupInvitation)
}
