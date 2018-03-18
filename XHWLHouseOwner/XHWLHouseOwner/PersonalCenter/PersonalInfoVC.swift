//
//  PersonalInfoVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import DropDown

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
    @IBOutlet weak var sexBtn: UIButton!
    let sexDD = DropDown()  // 性别下拉框
    
    //手机号行控件
    @IBOutlet weak var phoneTF: UITextField!
    
    //修改绑定微信
    @IBOutlet weak var changeWechatBtn: UIButton!
    @IBOutlet weak var wechatNameLabel: UILabel!
    
    //修改密码
    @IBOutlet weak var changePswBtn: UIButton!
    @IBOutlet weak var pswStateLabel: UILabel!
    @IBOutlet weak var headIconIV: UIImageView!
    
    //暂存微信名称和微信头像
    var wechatNickName = ""
    var wechatHeadIconUrl = ""
    
    //配置sex下拉框
    func setupSexDropDown() {
        sexDD.anchorView = sexBtn
        
        sexDD.bottomOffset = CGPoint(x: 0, y: sexBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        sexDD.dataSource = [
            "男",
            "女"
        ]
        
        // Action triggered on selection
        sexDD.selectionAction = { [unowned self] (index, item) in
            self.sexBtn.setTitle(item, for: .normal)
        }
        
    }
    @IBAction func sexBtnClicked(_ sender: UIButton) {
        sexDD.show()
        self.isInfoChanged = true
    }
    
    //修改密码事件
    @IBAction func changePswBtnClicked(_ sender: UIButton) {
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        
        let params = ["telephone": userModel?.telephone as! String]
        XHWLNetwork.sharedManager().postVeriCode(params as NSDictionary, self)
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
                XHWLNetwork.sharedManager().postBindWechat(params as NSDictionary, self)
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
                print("#############jsonResult",jsonResult)
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
                self.wechatNickName = jsonResult["nickname"] as! String
                self.wechatHeadIconUrl = jsonResult["headimgurl"] as! String
                //绑定微信
                let data = UserDefaults.standard.object(forKey:"user") as! NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues:data.mj_JSONObject())
                let params = ["id": userModel?.sysAccount.id, "openId":openid, "nickName":jsonResult["nickname"] as! String, "imageUrl":jsonResult["headimgurl"] as! String]
                XHWLNetwork.sharedManager().postBindWechat(params as NSDictionary, self)
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
        self.isInfoChanged = false
        XHWLNetwork.sharedManager().postLogout(params as NSDictionary, self)
    }
    
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_LOGOUT.rawValue:
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.removeObject(forKey: "projectList")
            UserDefaults.standard.removeObject(forKey: "roomList")
            UserDefaults.standard.removeObject(forKey: "wechatNickName")
            UserDefaults.standard.removeObject(forKey: "imageUrl")
            UserDefaults.standard.removeObject(forKey: "sex")
            
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
                    
                    UserDefaults.standard.set(self.wechatNickName, forKey: "wechatNickName")
                    UserDefaults.standard.set(self.wechatHeadIconUrl, forKey: "imageUrl")
                    //更新沙河中user的wechatNickName 和 imageUrl
                    userModel?.sysAccount.setValue(self.wechatNickName, forKey: "weChatNickName")
                    userModel?.sysAccount.setValue(self.wechatHeadIconUrl, forKey: "imageUrl")
                    //将用户信息存入沙盒
                    data = userModel?.mj_JSONData() as! NSData
                    UserDefaults.standard.set(data, forKey: "user")
                    UserDefaults.standard.synchronize()
                    
                    UserDefaults.standard.synchronize()
                    self.viewDidLoad()
                }else{
                    UserDefaults.standard.removeObject(forKey: "wechatNickName")
                    UserDefaults.standard.removeObject(forKey: "openId")
                    UserDefaults.standard.removeObject(forKey: "access_token")
                    UserDefaults.standard.removeObject(forKey: "code")
                    UserDefaults.standard.synchronize()
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
        case XHWLRequestKeyID.XHWL_UPDATEINFO.rawValue:
            self.isInfoChanged = false
            "更新个人信息成功".ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        
    }
    
    //设置可编辑
    func editBtnClicked(){
        nameTF.isEnabled = true
        nameTF.backgroundColor = UIColor.darkGray
        editBtn.isHidden = true
        conformEditBtn.isHidden = false
        nameTF.becomeFirstResponder()
    }
    
    var isInfoChanged: Bool = false //name和sex是否改变，改变则调用修改个人信息接口
    
    //确认则赋值
    func conformEditBtnClicked(){
        userModel?.sysAccount.setValue(nameTF.text, forKey: "nickName")
        data = userModel?.mj_JSONData()! as! NSData
        UserDefaults.standard.set(data, forKey: "user")
        self.isInfoChanged = true
        nameTF.isEnabled = false
        nameTF.backgroundColor = UIColor.clear
        conformEditBtn.isHidden = true
        editBtn.isHidden = false
    }
    
    
    
    
    var data: NSData?
    var userModel: XHWLUserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSexDropDown()
        
        scrollView.contentSize = CGSize(width: personalInfoView.frame.width, height: personalInfoView.frame.height)
        data = UserDefaults.standard.object(forKey: "user") as? NSData
        if data == nil{
            self.noticeError("您的账户未绑定", autoClearTime: 1)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }
        userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        // MARK: - 初始化界面变量
        //初始化个人信息
        
        nameTF.text = userModel?.sysAccount.nickName
        if userModel?.sysAccount.nickName == ""{
            nameTF.text = "未设置"
        }
        
        if (userModel?.sysAccount.sex)!{
            sexBtn.setTitle("男", for: .normal)
        }else{
            sexBtn.setTitle("女", for: .normal)
        }
        phoneTF.text = userModel?.telephone
        
        //绑定状态、密码状态更改
        if let wechatNickName = UserDefaults.standard.object(forKey: "wechatNickName") as? String{
            self.wechatNameLabel.text = wechatNickName
        }else{
            self.wechatNameLabel.text = "未绑定"
        }
        self.pswStateLabel.text = "修改"
        
        //修改头像
        if let headImgUrl = UserDefaults.standard.object(forKey: "imageUrl") as? String{
            /**
             *  初始化data。从URL中获取数据
             */
            var data = NSData(contentsOf: URL(string: headImgUrl)!)
            /**
             *  创建图片
             */
            var image = UIImage(data:data as! Data, scale: 1.0)
            self.headIconIV.image = image
            
            self.headIconIV.contentMode = .scaleAspectFill
            self.headIconIV.layer.masksToBounds = true
            self.headIconIV.layer.cornerRadius = self.headIconIV.frame.width/2
            
        }else{
            
        }
        
        //姓名编辑
        editBtn.addTarget(self, action: #selector(editBtnClicked), for: .touchUpInside)
        conformEditBtn.addTarget(self, action: #selector(conformEditBtnClicked), for: .touchUpInside)
        conformEditBtn.isHidden = true
        nameTF.isEnabled = false
        nameTF.textColor = UIColor.white
        
        
        //手机号编辑
        phoneTF.isEnabled = false
        phoneTF.textColor = UIColor.white
        
        isInfoChanged = false
        if WXApi.isWXAppInstalled(){
            self.changeWechatBtn.isEnabled = true
        }else{
            self.changeWechatBtn.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,selector: #selector(WXLoginSuccess(notification:)),name:   NSNotification.Name(rawValue: "WXPersonalInfoVCNotification"),object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WXPersonalInfoVCNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isInfoChanged{
            
            //取出user的信息
            var data = UserDefaults.standard.object(forKey: "user") as? NSData
            var userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            let token = userModel?.sysAccount.token
            let name = self.nameTF.text
            let sex = self.sexBtn.currentTitle
            var upSex = true
            if sex == "男"{
                upSex = true
            }else{
                upSex = false
            }
            let params = ["id":userModel?.sysAccount.id as! String,"sex":upSex,"nickName":name!,"token":token!] as [String : Any]
            XHWLNetwork.sharedManager().postUpdateInfo(params as NSDictionary, self)
            //更新沙河中sex变量
            if sexBtn.currentTitle == "男"{
                userModel?.sysAccount.setValue(true, forKey: "sex")
            }else{
                userModel?.sysAccount.setValue(false, forKey: "sex")
            }
            data = userModel?.mj_JSONData()! as! NSData
            UserDefaults.standard.set(data, forKey: "user")
            UserDefaults.standard.synchronize()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

}
