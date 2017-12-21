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
        
        //取出user的信息
        let params = ["telephone":self.telephone, "newPsw":self.conformPswTF.text as! String, "verificatCode":self.veriCode]
        XHWLNetwork.shared.postChangePsw(params as NSDictionary, self)
        
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
