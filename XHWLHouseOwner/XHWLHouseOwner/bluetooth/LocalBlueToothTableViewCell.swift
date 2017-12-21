//
//  LocalBlueToothTableViewCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/19.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class LocalBlueToothTableViewCell: UITableViewCell {
    @IBOutlet weak var localDeviceName: UILabel!
    @IBOutlet weak var localOpenDoorBtn: UIButton!
    var getWhcihCellBlock: (LocalBlueToothTableViewCell)->() = {_ in
    }

    
    @IBAction func localOpenDoorBtnClicked(_ sender: UIButton) {
        self.getWhcihCellBlock(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
