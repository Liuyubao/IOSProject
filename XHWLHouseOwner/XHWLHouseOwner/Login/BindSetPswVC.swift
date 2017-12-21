//
//  BindSetPswVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class BindSetPswVC: UIViewController, XHWLNetworkDelegate {
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var conformPswTF: UITextField!
    @IBOutlet weak var conformRePswTF: UITextField!
    var telephone = ""          //暂存手机号码
    
    //确定按钮点击事件
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //键盘隐藏
        self.view.endEditing(true)
        //conformPswTF是否为空
        if self.conformPswTF.text == ""{
            "密码不能为空".ext_debugPrintAndHint()
            return
        }
        //conformRePswTF是否为空
        if self.conformRePswTF.text == ""{
            "确认密码不能为空".ext_debugPrintAndHint()
            return
        }
        //conformPswTF和conformRePswTF值是否相同
        if self.conformPswTF.text != self.conformRePswTF.text{
            "两次输入密码不同".ext_debugPrintAndHint()
            return
        }
        
        //传给testVerificatCode接口的参数
        let openId = UserDefaults.standard.object(forKey: "openId") as! String
        //取出user的信息
        let params = ["telephone":self.telephone, "password":self.conformPswTF.text as! String, "openId":openId]
        XHWLNetwork.shared.postChangePsw(params as NSDictionary, self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //登录返回参数处理
    func onLoginBtnCLicked(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            let result = response["result"] as! NSDictionary
            //获取user
            let yzUser = result["sysUser"] as? NSDictionary
            
            //未认证用户
            if yzUser?.count == 0{
                "您的账号未认证，无法登陆！".ext_debugPrintAndHint()
                return
            }
            
            //将用户信息存入沙盒
            let yzUserData = yzUser?.mj_JSONData() as! NSData
            UserDefaults.standard.set(yzUserData, forKey: "user")
            
            //将别名上传
            JPUSHService.setAlias(yzUser!["sysAccountName"] as! String, completion: { (iResCode, iAlias, seq) in
                if seq == 0 {
                    "上传别名成功".ext_debugPrintAndHint()
                }
            }, seq: 0)
            
            //保存roomList到沙盒
            if let roomList:NSArray = result["roomList"] as? NSArray{
                let roomListModelData:NSData = roomList.mj_JSONData()! as NSData
                UserDefaults.standard.set(roomListModelData, forKey: "roomList")
            }
            
            if let projectList:NSArray = result["projectList"] as? NSArray{
                let modelData3:NSData = projectList.mj_JSONData()! as NSData
                UserDefaults.standard.set(modelData3, forKey: "projectList")
            }
            
            //初始化curInfoModel参数
            var curInfoModel = XHWLCurrentInfoModel()
            curInfoModel.isFirstToSpace = true
            curInfoModel.isFirstToFourFuncs = true
            
            //从沙盒中加载数据
            let projectListData = UserDefaults.standard.object(forKey: "projectList") as? NSData
            let projectListArray = XHWLProjectModel.mj_objectArray(withKeyValuesArray: projectListData?.mj_JSONObject()) as? NSArray
            if projectListArray?.count != 0{
                curInfoModel.curProject = projectListArray![0] as! XHWLProjectModel
            }else{
                "您的账号未认证，无法登陆！".ext_debugPrintAndHint()
                return
            }
            
            let curInfoData = curInfoModel.mj_JSONData() as? NSData
            UserDefaults.standard.set(curInfoData, forKey: "curInfo")
            UserDefaults.standard.synchronize()
            
            //            self.loginBtn.startL()
            let successfullyVC:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC"))!
            //                successfullyVC.transitioningDelegate = self
            successfullyVC.modalTransitionStyle = .crossDissolve
            self.present(successfullyVC, animated: true, completion: nil)
            self.view.window?.rootViewController = successfullyVC
            
        }else{
            (response["message"] as! String).ext_debugPrintAndHint()
            switch(response["errorCode"] as! Int){
            case 114:
                //用户名不存在
                AlertMessage.showAlertMessage(vc: self, alertMessage: "用户名不存在！", duration: 1)
                break
            case 113:
                //用户名密码不正确，请重新输入
                AlertMessage.showAlertMessage(vc: self, alertMessage: "用户名密码不正确，请重新输入！", duration: 1)
                break
            default:
                break
            }
        }
    }
    
    //通过微信授权登录
    func onWechatBtnClicked(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            onLoginBtnCLicked(response)
            break
        case 114:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BindSendMsgVC") as! BindSendMsgVC
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            ("该微信没有绑定任何注册用户").ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_WECHATREGISTERUSER.rawValue:
            switch response["errorCode"] as! Int{
            case 201, 111:
                (response["message"] as! String).ext_debugPrintAndHint()
                break
            case 200:
                "注册成功".ext_debugPrintAndHint()
                //传给testVerificatCode接口的参数
                let openId = UserDefaults.standard.object(forKey: "openId") as! String
                let params = ["openId":openId]
                XHWLNetwork.shared.postWechatLogin(params as NSDictionary, self)
                break
            default:
                break
            }
            break
        case XHWLRequestKeyID.XHWL_WECHATLOGIN.rawValue:
            onWechatBtnClicked(response)
            break
        default:
            break
        }
    }
    
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        print("&&&&wechatLogin&&&&", error)
    }
    
}
