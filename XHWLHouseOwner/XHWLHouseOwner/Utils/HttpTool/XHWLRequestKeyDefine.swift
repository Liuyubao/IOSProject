//
//  XHWLRequestKeyDefine.swift
//  XHWLHouseManager
//
//  Created by admin on 2017/9/17.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit

/**
 *  网络请求的业务ID，方便以后扩展功能模块
 */
enum XHWLRequestKeyID : NSInteger {
    case XHWL_NONE = 0
    case XHWL_LOGIN         // 登录
    
    case XHWL_REMOTEOPENDOOR      //远程开门
    case XHWL_SAVEENTRYLOG          //保存开门记录
    case XHWL_GETENTRYLOG           //获取开门记录
    case XHWL_SCAN                  //根据二维码返回信息
    case XHWL_BLUETOOTHUPLOAD       //上传蓝牙设备记录
    case XHWL_GETBLUETOOTH          //获取蓝牙设备记录
    case XHWL_DELETEBLUETOOTH       //删除蓝牙设备记录
    case XHWL_JPUSHMSG              //推送
    case XHWL_LOGOUT                //退出登录
    case XHWL_GETPUBLICDOORLIST     //获取公区门禁列表
    case XHWL_HEARTWEATHER          //心情天气
    case XHWL_SERVICELIST          //获取客服列表
    case XHWL_VISITORREPLY          //处理访客登记
    case XHWL_OPENJYDOOR            //锦阳公馆开门
    case XHWL_WECHATLOGIN           //通过微信授权登录app
    case XHWL_WECHATGETVERICODE     //绑定微信获取验证码
    case XHWL_TESTVERICODE          //绑定微信验证验证码
    case XHWL_WECHATREGISTERUSER    //微信登录时注册用户
    case XHWL_BINDWECHAT            //绑定or解绑微信
    
    case XHWL_GETVERICODE           //获取验证码
    case XHWL_TESTPHONEVERICODE     //验证验证码
    case XHWL_CHANGEPSW             //验证码修改密码
    
    case XHWL_ACCOUNTLIST           //获取附属账号列表
    case XHWL_ADDACCOUNT            //添加附属账号
    case XHWL_DELETEACCOUNT         //注销附属账号
    case XHWL_SETACCOUNTSTATE       //设置附属账号状态
    
}


class XHWLRequestKeyDefine: NSObject {
    
    var trandIdDict:NSDictionary!
    
    // 单例
    class var shared: XHWLRequestKeyDefine {
        struct Static {
            static let instance = XHWLRequestKeyDefine()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        initWebServiceDomain()
    }
    
    func initWebServiceDomain() {
        self.trandIdDict = [
            XHWLRequestKeyID.XHWL_NONE: "",
            XHWLRequestKeyID.XHWL_LOGIN:"appBase/login",                     // 登录
            
            XHWLRequestKeyID.XHWL_REMOTEOPENDOOR:"appBusiness/iot/entrance/openDoor",    //远程开门
            XHWLRequestKeyID.XHWL_SAVEENTRYLOG:"appBusiness/iot/entryLog",    //保存开门记录
            XHWLRequestKeyID.XHWL_GETENTRYLOG:"appBusiness/iot/entryLog",  //获取开门记录
            XHWLRequestKeyID.XHWL_SCAN:"appBusiness/qrcode/scan",           //根据二维码返回信息
            XHWLRequestKeyID.XHWL_BLUETOOTHUPLOAD:"wyBusiness/bluetoothCard/bind",            //上传蓝牙设备记录
            XHWLRequestKeyID.XHWL_GETBLUETOOTH:"wyBusiness/bluetoothCard",           //获取蓝牙设备记录
            XHWLRequestKeyID.XHWL_DELETEBLUETOOTH:"wyBusiness/delBluetoothCard",           //删除蓝牙设备记录
            XHWLRequestKeyID.XHWL_JPUSHMSG:"appBase/jgPush",                                 //推送
            XHWLRequestKeyID.XHWL_LOGOUT:"appBase/appLogout",                                 //退出登录
            XHWLRequestKeyID.XHWL_GETPUBLICDOORLIST:"appBusiness/iot/entrance/getPublicDoorList",     //获取公区门禁列表
            XHWLRequestKeyID.XHWL_HEARTWEATHER:"appBusiness/weather",    //心情天气
            XHWLRequestKeyID.XHWL_SERVICELIST:"appBusiness/customerService",     //获取客服列表
            XHWLRequestKeyID.XHWL_VISITORREPLY:"wyBusiness/visitor/regist/jgPush",   //处理访客登记
            XHWLRequestKeyID.XHWL_OPENJYDOOR:"/appBusiness/openDoorForCHJY",   //锦阳公馆开门
            XHWLRequestKeyID.XHWL_WECHATLOGIN:"/appBase/loginByWeChat",   //通过微信授权登录
            XHWLRequestKeyID.XHWL_WECHATGETVERICODE:"/appBase/weChat/getVerifyCode",   //绑定微信获取验证码
            XHWLRequestKeyID.XHWL_TESTVERICODE:"/appBase/weChat/testVerifyCode",   //绑定微信验证验证码
            XHWLRequestKeyID.XHWL_WECHATREGISTERUSER:"/appBase/register/wechat",   //微信登录时注册用户
            XHWLRequestKeyID.XHWL_BINDWECHAT:"/appBase/bindWeChat",              //绑定微信or解绑
            XHWLRequestKeyID.XHWL_GETVERICODE:"/appBase/register/getVerificatCode",              //获取验证码
            XHWLRequestKeyID.XHWL_TESTPHONEVERICODE:"/appBase/register/testVerificatCode",        //验证验证码
            XHWLRequestKeyID.XHWL_CHANGEPSW:"/appBase/modifyPassword/forgetOldPsw",              //验证码修改密
            XHWLRequestKeyID.XHWL_ACCOUNTLIST:"/appBusiness/ownerRenter/getList",               //获取附属账号列表
            XHWLRequestKeyID.XHWL_ADDACCOUNT:"/appBusiness/ownerRenter/add",                    //添加附属账号
            XHWLRequestKeyID.XHWL_DELETEACCOUNT:"/appBusiness/ownerRenter/delete",              //注销附属账号
            XHWLRequestKeyID.XHWL_SETACCOUNTSTATE:"/appBusiness/ownerRenter/updateStat"         //设置附属账号状态
        ]
    }
}
