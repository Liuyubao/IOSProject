//
//  MyHouseCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyHouseCell: UITableViewCell {
    
    
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var buildingName: UILabel!
    @IBOutlet weak var unitName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
