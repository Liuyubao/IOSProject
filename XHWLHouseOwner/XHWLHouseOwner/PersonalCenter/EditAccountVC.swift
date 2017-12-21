//
//  EditAccountVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import DropDown

class EditAccountVC: UIViewController, XHWLNetworkDelegate {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var telephoneTF: UITextField!
    @IBOutlet weak var nationalIdTF: UITextField!
    
    @IBOutlet weak var typeBtn: UIButton!
    let typeDD = DropDown()  //类型下拉框
    
    
    @IBAction func typeBtnClicked(_ sender: UIButton) {
        typeDD.show()
    }
    
    
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //键盘隐藏
        self.view.endEditing(true)
        
        //userNameTF是否为空
        if self.userNameTF.text == ""{
            "使用人不能为空".ext_debugPrintAndHint()
            return
        }
        
        //typeBtn是否为空
        if self.typeBtn.currentTitle == ""{
            "类型不能为空".ext_debugPrintAndHint()
            return
        }
        
        //telephoneTF是否为空
        if self.telephoneTF.text == ""{
            "手机号码不能为空".ext_debugPrintAndHint()
            return
        }
        
        //nationalIdTF是否为空
        if self.nationalIdTF.text == ""{
            "身份证号码不能为空".ext_debugPrintAndHint()
            return
        }else if !Validation.cardNum(self.nationalIdTF.text!).isRight{
            "身份证号码格式不正确".ext_debugPrintAndHint()
            return
        }
        
        let data = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        let giveRights = "[\n{'projectId': '5ba97a83-8e1f-11e7-a2f9-4ccc6aeb6282','rightsId': 'r1,r2'},{'projectId': '5e93182f-8e1f-11e7-a2f9-4ccc6aeb6282','rightsId': 'r1,r3'}]"
        
        let params = ["token":userModel?.sysAccount.token,"name":self.userNameTF.text as! String,"type":self.typeBtn.currentTitle as! String,"telephone":self.telephoneTF.text as! String,"identity":self.nationalIdTF.text as! String,"rights":giveRights]
        
        XHWLNetwork.shared.postAddAccount(params as NSDictionary, self)
        
    }
    
    //配置type下拉框
    func setupTypeDropDown() {
        typeDD.anchorView = typeBtn
        
        typeDD.bottomOffset = CGPoint(x: 0, y: typeBtn.bounds.height)
        
        typeDD.dataSource = [
            "家人",
            "租户"
        ]
        
        typeDD.selectionAction = { [unowned self] (index, item) in
            self.typeBtn.setTitle(item, for: .normal)
        }
    }
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 文本输入框的隐藏关闭
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var chooseDoorBtn: UIButton!
    let chooseDoorsDD = DropDown()  //授权门禁下拉框
    
    @IBOutlet weak var chooseFunctionsBtn: UIButton!
    let chooseFunctionsDD = DropDown()  //授权功能下拉框
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTypeDropDown()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userNameTF.layer.borderWidth = 0.5
        userNameTF.layer.cornerRadius = 2
        userNameTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        telephoneTF.layer.borderWidth = 0.5
        telephoneTF.layer.cornerRadius = 2
        telephoneTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        //        carPlateTF.layer.borderWidth = 0.5
        //        carPlateTF.layer.cornerRadius = 2
        //        carPlateTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        nationalIdTF.layer.borderWidth = 0.5
        nationalIdTF.layer.cornerRadius = 2
        nationalIdTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        typeBtn.layer.borderWidth = 0.5
        typeBtn.layer.cornerRadius = 2
        typeBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        
    }
    
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_ADDACCOUNT.rawValue:
            switch response["errorCode"] as! Int{
            case 401, 400, 201:
                (response["message"] as! String).ext_debugPrintAndHint()
                break
            case 200:
                "添加账号成功".ext_debugPrintAndHint()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
