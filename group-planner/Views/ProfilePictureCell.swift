//
//  ProfilePictureCell.swift
//  group-planner
//
//  Created by Hoang on 5/13/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class ProfilePictureCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: PFImageView!
    
    var inGroupsDetailPage: Bool = false
    var profileSelected: Bool = true
    
    var user: User? {
        didSet {
            profileImageView.file = user!.profilePicture
            profileImageView.loadInBackground()
        }
    }
    
    var isPlusButton: Bool? {
        didSet {
            if isPlusButton! {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickedOnPlus))
                profileImageView.addGestureRecognizer(tapGesture)
            }
            else {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickedOnProfile))
                profileImageView.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    weak var delegate: ProfilePictureCellDelegate? = nil
    
    var laidoutSubviews: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !laidoutSubviews {
            let width = self.frame.width
            profileImageView.layer.cornerRadius = width/2
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
            laidoutSubviews = true
            
            if inGroupsDetailPage && !isPlusButton! {
                self.profileImageView.layer.borderWidth = 2.0
                self.profileImageView.layer.borderColor = UIColor.green.cgColor
            }
        }
    }
    
    @objc func clickedOnPlus(_ tapGesture: UITapGestureRecognizer) {
        delegate?.clickedOnPlus()
    }
    
    @objc func clickedOnProfile(_ tapGesture: UITapGestureRecognizer) {
        if !inGroupsDetailPage {return}
        if let user = User.current(),
            user.objectId! == self.user!.objectId! {return}
        
        profileSelected = !profileSelected
        if !profileSelected && !isPlusButton! {
            self.profileImageView.layer.borderWidth = 0
            delegate?.clickedOnProfile(userId: user!.objectId!, selected: profileSelected)
        }
        else if !isPlusButton! {
            self.profileImageView.layer.borderWidth = 2.0
            self.profileImageView.layer.borderColor = UIColor.green.cgColor
            delegate?.clickedOnProfile(userId: user!.objectId!, selected: profileSelected)
        }
    }
}


protocol ProfilePictureCellDelegate: class {
    func clickedOnProfile(userId: String, selected: Bool)
    func clickedOnPlus()
}



