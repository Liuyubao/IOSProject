//  
//  LoginViewController.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/10.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.

import UIKit
import Alamofire
import ElasticTransition

class LoginViewController: UIViewController, UITextFieldDelegate, XHWLNetworkDelegate {
    static let baseUrl = XHWLHttpURL
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var loginBtn: DKTransitionButton!
    @IBOutlet weak var loginView: LoginView!
    @IBOutlet weak var registerView: RegisterView!
    @IBOutlet weak var conformPswView: ConformPswView!
    @IBOutlet weak var successView: SuccessView!
    
    @IBOutlet weak var sendVeriBtn: UIButton!   //发送验证码按钮
    var countDownTimer: Timer?  //用于按钮计时
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var toRegisterViewBtn: UIButton!
    @IBOutlet weak var toLoginViewBtn: UIButton!
    
    //所有的TextField
    @IBOutlet weak var loginPhoneNumberTF: UITextField!
    @IBOutlet weak var loginPswTF: UITextField!
    @IBOutlet weak var registerPhoneNumberTF: UITextField!
    @IBOutlet weak var registerVeriTF: UITextField!
    @IBOutlet weak var conformPswTF: UITextField!
    @IBOutlet weak var conformRePswTF: UITextField!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var testBottonConstraint: NSLayoutConstraint!
    
    var saveParameter = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginPhoneNumberTF.delegate = self
        loginPswTF.delegate = self
        registerPhoneNumberTF.delegate = self
        registerVeriTF.delegate = self
        conformPswTF.delegate = self
        conformRePswTF.delegate = self
        
        //设置键盘类型
        loginPhoneNumberTF.keyboardType = .numberPad
        registerPhoneNumberTF.keyboardType = .numberPad
        registerVeriTF.keyboardType = .numberPad
        
        NotificationCenter.default.addObserver(self,selector: #selector(WXLoginSuccess(notification:)),name:   NSNotification.Name(rawValue: "WXLoginVCNotification"),object: nil)
        
//        YLGIFImage.setPrefetchNum(5)
//        let path = Bundle.main.url(forResource: "up2", withExtension: "gif")?.absoluteString as String!
//        logoImg.image = YLGIFImage(contentsOfFile: path!)
//        logoImg.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        if UserDefaults.standard.object(forKey: "versionCode") == nil {
            setupLaunch()
        }
        else {
            let saveVersion:String = UserDefaults.standard.object(forKey: "versionCode") as! String
            print("\(saveVersion)")
            if saveVersion != currentVersion {
                setupLaunch()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WXLoginVCNotification"), object: nil)
    }
    
    func setupLaunch(){
//        if UserDefaults.standard.bool(forKey: "notFirstLoad") == false {
            var imageNameArr = Array<Any>()
            for i in 1..<4 {
                imageNameArr.append("Introduction_\(i)")
            }
            
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            self.view!.addSubview(CLNewFeatureView(imageNameArr: imageNameArr))
            UserDefaults.standard.set(currentVersion, forKey:"versionCode")
            UserDefaults.standard.synchronize()
    }
    
    @IBAction func forgetPswBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPhoneVeriVC") as! ForgetPhoneVeriVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        let myStoryBoard = self.storyboard
        self.view.endEditing(true)
        //传给login接口的参数
        var params = [String: String]()
        params["telephone"] = loginPhoneNumberTF.text!
        params["password"] = loginPswTF.text!
        
        //判断手机号格式是否正确
        if Validation.phoneNum(loginPhoneNumberTF.text!).isRight{
            XHWLNetwork.shared.postLogin(params as NSDictionary, self)
        }else{
            AlertMessage.showAlertMessage(vc: self, alertMessage: "您输入的手机号格式有误！", duration: 1)
        }
    }
    
    //当开始输入时，上升
    func textFieldDidBeginEditing(_ textField: UITextField) {
            animateViewMoving(up: true, moveValue: 100)
    }
    
    //当完成输入后，下降
    func textFieldDidEndEditing(_ textField: UITextField) {
            animateViewMoving(up: false, moveValue: 100)
    }
    
    //上升 下降的函数
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func wechatLoginBtnClicked(_ sender: UIButton) {
        wechatClickedSource = 1     //将点击源设为LoginVC  ◊
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
                UIApplication.shared.openURL(URL.init(string: "http://weixin.qq.com/r/qUQVDfDEVK0rrbRu9xG7")!)
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
                let params = ["openId":jsonResult["openid"] as! String]
                XHWLNetwork.shared.postWechatLogin(params as NSDictionary, self)
                print(jsonResult)
            }
        }
    }
    
    //当按下return键
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true;
    }
    
    //点击其他地方  收回键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //conformView中的上一步事件
    @IBAction func returnToRegisterViewBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationTransition(.curlDown, for: registerView!, cache: true)//conformPswView翻转
        self.view.bringSubview(toFront: registerView)
        conformPswView.alpha = 0
        let t = true
        let q = t ? 1 : 0
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
        remainingSeconds = 0
        conformPswView.transform = registerView.transform
    }
    
    //conformView中的下一步事件
    @IBAction func conformNextStopBtnClicked(_ sender: UIButton) {
        //判断输入框是否为空
        if self.conformPswTF.text?.characters.count == 0 || self.conformRePswTF.text?.characters.count == 0{
            AlertMessage.showAlertMessage(vc: self, alertMessage: "密码不能为空", duration: 1)
        }else if self.conformPswTF.text != self.conformRePswTF.text{
            AlertMessage.showAlertMessage(vc: self, alertMessage: "您输入的密码不匹配", duration: 1)
        }else{
            //传给register接口的参数
            var params = [String: String]()
            params["telephone"] = self.saveParameter["telephone"]
            params["password"] = self.conformRePswTF.text!
            params["verificatCode"] = self.saveParameter["verificatCode"]
            
            Alamofire.request("\(LoginViewController.baseUrl)/appBase/register", method: .post ,parameters: params).responseJSON{ response in
                let result = response.result.value as! NSDictionary
                switch result["errorCode"] as! Int{
                case -5,-6:
                    (result["message"] as! String).ext_debugPrintAndHint()
                    break
                case 200:
                    //注册成功 还原输入框
                    self.conformPswTF.text = ""
                    self.conformRePswTF.text = ""
                    
                    self.loginPhoneNumberTF.text = params["telephone"]
                    
                    //将registerView和conformView先后放到最下层，并设置alpha
                    self.view.sendSubview(toBack: self.conformPswView)
                    self.conformPswView.alpha = 0
                    
                    //防止此过程中点击toLoginViewBtn
                    self.toLoginViewBtn.isEnabled = false
                    
                    self.successView.transform = self.registerView.transform
                    UIView.beginAnimations(nil, context: nil)
                    UIView.setAnimationCurve(.easeOut)
                    UIView.setAnimationDuration(1)
                    UIView.setAnimationBeginsFromCurrentState(true)
                    
                    self.successView.alpha = 1.0
                    self.view.bringSubview(toFront: self.successView)
                    
                    UIView.setAnimationDelegate(self)
                    UIView.commitAnimations()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(1.0)) {
                        UIView.beginAnimations(nil, context: nil)
                        UIView.setAnimationCurve(.easeOut)
                        UIView.setAnimationDuration(1)
                        UIView.setAnimationBeginsFromCurrentState(true)
                        
                        self.successView.alpha = 0
                        
                        UIView.setAnimationDelegate(self)
                        UIView.commitAnimations()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(0.1)){
                            self.view.sendSubview(toBack: self.successView)
                            self.toLoginView(sender)
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    //registerView中的下一步事件
    @IBAction func nextStepBtnClicked(_ sender: UIButton) {
        //传给testVerificatCode接口的参数
        var params = [String: String]()
        params["telephone"] = registerPhoneNumberTF.text!
        params["verificatCode"] = registerVeriTF.text!
        
        //判断验证码是否为6位
        if registerVeriTF.text!.characters.count == 6{
            Alamofire.request("\(LoginViewController.baseUrl)/appBase/register/testVerificatCode", method: .post ,parameters: params).responseJSON{ response in
                if let result = response.result.value as? NSDictionary{
                    if result["state"] as! Bool{
                        //验证码正确,保存手机号和验证码到saveParamerters
                        self.saveParameter["telephone"] = params["telephone"]
                        self.saveParameter["verificatCode"] = params["verificatCode"]
                        
                        //清空输入框，还原计时器和下一步属性
                        self.registerPhoneNumberTF.text = ""
                        self.registerVeriTF.text = ""
                        self.remainingSeconds = 0
                        self.nextStepBtn.isEnabled = false
                        
                        self.remainingSeconds = 0
                        self.conformPswView.transform = self.registerView.transform
                        
                        
                        UIView.beginAnimations(nil, context: nil)
                        UIView.setAnimationCurve(.easeOut)
                        UIView.setAnimationDuration(0.5)
                        UIView.setAnimationBeginsFromCurrentState(true)
                        
                        UIView.setAnimationTransition(.curlUp, for: self.registerView!, cache: true)//registerView翻转
                        self.conformPswView.alpha = 1
                        
                        self.view.bringSubview(toFront: self.conformPswView)
                        
                        UIView.setAnimationDelegate(self)
                        UIView.commitAnimations()
                    }else{
                        "验证码不正确".ext_debugPrintAndHint()
                        self.isCounting = false
                        self.remainingSeconds = 0
                        self.nextStepBtn.isEnabled = false
                    }
                }
            }
        }else{
            "请输入6位数字验证码".ext_debugPrintAndHint()
        }
    }
    
    
    //发送短信验证码
    @IBAction func sendVeriBtnClicked(_ sender: UIButton) {
        self.sendVeriBtn.isEnabled = false
        //传给发送验证码接口的参数
        var params = [String: String]()
        params["telephone"] = registerPhoneNumberTF.text!
        //判断手机号格式是否正确
        if Validation.phoneNum(registerPhoneNumberTF.text!).isRight{
            Alamofire.request("\(LoginViewController.baseUrl)/appBase/register/getVerificatCode", method: .post ,parameters: params).responseJSON{ response in
                if let result = response.result.value as? NSDictionary{
                    if result["state"] as! Bool{
                        //发送验证码成功
                        "验证码发送成功".ext_debugPrintAndHint
                        self.isCounting = true
                        self.nextStepBtn.isEnabled = true
                    }else{
                        "验证码发送失败".ext_debugPrintAndHint()
                    }
                }
            }
        }else{
            "您输入的手机号格式不正确".ext_debugPrintAndHint()
            self.isCounting = false
        }
    }

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
                countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LoginViewController.updateTimer(_:)), userInfo: nil, repeats: true)
                
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
    
    //转到registerView
    @IBAction func registerBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        var loginTransfrom = loginView?.transform
        
        loginTransfrom = loginTransfrom?.scaledBy(x: 0.9, y: 0.9)//loginView缩小
        loginTransfrom = loginTransfrom?.translatedBy(x: 0, y: -30)//loginView向上平移
        
        var registerTransform = registerView?.transform
        UIView.setAnimationTransition(.none, for: registerView!, cache: true)//loginView翻转
        registerTransform = registerTransform?.scaledBy(x: 1.1, y: 1.1)//registerView放大
        registerTransform = registerTransform?.translatedBy(x: 0, y: -35)//registerView向上平移

        self.view.bringSubview(toFront: registerView)//将RegisterView置于LoginView之上
        loginView.transform = loginTransfrom!
        registerView.transform = registerTransform!
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
        
        //将toRegisterViewBtn设置为不能点击，并将下一步按钮放上来
        toRegisterViewBtn.isEnabled = false
        registerView.bringSubview(toFront: nextStepBtn)
        
        //设置为下一步按钮，并将其isEnabled设为false
        nextStepBtn.setTitle("下一步", for: UIControlState.normal)
        nextStepBtn.isEnabled = false
        
        //设置toLoginViewBtn 为可点击
        toLoginViewBtn.isEnabled = true
    }
    
    //取消注册，返回到loginView
    @IBAction func cancelRegisterBtnClicked(_ sender: UIButton) {
        //还原输入框
        self.registerPhoneNumberTF.text = ""
        self.registerVeriTF.text = ""
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        var registerTransform = registerView?.transform
        UIView.setAnimationTransition(.none, for: registerView!, cache: true)
        
        registerTransform = registerTransform?.translatedBy(x: 0, y: 35)
        registerTransform = registerTransform?.scaledBy(x: 10/11, y: 10/11)

        var loginTransfrom = loginView?.transform
        
        loginTransfrom = loginTransfrom?.translatedBy(x: 0, y: 30)
        loginTransfrom = loginTransfrom?.scaledBy(x: 10/9, y: 10/9)
        
        self.view.bringSubview(toFront: loginView)
        loginView.transform = loginTransfrom!
        registerView.transform = registerTransform!
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
        
        //将toRegisterViewBtn设置为能点击，并将toRegisterViewBtn按钮放上来
        toRegisterViewBtn.isEnabled = true
        registerView.bringSubview(toFront: toRegisterViewBtn)
        
        //设置为注册按钮，并将其isEnabled设为true
        nextStepBtn.setTitle("注册", for: UIControlState.normal)
        nextStepBtn.isEnabled = true
        
        //设置toLoginViewBtn 为不可点击
        toLoginViewBtn.isEnabled = false
        
        //设置remaining为0,nextStep的isEnable
        remainingSeconds=0
        nextStepBtn.isEnabled = true
        self.view.sendSubview(toBack: conformPswView)
        conformPswView.alpha = 0
    }
    
    //去loginView
    @IBAction func toLoginView(_ sender: UIButton) {
        cancelRegisterBtnClicked(sender)
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_LOGIN.rawValue:
            onLoginBtnCLicked(response)
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
    
    //登录返回参数处理
    func onLoginBtnCLicked(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            let result = response["result"] as! NSDictionary
            //获取user
            let yzUser = result["sysUser"] as? NSDictionary
            
//            //未认证用户
//            if yzUser?.count == 0{
//                "您的账号未认证，无法登陆！".ext_debugPrintAndHint()
//                return
//            }
            
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
}
