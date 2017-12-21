//
//  ForgetPhoneVeriVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/12/4.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class ForgetPhoneVeriVC: UIViewController, XHWLNetworkDelegate {
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
            self.sendVeriBtn.isEnabled = false
            XHWLNetwork.shared.postVeriCode(params as NSDictionary, self)
        }else{
            "您输入的手机号格式不正确".ext_debugPrintAndHint()
        }
    }
    
    //验证验证码
    @IBAction func nextStepBtnClicked(_ sender: UIButton) {
        //传给testVerificatCode接口的参数
        let params = ["telephone":registerPhoneNumberTF.text!,"verificatCode":registerVeriTF.text!]
        
        //判断验证码是否为6位
        if registerVeriTF.text!.characters.count == 6{
            XHWLNetwork.shared.postTestPhoneVeriCode(params as NSDictionary, self)
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
        self.registerVeriTF.keyboardType = .numberPad
        self.registerPhoneNumberTF.keyboardType = .numberPad
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_GETVERICODE.rawValue:
            onGetVeriCode(response)
            break
        case XHWLRequestKeyID.XHWL_TESTPHONEVERICODE.rawValue:
            onTestPhoneVeriCode(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        print("&&&&wechatLogin&&&&", error)
    }
    
    //获取验证码之后
    func onGetVeriCode(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            self.isCounting = true
            self.nextStepBtn.isEnabled = true
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        case -4:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    //验证验证码
    func onTestPhoneVeriCode(_ response:[String : AnyObject]){
        self.remainingSeconds = 0
        switch response["errorCode"] as! Int {
        case 200:   //设置密码
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetResetPswVC") as! ForgetResetPswVC
            self.present(vc, animated: true, completion: nil)
            vc.veriCode = self.registerVeriTF.text!
            vc.telephone = self.registerPhoneNumberTF.text!
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
