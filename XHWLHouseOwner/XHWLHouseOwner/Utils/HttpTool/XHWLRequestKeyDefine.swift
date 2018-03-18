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
    
    case XHWL_WILDDOGTOKEN          //获取野狗云token
    case XHWL_GETALLDOORS           //获取用户授权门禁列表
    case XHWL_REMOTEOPENDOOR      //远程开门
    case XHWL_UPDATEINFO            //更新个人信息
    case XHWL_NEWLESTVERSION        //得到最新版本号
    case XHWL_OPENDOORBYCALL        //通话时远程开门
    
    case XHWL_GETVERIFICATCODEBYTYPE    //获取短信验证码（新）
    case XHWL_VERICODELOGIN             //短信验证码登录
    case XHWL_GETCLOUDTALKHISTORY                //获取云对讲记录
    case XHWL_UPLOADCLOUDTALKHISTORY             //上传云对讲记录
    case XHWL_DELETECLOUDTALKHISTORY             //删除云对讲记录
    
    case XHWL_GETUSERINFOBYTOKEN                //通过token获取个人信息
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
            XHWLRequestKeyID.XHWL_LOGIN:"v1/appBase/login",                     // 登录
            XHWLRequestKeyID.XHWL_SAVEENTRYLOG:"v1/appBusiness/iot/entryLog",    //保存开门记录
            XHWLRequestKeyID.XHWL_GETENTRYLOG:"v1/appBusiness/iot/entryLog",  //获取开门记录
            XHWLRequestKeyID.XHWL_SCAN:"v1/appBusiness/qrcode/scan",           //根据二维码返回信息
            XHWLRequestKeyID.XHWL_BLUETOOTHUPLOAD:"v1/wyBusiness/bluetoothCard/bind",            //上传蓝牙设备记录
            XHWLRequestKeyID.XHWL_GETBLUETOOTH:"v1/wyBusiness/bluetoothCard",           //获取蓝牙设备记录
            XHWLRequestKeyID.XHWL_DELETEBLUETOOTH:"v1/wyBusiness/delBluetoothCard",           //删除蓝牙设备记录
            XHWLRequestKeyID.XHWL_JPUSHMSG:"v1/appBase/jgPush",                                 //推送
            XHWLRequestKeyID.XHWL_LOGOUT:"v1/appBase/appLogout",                                 //退出登录
            XHWLRequestKeyID.XHWL_GETPUBLICDOORLIST:"v1/appBusiness/iot/entrance/getPublicDoorList",     //获取公区门禁列表
            XHWLRequestKeyID.XHWL_HEARTWEATHER:"v1/appBusiness/weather",    //心情天气
            XHWLRequestKeyID.XHWL_SERVICELIST:"v1/appBusiness/customerService",     //获取客服列表
            XHWLRequestKeyID.XHWL_VISITORREPLY:"v1/wyBusiness/visitor/regist/jgPush",   //处理访客登记
            XHWLRequestKeyID.XHWL_OPENJYDOOR:"v1/appBusiness/openDoorForCHJY",   //锦阳公馆开门
            XHWLRequestKeyID.XHWL_WECHATLOGIN:"v1/appBase/loginByWeChat",   //通过微信授权登录
            XHWLRequestKeyID.XHWL_WECHATGETVERICODE:"v1/appBase/weChat/getVerifyCode",   //绑定微信获取验证码
            XHWLRequestKeyID.XHWL_TESTVERICODE:"v1/appBase/weChat/testVerifyCode",   //绑定微信验证验证码
            XHWLRequestKeyID.XHWL_WECHATREGISTERUSER:"v1/appBase/register/wechat",   //微信登录时注册用户
            XHWLRequestKeyID.XHWL_BINDWECHAT:"v1/appBase/bindWeChat",              //绑定微信or解绑
            XHWLRequestKeyID.XHWL_GETVERICODE:"v1/appBase/register/getVerificatCode",              //获取验证码
            XHWLRequestKeyID.XHWL_TESTPHONEVERICODE:"v1/appBase/register/testVerificatCode",        //验证验证码
            XHWLRequestKeyID.XHWL_CHANGEPSW:"/v1/appBase/modifyPassword/forgetOldPsw",              //验证码修改密
            XHWLRequestKeyID.XHWL_ACCOUNTLIST:"/v1/appBusiness/ownerRenter/getList",               //获取附属账号列表
            XHWLRequestKeyID.XHWL_ADDACCOUNT:"/v1/appBusiness/ownerRenter/add",                    //添加附属账号
            XHWLRequestKeyID.XHWL_DELETEACCOUNT:"/v1/appBusiness/ownerRenter/delete",              //注销附属账号
            XHWLRequestKeyID.XHWL_SETACCOUNTSTATE:"/v1/appBusiness/ownerRenter/updateStat",         //设置附属账号状态
            XHWLRequestKeyID.XHWL_WILDDOGTOKEN:"/wilddog/getToken",                                 // 获取野狗云token
            XHWLRequestKeyID.XHWL_GETALLDOORS:"/openDoor/getDoorByPhone",                           // 获取野狗云token
            XHWLRequestKeyID.XHWL_REMOTEOPENDOOR:"/openDoor/openDoor",                              // 远程开门
            XHWLRequestKeyID.XHWL_UPDATEINFO:"/v1/appBase/updateUserInfo",                          // 更新个人信息
            XHWLRequestKeyID.XHWL_NEWLESTVERSION:"/version/getNewestVersion",                        // 得到最新版本号
            XHWLRequestKeyID.XHWL_OPENDOORBYCALL:"/doorMachine/openDoorByCall",                       //通话时远程开门
            XHWLRequestKeyID.XHWL_GETVERIFICATCODEBYTYPE:"/v1/appBase/getVerificatCodeByType",         //获取验证码(新)
            XHWLRequestKeyID.XHWL_VERICODELOGIN:"/v1/appBase/verifyCodeLogin",                          //短信验证码登录
            XHWLRequestKeyID.XHWL_GETCLOUDTALKHISTORY:"/v1/wyBusiness/talkingBack/history/get",        //获取云对讲记录
            XHWLRequestKeyID.XHWL_UPLOADCLOUDTALKHISTORY:"/v1/wyBusiness/talkingBack/history/add",      //上传云对讲记录
            XHWLRequestKeyID.XHWL_DELETECLOUDTALKHISTORY:"/v1/wyBusiness/talkingBack/history/delete",      //删除云对讲记录
            XHWLRequestKeyID.XHWL_GETUSERINFOBYTOKEN:"/v1/appBase/getUserInfoByToken"                      //通过token获取个人信息
        ]
    }
}
