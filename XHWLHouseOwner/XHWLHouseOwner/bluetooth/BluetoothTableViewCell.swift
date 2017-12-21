//
//  BluetoothTableViewCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/19.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class BluetoothTableViewCell: UITableViewCell {
    @IBOutlet weak var bluetoothName: UILabel!
    @IBOutlet weak var smallCheck: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
