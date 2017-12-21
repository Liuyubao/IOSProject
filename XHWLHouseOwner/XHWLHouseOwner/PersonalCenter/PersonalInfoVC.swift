//
//  PersonalInfoVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class PersonalInfoVC: UIViewController,UITextFieldDelegate ,UIScrollViewDelegate, XHWLNetworkDelegate{
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var personalInfoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //姓名的行控件
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var conformEditBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    //性别的行控件
    @IBOutlet weak var sexTF: UITextField!
    @IBOutlet weak var conformSexBtn: UIButton!
    @IBOutlet weak var editSexBtn: UIButton!
    
    //手机号行控件
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var conformPhoneBtn: UIButton!
    @IBOutlet weak var editPhoneBtn: UIButton!
    
    //修改绑定微信
    @IBOutlet weak var changeWechatBtn: UIButton!
    @IBOutlet weak var wechatNameLabel: UILabel!
    
    //修改密码
    @IBOutlet weak var changePswBtn: UIButton!
    @IBOutlet weak var pswStateLabel: UILabel!
    
    //修改密码事件
    @IBAction func changePswBtnClicked(_ sender: UIButton) {
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        
        let params = ["telephone": userModel?.telephone as! String]
        XHWLNetwork.shared.postVeriCode(params as NSDictionary, self)
    }
    
    @IBAction func changeWechatBtnClicked(_ sender: UIButton) {
        if wechatNameLabel.text == "未绑定"{
            wechatClickedSource = 2 //将点击源设为PersonalInfoVC
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "default_state"
            WXApi.send(req)
            let urlStr = "weixin://"
            if UIApplication.shared.canOpenURL(URL(string: urlStr)!) {
                let red = SendAuthReq()
                red.scope = "snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"
                red.state = "\(arc4random()%100)"
                WXApi.send(red)
            }else{
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL.init(string: "http://weixin.qq.com/r/qUQVDfDEVK0rrbRu9xG7")!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(URL.init(string: "http://weixin.qq.com/r/qUQVDfDEVK0rrbRu9xG7")!)
                }
            }
        }else{
            AlertMessage.showAlertMessage(vc: self, alertMessage: "确定要解绑吗？") {
                //解绑微信
                let data = UserDefaults.standard.object(forKey:"user") as! NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues:data.mj_JSONObject())
                let params = ["id": userModel?.sysAccount.id]
                XHWLNetwork.shared.postBindWechat(params as NSDictionary, self)
            }
            
        }
    }
    
    /**  微信通知  */
    func WXLoginSuccess(notification:Notification) {
        let code = notification.object as! String
        let requestUrl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(WX_APPID)&secret=\(WX_APPSecret)&code=\(code)&grant_type=authorization_code"
        DispatchQueue.global().async {
            let requestURL: URL = URL.init(string: requestUrl)!
            let data = try? Data.init(contentsOf: requestURL, options: Data.ReadingOptions())
            DispatchQueue.main.async {
                let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                let openid: String = jsonResult["openid"] as! String
                let access_token: String = jsonResult["access_token"] as! String
                //保存openID、access_token到沙盒
                UserDefaults.standard.set(openid, forKey: "openId")
                UserDefaults.standard.set(access_token, forKey: "access_token")
                UserDefaults.standard.synchronize()
                
                self.getUserInfo(openid: openid, access_token: access_token)
            }
        }
    }
    
    /**  获取用户信息  */
    func getUserInfo(openid:String,access_token:String) {
        let requestUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=\(access_token)&openid=\(openid)"
        DispatchQueue.global().async {
            let requestURL: URL = URL.init(string: requestUrl)!
            let data = try? Data.init(contentsOf: requestURL, options: Data.ReadingOptions())
            
            DispatchQueue.main.async {
                let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                //保存nickname到沙盒
                UserDefaults.standard.set(jsonResult["nickname"] as! String, forKey: "nickName")
                UserDefaults.standard.synchronize()
                //绑定微信
                let data = UserDefaults.standard.object(forKey:"user") as! NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues:data.mj_JSONObject())
                let params = ["id": userModel?.sysAccount.id, "openId":openid]
                XHWLNetwork.shared.postBindWechat(params as NSDictionary, self)
                
                print(jsonResult)
            }
        }
    }
    
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        AlertMessage.showAlertMessage(vc: self, alertMessage: "确定要退出吗？") {
                self.onLogout()
        }
    }
    
    func onLogout() {
        let data:NSData = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel:XHWLUserModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        let params = ["token": userModel.sysAccount.token]
        XHWLNetwork.shared.postLogout(params as NSDictionary, self)
    }
    
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_LOGOUT.rawValue:
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.removeObject(forKey: "projectList")
            UserDefaults.standard.removeObject(forKey: "roomList")
            UserDefaults.standard.synchronize()
            
            JPUSHService.deleteAlias(nil, seq: 0)
            
            let window:UIWindow = UIApplication.shared.keyWindow!
            let loginVC = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
            window.rootViewController = loginVC
            loginVC?.dismiss(animated: true, completion: nil)
            break
        case XHWLRequestKeyID.XHWL_BINDWECHAT.rawValue:
            switch response["errorCode"] as! Int{
            case 111:
                (response["message"] as! String).ext_debugPrintAndHint()
                break
            case 200:
                if wechatNameLabel.text == "未绑定"{
                    "绑定成功".ext_debugPrintAndHint()
                    self.viewDidLoad()
                }else{
                    UserDefaults.standard.removeObject(forKey: "nickName")
                    UserDefaults.standard.removeObject(forKey: "openId")
                    UserDefaults.standard.removeObject(forKey: "access_token")
                    UserDefaults.standard.removeObject(forKey: "code")
                    "解绑成功".ext_debugPrintAndHint()
                    self.viewDidLoad()
                }
                break
            default:
                break
            }
            break
        case XHWLRequestKeyID.XHWL_GETVERICODE.rawValue:
            switch response["errorCode"] as! Int{
            case -4:
                (response["message"] as! String).ext_debugPrintAndHint()
                break
            case 200:
                "验证码发送成功".ext_debugPrintAndHint()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReSetPswVC") as! ReSetPswVC
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                vc.isCounting = true
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        
    }
    
    
    //设置手机号可编辑
    func editPhoneBtnClicked(){
        phoneTF.isEnabled = true
        phoneTF.backgroundColor = UIColor.darkGray
        editPhoneBtn.isHidden = true
        conformPhoneBtn.isHidden = false
        phoneTF.becomeFirstResponder()
    }
    
    //确认手机号赋值
    func conformPhoneEditBtnClicked(){
        userModel?.setValue(phoneTF.text, forKey: "telephone")
        data = userModel?.mj_JSONData()! as! NSData
        UserDefaults.standard.set(data, forKey: "user")
        
        phoneTF.isEnabled = false
        phoneTF.backgroundColor = UIColor.clear
        conformPhoneBtn.isHidden = true
        editPhoneBtn.isHidden = false
    }
    
    //设置可编辑
    func editBtnClicked(){
        nameTF.isEnabled = true
        nameTF.backgroundColor = UIColor.darkGray
        editBtn.isHidden = true
        conformEditBtn.isHidden = false
        nameTF.becomeFirstResponder()
    }
    
    //确认则赋值
    func conformEditBtnClicked(){
        userModel?.setValue(nameTF.text, forKey: "name")
        data = userModel?.mj_JSONData()! as! NSData
        UserDefaults.standard.set(data, forKey: "user")
        
        nameTF.isEnabled = false
        nameTF.backgroundColor = UIColor.clear
        conformEditBtn.isHidden = true
        editBtn.isHidden = false
    }
    
    
    //设置性别可编辑
    func editSexBtnClicked(){
        
        
        sexTF.isEnabled = true
        sexTF.backgroundColor = UIColor.darkGray
        editSexBtn.isHidden = true
        conformSexBtn.isHidden = false
        sexTF.becomeFirstResponder()
    }
    
    //确认性别则赋值
    func conformSexEditBtnClicked(){
        userModel?.setValue(sexTF.text, forKey: "sex")
        data = userModel?.mj_JSONData()! as! NSData
        UserDefaults.standard.set(data, forKey: "user")
        
        sexTF.isEnabled = false
        sexTF.backgroundColor = UIColor.clear
        conformSexBtn.isHidden = true
        editSexBtn.isHidden = false
    }
    
    var data: NSData?
    var userModel: XHWLUserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: personalInfoView.frame.width, height: personalInfoView.frame.height)
        data = UserDefaults.standard.object(forKey: "user") as? NSData
        if data == nil{
            self.noticeError("您的账户未绑定", autoClearTime: 1)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }
        userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        //初始化个人信息
        nameTF.text = userModel?.name
        sexTF.text = userModel?.sex
        phoneTF.text = userModel?.telephone
        
        
        //姓名编辑
        editBtn.addTarget(self, action: #selector(editBtnClicked), for: .touchUpInside)
        conformEditBtn.addTarget(self, action: #selector(conformEditBtnClicked), for: .touchUpInside)
        conformEditBtn.isHidden = true
        nameTF.isEnabled = false
        nameTF.textColor = UIColor.white
        
        //性别编辑
        editSexBtn.addTarget(self, action: #selector(editSexBtnClicked), for: .touchUpInside)
        conformSexBtn.addTarget(self, action: #selector(conformSexEditBtnClicked), for: .touchUpInside)
        conformSexBtn.isHidden = true
        sexTF.isEnabled = false
        sexTF.textColor = UIColor.white
        
        //手机号编辑
        editPhoneBtn.addTarget(self, action: #selector(editPhoneBtnClicked), for: .touchUpInside)
        conformPhoneBtn.addTarget(self, action: #selector(conformPhoneEditBtnClicked), for: .touchUpInside)
        conformPhoneBtn.isHidden = true
        phoneTF.isEnabled = false
        phoneTF.textColor = UIColor.white
        
        //绑定状态、密码状态更改
        if let wechatNickName = UserDefaults.standard.object(forKey: "nickName") as? String{
            self.wechatNameLabel.text = wechatNickName
        }else{
            self.wechatNameLabel.text = "未绑定"
        }
        self.pswStateLabel.text = "修改"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,selector: #selector(WXLoginSuccess(notification:)),name:   NSNotification.Name(rawValue: "WXPersonalInfoVCNotification"),object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WXPersonalInfoVCNotification"), object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    

}
