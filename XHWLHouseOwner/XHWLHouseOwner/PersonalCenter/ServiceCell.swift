//
//  ServiceCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/20.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class ServiceCell: UITableViewCell {
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var cloudTalkingBtn: UIButton!
    @IBOutlet weak var servicePhoneCallBtn: UIButton!
    var clickWhichCloud: (ServiceCell)->() = {_ in}
    var clickWhichPhone: (ServiceCell)->() = {_ in}
    
    @IBAction func clouidTalkingBtnClicked(_ sender: UIButton) {
        self.clickWhichCloud(self)
    }
    
    @IBAction func phoneBtnClicked(_ sender: UIButton) {
        self.clickWhichPhone(self)
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
