//
//  MyAccountCell.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyAccountCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var telephoneLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var indicateColor: UIImageView!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
//    var state: Bool = true{
//        willSet{
//            if newValue{//新值为启用
//                self.indicateColor.image = UIImage(named: "PersonalCenter_greenPoint")
//            }else{
//                self.indicateColor.image = UIImage(named: "PersonalCenter_redPoint")
//            }
//        }
//    }
    
    var setWhichCellClosure: (MyAccountCell)->() = {curCell in
    }
    var deleteWhichCellClosure: (MyAccountCell)->() = {curCell in
    }
    
    @IBAction func stopBtnClicked(_ sender: UIButton) {
        setWhichCellClosure(self)
    }
    
    @IBAction func deleteBtnClicked(_ sender: UIButton) {
        deleteWhichCellClosure(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
