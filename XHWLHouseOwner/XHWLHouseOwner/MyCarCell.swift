//
//  MyCarCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/6.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyCarCell: UITableViewCell {
    @IBOutlet weak var carPicIV: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var plateNum: UILabel!
    @IBOutlet weak var color: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
