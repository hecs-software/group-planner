//
//  GroupCell.swift
//  group-planner
//
//  Created by Christopher Guan on 4/29/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import UIKit
import ParseUI

class GroupCell: UITableViewCell, UICollectionViewDataSource {
    
    
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
