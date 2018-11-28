//
//  ProgressCell.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-10.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var measureLabel: UILabel!
    
    
    func setCell(date: String, range: String){
        
        dateLabel.text = date
        measureLabel.text = range
        
    }
    
    
}
