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
    
    var user: User? {
        didSet {
            nameLabel.text = user!.name
            profileImageView.file = user!.profilePicture
            profileImageView.loadInBackground()
        }
    }
    
    var laidoutSubviews: Bool = false
    
    var profileImageView: PFImageView!
    var nameLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupProfileImageView()
        setupNameLabel()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func setupProfileImageView() {
        profileImageView = PFImageView()
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(profileImageView)
        
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
    
    func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10).isActive = true
        self.trailingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 30).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !laidoutSubviews {
            print(profileImageView.frame)
            let width = profileImageView.frame.width
            profileImageView.layer.cornerRadius = width/2
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
