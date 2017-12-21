//
//  SingleMonitorView.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/6.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class SingleMonitorView: UIView {
    var monitorImg: UIImageView!    //监控的静态img
    var monitorName: UILabel!   //监控的地点名称
    var cameraSyscode: String!  //预览监控的sysCode
    
    func setValues(img:UIImage, name: String, code:String) {
        monitorImg.image = img
        monitorName.text = name
        cameraSyscode = code
        
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
//        self.backgroundColor = UIColor.black
        
//        monitorName.lineBreakMode
        
        monitorImg = UIImageView()
        monitorName = UILabel()
        monitorImg.backgroundColor = UIColor.black
        monitorImg.contentMode = .scaleAspectFit
        self.addSubview(monitorImg)
        self.addSubview(monitorName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monitorName.frame = CGRect(x: (self.frame.width-120)/2, y: self.frame.height-30, width: 120, height: 15)
        monitorName.adjustsFontSizeToFitWidth = true
        monitorName.textAlignment = .center
        monitorImg.frame = CGRect(x: 5, y: 5, width: self.frame.width-10, height: self.frame.height-60)
        monitorName.font = font_14
        monitorName.numberOfLines = 0
        
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
