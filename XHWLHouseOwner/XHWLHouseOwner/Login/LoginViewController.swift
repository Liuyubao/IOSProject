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
    @IBOutlet weak var wechatBtn: UIButton!
    
    var saveParameter = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if WXApi.isWXAppInstalled(){
            self.wechatBtn.alpha = 1
        }else{
            self.wechatBtn.alpha = 0
        }
        
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        if UserDefaults.standard.object(forKey: "versionCode") == nil {
            setupLaunch()
        }else {
            let saveVersion:String = UserDefaults.standard.object(forKey: "versionCode") as! String
            print("\(saveVersion)")
            if saveVersion != currentVersion {
                setupLaunch()
            }
        }
        //请求后台获得最新的版本号
        XHWLNetwork.sharedManager().getNewestVersion(["yzIOS"], self)
        
        
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
    
    
    // MARK: - 忘记密码
    @IBAction func forgetPswBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPhoneVeriVC") as! ForgetPhoneVeriVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - 登陆按钮点击事件
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        let myStoryBoard = self.storyboard
        self.view.endEditing(true)
        //传给login接口的参数
        var params = [String: String]()
        params["telephone"] = loginPhoneNumberTF.text!
        params["password"] = loginPswTF.text!
        
        //判断手机号格式是否正确
        if Validation.phoneNum(loginPhoneNumberTF.text!).isRight{
            XHWLNetwork.sharedManager().postLogin(params as NSDictionary, self)
        }else{
            "您输入的手机号格式有误！".ext_debugPrintAndHint()
        }
    }
    
    //当开始输入时，上升
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.view.frame.midY < self.view.frame.height/2{
            return
        }
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
//        self.registerView.frame = self.registerView.frame.offsetBy(dx: 0, dy: movement)
//        self.conformPswView.frame = self.conformPswView.frame.offsetBy(dx: 0, dy: movement)
//        self.loginView.frame = self.loginView.frame.offsetBy(dx: 0, dy: movement)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        
        UIView.commitAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    // MARK: - 微信登陆按钮点击事件
    @IBAction func wechatLoginBtnClicked(_ sender: UIButton) {
        wechatClickedSource = 1     //将点击源设为LoginVC  
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
        UserDefaults.standard.set(code, forKey: "code")
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
                UserDefaults.standard.set(jsonResult["nickname"] as! String, forKey: "wechatNickName")
                UserDefaults.standard.synchronize()
                let params = ["openId":jsonResult["openid"] as! String]
                XHWLNetwork.sharedManager().postWechatLogin(params as NSDictionary, self)
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
    
    
    // MARK: - 确认密码view中的上一步点击事件
    //conformView中的上一步事件
    @IBAction func returnToRegisterViewBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationTransition(.none, for: registerView!, cache: true)//conformPswView翻转
        self.view.bringSubview(toFront: registerView)
        conformPswView.alpha = 0
        let t = true
        let q = t ? 1 : 0
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
        remainingSeconds = 0
        conformPswView.transform = registerView.transform
    }
    
    // MARK: - 判断设置密码是否符合格式要求
    func checkPsw(str: String) -> Bool{
        //长度6-16
        if str.characters.count < 6 || str.characters.count > 16{
            "密码长度须为6-16位".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return false
        }
        
        //不是只包含数字
        let predNumRule = "^([0-9]{6,16})$"
        let p1 = NSPredicate(format: "SELF MATCHES %@" ,predNumRule)
        if p1.evaluate(with: str){
            "密码不能只包含数字".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return false
        }
        //不是只包含字母
        let predAlphabetRule = "^([A-Za-z]{6,16})$"
        let p2 = NSPredicate(format: "SELF MATCHES %@" ,predAlphabetRule)
        if p2.evaluate(with: str){
            "密码不能只包含字母".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return false
        }
        //总验证
        let predOverallRule = "^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,20}$"
        let p3 = NSPredicate(format: "SELF MATCHES %@" ,predOverallRule)
        if !p3.evaluate(with: str){
            "密码须包含数字字母".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    // MARK: - conformView中的下一步事件
    @IBAction func conformNextStopBtnClicked(_ sender: UIButton) {
        //判断输入框是否为空
        if self.conformPswTF.text?.characters.count == 0 || self.conformRePswTF.text?.characters.count == 0{
            "密码不能为空".ext_debugPrintAndHint()
            self.view.endEditing(true)
        }else if !self.checkPsw(str: self.conformPswTF.text!){
            self.view.endEditing(true)
        }else if self.conformPswTF.text != self.conformRePswTF.text{
            "您输入的两次密码不匹配".ext_debugPrintAndHint()
            self.view.endEditing(true)
        }else{
            //传给register接口的参数
            var params = [String: String]()
            params["telephone"] = self.saveParameter["telephone"]
            params["password"] = self.conformRePswTF.text!
            params["verificatCode"] = self.saveParameter["verificatCode"]
            
            Alamofire.request("\(LoginViewController.baseUrl)/v1/appBase/register", method: .post ,parameters: params).responseJSON{ response in
                let result = response.result.value as! NSDictionary
                switch result["errorCode"] as! Int{
                case -5,-6:
                    (result["message"] as! String).ext_debugPrintAndHint()
                    self.view.endEditing(true)
                    break
                case 200:
                    //注册成功，跳到主页面
                    //传给login接口的参数
                    var params2 = ["telephone":self.registerTelephone,"password":params["password"]]
                    
                    XHWLNetwork.sharedManager().postLogin(params2 as NSDictionary, self)
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - registerView中的下一步事件
    @IBAction func nextStepBtnClicked(_ sender: UIButton) {
        //传给testVerificatCode接口的参数
        var params = [String: String]()
        params["telephone"] = registerPhoneNumberTF.text!
        params["verifyCode"] = registerVeriTF.text!
        //保存手机号和验证码到saveParamerters
        self.saveParameter["telephone"] = params["telephone"]
        self.saveParameter["verificatCode"] = params["verifyCode"]
        
        self.registerTelephone = registerPhoneNumberTF.text!
        //判断验证码是否为6位
        if registerVeriTF.text!.characters.count == 6{
            XHWLNetwork.sharedManager().postVeriCodeLogin(params as NSDictionary, self)

        }else{
            "请输入6位数字验证码".ext_debugPrintAndHint()
            self.view.endEditing(true)
        }
    }
    
    var registerTelephone: String = ""  //保存注册填写时候的手机账号
    
    // MARK: - 发送短信验证码
    @IBAction func sendVeriBtnClicked(_ sender: UIButton) {
        self.sendVeriBtn.isEnabled = false
        //传给发送验证码接口的参数
        var params = [String: String]()
        params["telephone"] = registerPhoneNumberTF.text!
        //判断手机号格式是否正确
        if Validation.phoneNum(registerPhoneNumberTF.text!).isRight{
            Alamofire.request("\(LoginViewController.baseUrl)/v1/appBase/register/getVerificatCode", method: .post ,parameters: params).responseJSON{ response in
                if let result = response.result.value as? NSDictionary{
                    if result["state"] as! Bool{
                        //发送验证码成功
                        "验证码发送成功".ext_debugPrintAndHint
                        self.isCounting = true
                        self.nextStepBtn.isEnabled = true
                        self.registerVeriTF.becomeFirstResponder()
                    }else{
                        "验证码发送失败".ext_debugPrintAndHint()
                        self.view.endEditing(true)
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
    
    // MARK: - 转到registerView
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
        nextStepBtn.isEnabled = false
        
        //设置toLoginViewBtn 为可点击
        toLoginViewBtn.isEnabled = true
    }
    
    // MARK: - 取消注册，返回到loginView
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
    
    
    // MARK: - network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_LOGIN.rawValue:
            onLoginBtnCLicked(response)
            break
        case XHWLRequestKeyID.XHWL_WECHATLOGIN.rawValue:
            onWechatBtnClicked(response)
            break
        case XHWLRequestKeyID.XHWL_GETALLDOORS.rawValue:
            onSaveDoorValues(response)
            break
        case XHWLRequestKeyID.XHWL_NEWLESTVERSION.rawValue:
            onGetNewestVersion(response)
            break
        case XHWLRequestKeyID.XHWL_VERICODELOGIN.rawValue:
            onVeriCodeLogin(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        print("&&&&wechatLogin&&&&", error)
    }
    
    //短信验证码登录
    func onVeriCodeLogin(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case -1, -2, 111:   //验证码不争取//验证码过期//数据有误
            (response["message"] as! String).ext_debugPrintAndHint()
            self.view.resignFirstResponder()
            break
        case 100:       //设置密码
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
            
            UIView.setAnimationTransition(.none, for: self.registerView!, cache: true)//registerView翻转
            self.conformPswView.alpha = 1
            
            self.view.bringSubview(toFront: self.conformPswView)
            
            UIView.setAnimationDelegate(self)
            UIView.commitAnimations()
            
            break
        case 200:   //直接登陆
            onLoginBtnCLicked(response)
            break
        default:
            break
        }
    }
    
    func onGetNewestVersion(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let result = response["result"] as! NSDictionary
            let newestVersion = result["versionNo"] as! String
            if currentVersion != newestVersion{
                UserDefaults.standard.set(currentVersion, forKey:"versionCode")
                UserDefaults.standard.synchronize()
                // 跳转到对应的appStore  https://itunes.apple.com/cn/app/小七专家/id1283925515?l=en&mt=8
                print("跳转到AppStore")
                // update_type:更新类型// 1:强制更新 2:非强制更新
                //做你想做的事情
                let alertController = UIAlertController.init(title: "温馨提示", message: "最新版本\(result["versionNo"]! as! String)已上线，请立即更新！", preferredStyle: UIAlertControllerStyle.alert)
                let confirmAction = UIAlertAction.init(title: "更新", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    //跳转到AppStore，该App下载界面
//                    let urlStr:String = "https://itunes.apple.com/cn/app/小七专家/id1283925515?l=en&mt=8"
                    let urlStr:String = "https://itunes.apple.com/cn/app/小七当家/id1275826340?l=en&mt=8"
                    let string:String = urlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    guard let url:URL = URL.init(string: string) else {
                        print("失败")
                        return
                    }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                })
                let nextTimeAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
                
                alertController.addAction(confirmAction)
                alertController.addAction(nextTimeAction)
                let vc = UIViewController.currentViewController()
                vc?.present(alertController, animated: true, completion: nil)
            }
           
            break
        default:
            break
        }
    }
    
    //保存门禁列表到沙盒中
    func onSaveDoorValues(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            let result = response["result"] as! NSDictionary
            UserDefaults.standard.set("1419231E0606060606A8", forKey: "openData")
            UserDefaults.standard.set(result["personId"] as! String, forKey: "personId")
            //保存所有门禁列表
            if let doorList:NSArray = result["doorList"] as? NSArray{
                let modelData3:NSData = doorList.mj_JSONData()! as NSData
                UserDefaults.standard.set(modelData3, forKey: "allDoorList")
            }
            UserDefaults.standard.synchronize()
            break
        case 111,-1,2:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
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
    
    //登录返回参数处理
    func onLoginBtnCLicked(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            
            let result = response["result"] as! NSDictionary
            //获取user
            let yzUser = result["sysUser"] as? NSDictionary
            if yzUser == nil{
                "请联系物业人员授权登陆权限。".ext_debugPrintAndHint()
                return
            }
            
            //将用户信息存入沙盒
            let yzUserData = yzUser?.mj_JSONData() as! NSData
            UserDefaults.standard.set(yzUserData, forKey: "user")
            
            //更新微信用户名
            let userModel = XHWLUserModel.mj_object(withKeyValues: yzUserData.mj_JSONObject())
            if userModel?.sysAccount.imageUrl == nil || userModel?.sysAccount.imageUrl == ""{
                UserDefaults.standard.removeObject(forKey: "imageUrl")
            }else{
                UserDefaults.standard.set(userModel?.sysAccount.imageUrl as! String, forKey: "imageUrl")
            }
            if userModel?.sysAccount.weChatNickName == nil || userModel?.sysAccount.weChatNickName == ""{
                UserDefaults.standard.removeObject(forKey: "wechatNickName")
            }else{
                UserDefaults.standard.set(userModel?.sysAccount.weChatNickName, forKey: "wechatNickName")
            }
            
            //将别名上传
            JPUSHService.setAlias(yzUser!["sysAccountName"] as! String, completion: { (iResCode, iAlias, seq) in
                if seq == 0 {
//                    "上传别名成功".ext_debugPrintAndHint()
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
                if #available(iOS 10.0, *) {
                    AppDelegate.shared().getWilddogToken(curInfoModel.curProject.projectCode as! String, yzUser!["telephone"] as! String)
//                    let token = UserDefaults.standard.object(forKey: "wilddogToken") as! String
//                    AppDelegate.shared().wilddogLogin(token)
                } else {
                    // Fallback on earlier versions
                }
            }else{
                "请联系物业人员授权登陆权限。".ext_debugPrintAndHint()
                return
            }
            
            //传给postGetAllDoors接口的参数
            let sysAccount = yzUser!["sysAccount"] as! NSDictionary
            let date = Date()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
            let strNowTime = timeFormatter.string(from: date)
            let dateToken = (strNowTime+"adminXH").md5
            let params = ["projectCode":curInfoModel.curProject.projectCode,"token":dateToken,"userName":yzUser!["name"] as! String,"phone":yzUser!["telephone"] as! String]
            XHWLNetwork.sharedManager().postGetAllDoors(params as NSDictionary, self)
            
            let curInfoData = curInfoModel.mj_JSONData() as? NSData
            UserDefaults.standard.set(curInfoData, forKey: "curInfo")
            UserDefaults.standard.synchronize()
            
            let successfullyVC:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC"))!
            successfullyVC.modalTransitionStyle = .crossDissolve
            self.present(successfullyVC, animated: true, completion: nil)
            self.view.window?.rootViewController = successfullyVC
        }else{
            (response["message"] as! String).ext_debugPrintAndHint()
            switch(response["errorCode"] as! Int){
            case 114:
                //用户名不存在
                "用户名不存在！".ext_debugPrintAndHint()
                break
            case 113:
                //用户名密码不正确，请重新输入
                "用户名密码不正确，请重新输入！".ext_debugPrintAndHint()
                break
            default:
                break
            }
        }
    }
}
