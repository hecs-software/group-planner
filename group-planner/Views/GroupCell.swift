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

    @IBOutlet weak var profileCarousel: UICollectionView!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    var group: Group! {
        didSet {
            groupNameLabel.text = group.name
        }
        
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = profileCarousel.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: frame.width, height: frame.height / 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePicCell", for: indexPath)
        let users = group.groupMembers
        let user = users[indexPath.row]
        
        // TODO: set cell's picture
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return group.groupMembers.count
    }
}
