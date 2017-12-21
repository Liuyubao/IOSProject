//
//  XHWLDeviceRecordModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/8.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLDeviceRecordModel: NSObject {
    var name: String = ""
    var mac: String = ""
    var cardNo: String = ""
    
    
    init(_ name: String,_ mac: String) {
        self.name = name
        self.mac = mac
    }
    
    init(_ newRecord: XHWLDeviceRecordModel){
        self.name = newRecord.name
        self.mac = newRecord.mac
        self.cardNo = newRecord.cardNo
    }
        
    
}
