//
//  XHWLUserModel.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLUserModel: NSObject {
    var id:String = ""
    var sysAccount:XHWLAccountModel = XHWLAccountModel()
    var name:String = ""
    var code:String = ""
    var telephone:String = ""
    var identity:String = ""
    var sex:String = ""
    var isOwner:String = ""
    var sysAccountName:String = ""
    
    func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["sysAccount":XHWLAccountModel.self] // [JZMJewelryCategoryModel class]
    }
    
    
    
}
