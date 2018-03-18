//
//  ReSetPswVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/17.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class ReSetPswVC: UIViewController, XHWLNetworkDelegate {
    
    @IBOutlet weak var conformPswTF: UITextField!
    @IBOutlet weak var conformRePswTF: UITextField!
    @IBOutlet weak var registerVeriTF: UITextField!
    @IBOutlet weak var sendVeriBtn: UIButton!   //发送验证码按钮
    var countDownTimer: Timer?  //用于按钮计时
    @IBOutlet weak var conformBtn: UIButton!
    
    //确定按钮点击事件
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //键盘隐藏
        self.view.endEditing(true)
        //registerVeriTF是否为空
        if self.registerVeriTF.text == ""{
            "验证码不能为空".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return
        }
        //registerVeriTF是否为6位数
        if self.registerVeriTF.text?.characters.count != 6{
            "验证码必须为6位".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return
        }
        //conformPswTF是否为空
        if self.conformPswTF.text == ""{
            "密码不能为空".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return
        }
        //conformRePswTF是否为空
        if self.conformRePswTF.text == ""{
            "确认密码不能为空".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return
        }
        //conformPswTF和conformRePswTF值是否相同
        if self.conformPswTF.text != self.conformRePswTF.text{
            "两次输入密码不同".ext_debugPrintAndHint()
            self.view.endEditing(true)
            return
        }
        
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        let params = ["telephone":userModel?.telephone as! String, "newPsw":self.conformPswTF.text as! String, "verificatCode":self.registerVeriTF.text as! String]
        XHWLNetwork.sharedManager().postChangePsw(params as NSDictionary, self)
        
    }
    
    //发送验证码
    @IBAction func sendVeriBtnClicked(_ sender: UIButton) {
        self.isCounting = true
    }
    
    //显示剩余秒数
    var remainingSeconds: Int = 0{
        willSet{
            sendVeriBtn.setTitle("已发送(\(newValue))", for: .normal)
            if newValue <= 0{
                sendVeriBtn.setTitle("发送验证码", for: .normal)
                isCounting = false
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
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_CHANGEPSW.rawValue:
            switch response["errorCode"] as! Int{
            case 111, 110, 201:
                (response["message"] as! String).ext_debugPrintAndHint()
                break
            case 200:
                "密码修改成功".ext_debugPrintAndHint()
                self.dismiss(animated: true, completion: nil)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}
