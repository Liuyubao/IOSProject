//
//  Configurations.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/4.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import Foundation
import UIKit

var wechatClickedSource = 1 //1:app登录界面微信按钮 2:app内部绑定微信按钮

//微信第三方参数
let WX_APPID:String = "wxc5e20b28cf976b5c"
let WX_APPSecret:String = "57039eb96054557def20c354f21a709c"

//"10092150" // 应用编号
let WeatherKey:String = "3e6338eef8c947dd89f4ffebbf580778"
//野狗云appId
let WilddogAuthAppID = "wd5576019203pqpfqi"

// 野狗云
let VIDEO_APPID:String = "wd4554034089toorht"
let SYNC_APPID:String = "wd5576019203pqpfqi"


//from airong
//#pragma mark --登录及地址界面

let MSP_ADDRESS : String = "202.105.104.109"
let MSP_PORT  : String   = "443"
let MSP_USERNAME: String = "yanfa"
let MSP_PASSWORD: String = "yf1234567"

let jPushAppKey: String = "3a74312a795793257ac2ddbb"
let channel: String = "Publish channel"



//let DEFAULT_MSP_PORT:String =  "443"
//let PUSH_SERVER_ADDRESS:String = "60.191.22.218"
//let PUSH_SERVER_PORT:String = "8443"


// MARK: -- 颜色

let mainColor:UIColor = UIColor().colorWithHexString(colorStr: "#0abfab") //主色调
let color_c6c6c6:UIColor = UIColor().colorWithHexString(colorStr: "#c6c6c6") // 默认placholder颜色
let color_f2f2f2:UIColor = UIColor().colorWithHexString(colorStr: "#f2f2f2") // 线的颜色
let color_f9f9f9:UIColor = UIColor().colorWithHexString(colorStr: "#f9f9f9") // 文字的颜色
let color_5284d6:UIColor = UIColor().colorWithHexString(colorStr: "#5284d6") // 蓝色的文字
let color_01f0ff:UIColor = UIColor().colorWithHexString(colorStr: "#01f0ff") //主色调
let color_7a9198:UIColor = UIColor().colorWithHexString(colorStr: "#7a9198") //主色调
let color_09fbfe:UIColor = UIColor().colorWithHexString(colorStr: "#09fbfe") //主色调
let color_c8e5f0:UIColor = UIColor().colorWithHexString(colorStr: "#c8e5f0") // 默认placholder颜色
let color_58e9f3:UIColor = UIColor().colorWithHexString(colorStr: "#58e9f3") // 蓝色的文字
let color_51ebfd:UIColor = UIColor().colorWithHexString(colorStr: "#51ebfd") // 蓝色的文字
let color_328bfe:UIColor = UIColor().colorWithHexString(colorStr: "#328bfe") // 蓝色的文字
let color_d724d9:UIColor = UIColor().colorWithHexString(colorStr: "#d724d9") // 蓝色的文字


// MARK: -- 字体

let font_14:UIFont = UIFont.systemFont(ofSize: 14)
let font_15:UIFont = UIFont.systemFont(ofSize: 15)
let font_16:UIFont = UIFont.systemFont(ofSize: 16)
let font_17:UIFont = UIFont.systemFont(ofSize: 17)
let font_18:UIFont = UIFont.systemFont(ofSize: 18)


let Screen_height:CGFloat = UIScreen.main.bounds.size.height
let Screen_width:CGFloat = UIScreen.main.bounds.size.width

// MARK: -- 创建分割线

/**
 给一个视图 创建添加 一条分割线 高度 : HJSpaceLineHeight
 
 - parameter view:  需要添加的视图
 - parameter color: 颜色 可选
 
 - returns: 分割线view
 */
func SpaceLineSetup(view:UIView, color:UIColor? = nil) ->UIView {
    
    let spaceLine = UIView()
    
    spaceLine.backgroundColor = color != nil ? color : UIColor.lightGray
    
    view.addSubview(spaceLine)
    
    return spaceLine
}
