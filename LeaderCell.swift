//
//  LeaderCell.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-24.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit

/*
 This class sets the cells of the leaderboard table.
 */

class LeaderCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    func setleaderCell(name:String, rank: String, totalpoints: String){
        
        rankLabel.text = rank
        totalLabel.text = totalpoints
        nameLabel.text = name
        
    }
    
}
