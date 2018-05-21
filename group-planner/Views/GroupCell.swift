//
//  GroupCell.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI
import Pastel

class GroupCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var cellContainer: UIView!
    
    @IBOutlet weak var groupNameLabel: UILabel!

    @IBOutlet weak var profileCarousel: ProfileCarousel!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    var group: Group! {
        didSet {
            groupNameLabel.text = group.name
            self.users = group.groupMembers
            profileCarousel.reloadData()
        }
    }
    
    
    var users: [User] = [User]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = profileCarousel.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: 60, height: 60)
        profileCarousel.dataSource = self
        profileCarousel.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        
        
        
        cellContainer.cornerRadiusWithShadow(radius: 30, color:UIColor(r: 190, g: 229, b:252, a: 0.8))
        cellContainer.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        profileCarousel.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
 
        profileCarousel.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePicCell", for: indexPath) as! ProfilePictureCell
        let user = users[indexPath.row]
        
        cell.user = user
        cell.isPlusButton = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    
}
