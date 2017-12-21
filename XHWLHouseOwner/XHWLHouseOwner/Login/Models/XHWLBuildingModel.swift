//
//  XHWLBuildingModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLBuildingModel: NSObject {
    var id:String = ""
    var project:XHWLProjectModel = XHWLProjectModel()
    var name:String = ""
    var code:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var projectName:String = ""
    
    func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["project":XHWLProjectModel.self] // [JZMJewelryCategoryModel class]
    }
}
