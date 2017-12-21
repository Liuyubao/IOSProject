//
//  BindSeneMsgVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class BindSendMsgVC: UIViewController, XHWLNetworkDelegate, UITextFieldDelegate{
    @IBOutlet weak var registerPhoneNumberTF: UITextField!
    @IBOutlet weak var registerVeriTF: UITextField!
    @IBOutlet weak var sendVeriBtn: UIButton!   //发送验证码按钮
    @IBOutlet weak var nextStepBtn: UIButton!
    var countDownTimer: Timer?  //用于按钮计时
    
    //显示剩余秒数
    var remainingSeconds: Int = 0{
        willSet{
            sendVeriBtn.setTitle("已发送(\(newValue))", for: .normal)
            if newValue <= 0{
                sendVeriBtn.setTitle("发送验证码", for: .normal)
                isCounting = false
                nextStepBtn.isEnabled = false
            }
        }
    }
    
    //是否正在计数
    var isCounting = false{
        willSet{
            if newValue{
                countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(BindSendMsgVC.updateTimer(_:)), userInfo: nil, repeats: true)
                
                remainingSeconds = 60
            }else{
                countDownTimer?.invalidate()
                countDownTimer = nil
            }
            sendVeriBtn.isEnabled = !newValue //设置按钮的isEnabled属性
        }
    }
    
    //更新剩余秒数
    func updateTimer(_ timer: Timer){
        remainingSeconds -= 1
    }
    
    //发送短信验证码
    @IBAction func sendVeriBtnClicked(_ sender: UIButton) {
        let params = ["telephone":self.registerPhoneNumberTF.text!]
        if Validation.phoneNum(self.registerPhoneNumberTF.text!).isRight{
            XHWLNetwork.shared.postWechatVeriCode(params as NSDictionary, self)
        }else{
            "您输入的手机号格式不正确".ext_debugPrintAndHint()
        }
    }
    
    //还原手机号TF、验证码TF、remainTime、isCounting参数
    func restoreParams(){
        self.registerPhoneNumberTF.text = ""
        self.registerVeriTF.text = ""
        self.remainingSeconds = 0
    }
    
    //验证验证码
    @IBAction func nextStepBtnClicked(_ sender: UIButton) {
        //传给testVerificatCode接口的参数
        let openId = UserDefaults.standard.object(forKey: "openId") as! String
        let params = ["telephone":registerPhoneNumberTF.text!,"verificatCode":registerVeriTF.text!,"openId":openId]
        
        //判断验证码是否为6位
        if registerVeriTF.text!.characters.count == 6{
            XHWLNetwork.shared.postTestWechatVeriCode(params as NSDictionary, self)
        }else{
            "请输入6位数字验证码".ext_debugPrintAndHint()
        }
    }
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextStepBtn.isEnabled = false
        
        self.registerVeriTF.delegate = self
        self.registerPhoneNumberTF.delegate = self
        
        self.registerVeriTF.keyboardType = .numberPad
        self.registerPhoneNumberTF.keyboardType = .numberPad
        
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_WECHATGETVERICODE.rawValue:
            onWechatGetVeriCode(response)
            break
        case XHWLRequestKeyID.XHWL_TESTVERICODE.rawValue:
            onTestVeriCode(response)
            break
        default:
            break
        }
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

    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        print("&&&&wechatLogin&&&&", error)
    }
    
    //获取验证码之后
    func onWechatGetVeriCode(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            self.isCounting = true
            self.nextStepBtn.isEnabled = true
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        case 111,-4,112:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        case 100:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BindSetPswVC") as! BindSetPswVC
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            self.restoreParams()
            break
        default:
            break
        }
    }
    
    //验证验证码
    func onTestVeriCode(_ response:[String : AnyObject]){
        self.restoreParams()
        switch response["errorCode"] as! Int {
        case 200:   //该手机号为已存在账号，直接登录成功
            onLoginBtnCLicked(response)
            break
        case 100:   //无账号跳转到设置密码注册用户
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BindSetPswVC") as! BindSetPswVC
            break
        case 110,111:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
