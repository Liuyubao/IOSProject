//
//  XHWLUnitModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLUnitModel: NSObject {
    var id:String = ""
    var sysBuilding:XHWLBuildingModel = XHWLBuildingModel()
    var name:String = ""
    var code:String = ""
    var address:String = ""
    var buildingName  :String = ""
    var projectName: String = ""
    
    func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["building":XHWLBuildingModel.self] // [JZMJewelryCategoryModel class]
    }
}
