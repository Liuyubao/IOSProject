//
//  XHWLRoomModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/9.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLRoomModel: NSObject {
    var id:String = ""
    var sysUnit:XHWLUnitModel = XHWLUnitModel()
    var name:String = ""
    var code:String = ""
    var unitName:String = ""
    var buildingName  :String = ""
    var projectName: String = ""
    
    func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["sysUnit":XHWLUnitModel.self] // [JZMJewelryCategoryModel class]
    }
}
