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
        }
    }
    
    @objc func clickedOnPlus(_ tapGesture: UITapGestureRecognizer) {
        print("clicked on plus")
    }
    
    @objc func clickedOnProfile(_ tapGesture: UITapGestureRecognizer) {
        print("clicked on profile")
    }
}
