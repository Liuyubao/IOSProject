//
//  XHWLNetwork.swift
//  XHWLHouseManager
//
//  Created by admin on 2017/9/17.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

@objc protocol XHWLNetworkDelegate:NSObjectProtocol {

    @objc func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject])
    @objc func requestFail(_ requestKey:NSInteger, _ error:NSError)
    @objc optional func requestCancel(_ requestKey:NSInteger)
    @objc optional func requestError(_ requestKey:NSInteger, _ message:String)
    //请求成功返回错误字段为  Type = E
    @objc optional func requestSuccessWithTypeE(_ requestKey:NSInteger)
}

class XHWLNetwork: NSObject, XHWLHttpToolDelegate {
    weak var delegate:XHWLNetworkDelegate?
    
    // 单例
    class var shared: XHWLNetwork {
        struct Static {
            static let instance = XHWLNetwork()
        }
        return Static.instance
    }
    
    func superWithLoadData(_ parameters:Any, _ requestKey:XHWLRequestKeyID, _ method:HTTPMethod) {
        changeStatus({ (isReach) in
//            XHMLProgressHUD.shared.show()
            if isReach == false {
                "网络不可用".ext_debugPrintAndHint()
            } else {
                let request = XHWLHttpTool()
                request.initWithKey(requestKey, self)
                request.validTime = 1200
                if method == .get {
                    request.getHttpTool(parameters as! NSArray)
                } else {
                    request.postHttpTool(parameters as! Parameters)
                }
            }
        })
    }
    
    func superWithUploadImage(_ parameters:NSDictionary, _ requestKey:XHWLRequestKeyID, _ data:[Data], _ name:[String]) {
        changeStatus({ (isReach) in
//            XHMLProgressHUD.shared.show()
            if isReach == false {
                "网络不可用".ext_debugPrintAndHint()
            } else {
                let request = XHWLHttpTool()
                request.initWithKey(requestKey, self)
                request.validTime = 1200
                request.uploadHttpTool(parameters as! [String : String], data, name)
            }
        })
        
    }
    
//    // 登录
//    func getLoginClick(_ parameters:NSArray, _ delegate:XHWLNetworkDelegate) {
//        
//        self.delegate = delegate;
//        superWithLoadData(parameters, .XHWL_LOGIN, .get)
//    }
    
    
    
    
    //保存开门记录post
    func postSaveEntryLogBtnClicked(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        blueToothOrginName 	string 	是（蓝牙开门）/否（远程开门） 	蓝牙原始名称
        //        blueToothCustomName 	string 	是（蓝牙开门）/否（远程开门） 	蓝牙自定义名称
        //        yzId 	string 	是 	业主账户ID
        //        reqId 	string 	是（远程开门）/否（蓝牙开门） 	请求代码(随意)
        //        upid 	string 	是（远程开门）/否（蓝牙开门） 	项目唯一编号
        //        doorId 	string 	是 	门ID 蓝牙mac
        //        openTime 	string 	是 	开门时间 "yyy-MM-dd HH:mm:ss"
        //        type 	string 	是 	开门类型（bluetooth:蓝牙开门；remotion:远程开门）
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_SAVEENTRYLOG, .post)
    }
    
    // 获取开门记录get
    func getGetEntryLogBtnClicked(_ parameters:NSArray, _ delegate:XHWLNetworkDelegate) {
        //        token 	string 	是 	用户唯一凭证
        
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_GETENTRYLOG, .get)
    }
    
    // 扫一扫获取设备信息post
    func postScanResult(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        token     string     是     用户唯一凭证
        //        code     string     是     被扫描物的唯一标识（前端从二维码拆分得到值）
        //        type     string     是     扫描物类型（前端从二维码拆分得到值，设备type=equipment,园林绿植type=plant）
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_SCAN, .post)
    }
    
    // 上传蓝牙绑卡设备记录post
    func postBluetoothUpload(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        accountId     string     是     accountId
        //        identity     string     是     用户身份（业主端传：yz,物业端传：wy）
        //        systemType     string     是     手机系统类型，安卓：android，苹果：ios
        //        currentCardStr     string     是     cardNo
        //        name     string     是     蓝牙设备名称
        //        address     string     是     设备mac地址
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_BLUETOOTHUPLOAD, .post)
    }
    
    // 获取蓝牙绑卡设备记录get
    func getBluetoothRecord(_ parameters:NSArray, _ delegate:XHWLNetworkDelegate) {
        //        token     string     是     用户唯一凭证
        
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_GETBLUETOOTH, .get)
    }
    
    // 删除蓝牙绑卡设备记录post
    func postDeleteBluetooth(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        address     string     是     mac地址
        //        accountId     string     是     用户id
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_DELETEBLUETOOTH, .post)
    }
    
    // 推送消息给用户post
    func postJPushMsg(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        alias     string     是     推送对象别名（即对方号码）
        //        title     string      是       
        //        msg     string     是     推送到对方的提示消息
        //        pushToWebMsg     string     是     云对讲通讯相关消息（包含谁向谁发起对讲，进入某个房间号）
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_JPUSHMSG, .post)
    }
    
    // 退出登录post
    func postLogout(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        token     string     是     用户唯一凭证
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_LOGOUT, .post)
    }
    
    // 获取公区门禁列表post
    func postPublicDoorList(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        projectId     string     是     项目ID
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_GETPUBLICDOORLIST, .post)
    }

    // 登录post
    func postLogin(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        projectId     string     是     项目ID
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_LOGIN, .post)
    }
    
    // 心情天气post
    func postHeartWeather(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        code     string     是     今天天气的id
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_HEARTWEATHER, .post)
    }
    
    // 获取客服列表post
    func postServiceList(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        projectId     string     是     项目Id
        //        token     string     是     用户token
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_SERVICELIST, .post)
    }
    
    // 处理访客登记post
    func postVisitorReply(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        yzAlias     string     否     业主号码（推送别名）
        //        wyAlias     string     是     门岗号码（推送别名）
        //        yzOperator     string     是     业主操作类型（拒绝云对讲:refuse,同意访客：y,拒绝访客：n）
        //        msg     string     是     推送提示消息
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_VISITORREPLY, .post)
    }
    
    // 锦阳公馆开门post
    func postOpenJYDoor(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        token     string     是     用户唯一凭证
        //        doorID     string     是     门ID（从已有接口获取的长春锦阳公馆D地块相关参数）
        //        serverGuid     string     是     serverGuid（从已有接口获取的长春锦阳公馆D地块相关参数）
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_OPENJYDOOR, .post)
    }
    
    // 通过微信授权登录post
    func postWechatLogin(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        openId     string     是     微信唯一标识
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_WECHATLOGIN, .post)
    }
    
    // 绑定微信，获取手机验证码post
    func postWechatVeriCode(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_WECHATGETVERICODE, .post)
    }
    
    // 微信绑定验证验证码post
    func postTestWechatVeriCode(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        //        verificatCode     string     是    验证码
        //        openId     string     是     微信唯一标识
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_TESTVERICODE, .post)
    }
    
    // 微信登录时注册用户post
    func postWechatRegisterUser(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        //        password     string     是     密码
        //        openId     string     是     微信唯一标识
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_WECHATREGISTERUSER, .post)
    }
    
    // 绑定微信or解绑post
    func postBindWechat(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        id     string     是     登录账号id
        //        openId     string     否    微信唯一标识，绑定时传，解绑时不传
        //        nickName     string     否    微信昵称，绑定时传，解绑时不传
        //        imageUrl     string     否    微信头像，绑定时传，解绑时不传
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_BINDWECHAT, .post)
    }
    
    // 获取验证码post
    func postVeriCode(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_GETVERICODE, .post)
    }
    
    // 验证验证码post
    func postTestPhoneVeriCode(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        //        verificatCode     string     是     验证码
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_TESTPHONEVERICODE, .post)
    }
    
    // 验证码修改密码post
    func postChangePsw(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        telephone     string     是     手机号码
        //        newPsw     string     是     新密码
        //        verificatCode     string     是     验证码
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_CHANGEPSW, .post)
    }
    
    //获取附属账号post
    func postAccountList(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        token     string     是     用户登录token
        //        ownerId     string     是     业主登录id
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_ACCOUNTLIST, .post)
    }
    
    //添加附属账号post
    func postAddAccount(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        token     string     是     业主登录token
        //        name     string     是     附属账号人姓名
        //        type     string     是     附属账号类型（家人：family，租户：renter）
        //        telephone     string     是     附属账号（手机号码）
        //        identity     string     是     身份证号码
        //        rights     string     是     赋予附属账号的权限（包含项目及项目对应的功能权限），为数组格式的字符串
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_ADDACCOUNT, .post)
    }
    
    //删除附属账号post
    func postDeleteAccount(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        attachedTelephone     string     是     附属账号（手机号码）
        //        token     string     是     业主登录token
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_DELETEACCOUNT, .post)
    }
    
    //设置附属账号状态post
    func postSetAccountState(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        stat     string     是     正常：N，停用：D
        //        attachedTelephone     string     是     附属账号（手机号码）
        //        token     string     是     业主登录token
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_SETACCOUNTSTATE, .post)
    }
    
    // 获取野狗云token post
    func postWilddogTokenClick(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate) {
        
        self.delegate = delegate;
        superWithLoadData(parameters, .XHWL_WILDDOGTOKEN, .post)
    }
    
    // 获取用户授权门禁列表 post
    func postGetAllDoors(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate) {
        //        projectCode     string     是     项目编号
        //        token         string          是     token
        //        userName     string     是     用户名
        //        phone     string     是     用户手机
        self.delegate = delegate;
        superWithLoadData(parameters, .XHWL_GETALLDOORS, .post)
    }
    
    //远程开门post
    func postRemoteOpenDoorBtnClicked(_ parameters:NSDictionary, _ delegate:XHWLNetworkDelegate){
        //        projectCode     string     是                 项目编号
        //        token         string     是                 token
        //        doorId         string     是                 门编号
        //        type             string     是                 开门类别(当家6 ，专家5， 平台2，优你家1)
        //        personId         string     是                 人员编号
        self.delegate = delegate
        superWithLoadData(parameters, .XHWL_REMOTEOPENDOOR, .post)
    }
    
    // MARK: - XHWLHttpToolDelegate
    func requestSuccess(_ requestKey:NSInteger, result request:Any) {
       self.delegate?.requestSuccess(requestKey, request as! [String : AnyObject])
    }
    
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        self.delegate?.requestFail(requestKey, error)
    }
    
    func changeStatus(_ block:@escaping ((Bool)->())) {
        let networkManager:NetworkReachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")!
        // 开始监听
        networkManager.startListening()
        // 检测网络连接状态
        if networkManager.isReachable {
            print("网络连接：可用")
        } else {
            "网络不可用".ext_debugPrintAndHint()
            print("网络连接：不可用")
        }
        
        // 检测网络类型
        networkManager.listener = { status in
            switch status {
            case .notReachable:
                print("无网络连接")
                block(false)
                break
            case .unknown:
                print("未知网络")
                block(false)
                break
            case .reachable(.ethernetOrWiFi):
                print("WIFI")
                block(true)
                break
            case .reachable(.wwan):
                print("手机自带网络")
                block(true)
                break
            }
        }
    }
    
}
