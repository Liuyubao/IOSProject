//
//  PayHistoryCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/11.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class PayHistoryCell: UITableViewCell {
    @IBOutlet weak var carPlate: UILabel!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var payFee: UILabel!
    @IBOutlet weak var payTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
