//
//  ForgetResetPswVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/12/4.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class ForgetResetPswVC: UIViewController,XHWLNetworkDelegate {
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var conformPswTF: UITextField!
    @IBOutlet weak var conformRePswTF: UITextField!
    var telephone = ""             //暂存手机号
    var veriCode = ""           //暂存验证码
    
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
    
    //确定按钮点击事件
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //键盘隐藏
        self.view.endEditing(true)
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
        
        if !self.checkPsw(str: self.conformPswTF.text!){
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
        let params = ["telephone":self.telephone, "newPsw":self.conformPswTF.text as! String, "verificatCode":self.veriCode]
        XHWLNetwork.sharedManager().postChangePsw(params as NSDictionary, self)
        
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
                self.view.endEditing(true)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
