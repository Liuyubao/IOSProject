//
//  XHWLCurrentInfoModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/7.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.

import UIKit

class XHWLCurrentInfoModel: NSObject {
    
    var curProject: XHWLProjectModel = XHWLProjectModel()
    var isFirstToSpace: Bool = true //是否第一次进入SpaceVC
    var isFirstToFourFuncs: Bool = true //是否第一次进入TabBar
    
    func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["curProject":XHWLProjectModel.self]
    }
}
