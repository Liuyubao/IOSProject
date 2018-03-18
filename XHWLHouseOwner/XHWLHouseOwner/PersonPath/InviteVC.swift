//
//  InviteVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/12.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class InviteVC: UIViewController {
    
    @IBOutlet weak var friendName: UITextField! //访客姓名
    
    @IBOutlet weak var friendTel: UITextField!  //访客电话
    
    @IBOutlet weak var carPlateNumBtn: XNInputCarNumebrButton!//车牌号码
    // 自定义的键盘View
    fileprivate let keyboardView = XNKeyboardView()
    
    @IBOutlet weak var effectBeginTimeBtn: UIButton!    //生效日期
    
    @IBOutlet weak var authDoorBtn: UIButton!   //授权门禁
    
    //返回上一级
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureTFs(){
        self.friendTel.keyboardType = .numberPad    //设置为数字键盘
    }
    
    @IBAction func produceBtnClicked(_ sender: UIButton) {
        let qrVC = self.storyboard?.instantiateViewController(withIdentifier: "ProduceQRCodeVC") as! ProduceQRCodeVC
        qrVC.modalTransitionStyle = .crossDissolve
        self.present(qrVC, animated: true, completion: nil)
        let userData = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: userData?.mj_JSONObject())
        qrVC.visitorInfo.text = "\(self.friendName.text as! String) \(self.friendTel.text as! String)"
        qrVC.hosterInfo.text = "\(userModel?.name as! String) \(userModel?.telephone as! String)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        qrVC.validFrom.text = formatter.string(from: Date())
        qrVC.validTo.text = self.effectBeginTimeBtn.currentTitle
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTFs()
        
        // 创建 车牌号显示的View
        initInputCarNumebrView()
        
        // 创建键盘
        initKeyboardView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        
        
    }
    
    //点击旁边收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegin 发生了")
        // 文本框的隐藏关闭
        keyboardViewShowOrHidden(false)
        self.view.endEditing(true)
    }
    
    // MARK:
    // MARK: 创建键盘
    /// 创建键盘
    fileprivate func initKeyboardView() {
        
        // 创建键盘View
        view.addSubview(keyboardView);
        
        keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 216)
        
        // 设置代理
        keyboardView.xnKeyboardViewDelegate = self
        
        // 加载内容
        keyboardView.xnKeyboardViewLoadContent()
    }
    
    // MARK:
    // MARK: 创建 车牌号显示的View
    /// 创建 车牌号显示的View
    fileprivate func initInputCarNumebrView() {
        
        // 加载里面内容
        carPlateNumBtn.inputCarNumebrViewLoadContent()
        
        // 添加事件
        carPlateNumBtn.addTarget(self, action: #selector(InviteVC.clickInputCarNumebrButton(_:)), for: .touchDown)
        /*
         点击立即调用
         TouchDown
         
         */
    }
    
    // MARK:
    // MARK: 手势响应事件
    /// 手势响应事件
    @objc fileprivate func clickInputCarNumebrButton(_ sender: XNInputCarNumebrButton) {
        //print("----\(sender.view)")
        
        self.view.endEditing(true)
        // 文本框的隐藏关闭
        keyboardViewShowOrHidden(true)
    }
    
    // MARK:
    // MARK: 键盘的 出现和隐藏
    /// 键盘的 出现和隐藏 true 显示
    fileprivate func keyboardViewShowOrHidden(_ isShow: Bool) {
        // 为真 显示
        let y = isShow ? UIScreen.main.bounds.height - self.keyboardView.height : UIScreen.main.bounds.height
        
        // 如果一样不需要做动画
        if keyboardView.y == y {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.keyboardView.y = y
        })
        
    }
    
    //键盘的出现
    func keyBoardWillShow(_ notification: Notification){
        //收起车牌键盘
        keyboardViewShowOrHidden(false)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        friendName.layer.borderWidth = 0.5
        friendName.layer.cornerRadius = 2
        friendName.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        friendTel.layer.borderWidth = 0.5
        friendTel.layer.cornerRadius = 2
        friendTel.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
//        carPlateNumBtn.layer.borderWidth = 0.5
//        carPlateNumBtn.layer.cornerRadius = 2
//        carPlateNumBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        effectBeginTimeBtn.layer.borderWidth = 0.5
        effectBeginTimeBtn.layer.cornerRadius = 2
        effectBeginTimeBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        authDoorBtn.layer.borderWidth = 0.5
        authDoorBtn.layer.cornerRadius = 2
        authDoorBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        
    }
    
    @IBAction func effectBeginTimeBtnClicked(_ sender: UIButton) {
        let currentDate = Date()
        
        var dateComponents = DateComponents()
        dateComponents.month = 3
        
        let threeMonthLater = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        dateComponents.hour = 1
        let minEnd = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .blue,
                                          font: UIFont.boldSystemFont(ofSize: 14),
                                          showCancelButton: true)
        datePicker.show("请选择失效时间",
                        doneButtonTitle: "确认",
                        cancelButtonTitle: "取消",
                        minimumDate: minEnd,
                        maximumDate: threeMonthLater,
                        datePickerMode: .dateAndTime) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                self.effectBeginTimeBtn.setTitle(formatter.string(from: dt), for: .normal)
                            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK:
// MARK: 自定义键盘的 代理方法
extension InviteVC: XNKeyboardViewDelegate {
    
    // MARK:
    // MARK: 获得输入完整的车牌号码
    func getWholePlateNumber() -> String{
        var wholePlateNumber = ""
        for label in carPlateNumBtn.labelArray{
            if label.text != nil{
                wholePlateNumber.append(label.text!)
            }
        }
        return wholePlateNumber
    }
    
    // MARK:
    // MARK: 代理方法 监听点击 赋值
    func XNKeyboardViewMethod(_ title: String) {
        
        var number = 1
        
        for i in carPlateNumBtn.labelArray {
            
            // 当输入到最后一个的时候 让其不被删除 可以赋值
            if number == carPlateNumBtn.labelArray.count {
                
                i.text = title
                
                return
                
            }
            
            if i.text == nil {
                
                i.text = title
                
                return
            }
            
            number += 1
        }
        
        
    }
    
    
    // MARK:
    // MARK: 代理方法 删除
    /// 代理方法 删除
    func XNKeyboardViewDeleteMethod() {
        
        // 递减操作
        for i in carPlateNumBtn.labelArray.reversed() {
            
            // 判断是不是中文
            if i.text?.xnIsChinese() == true {
                
                // 删除字符
                i.text = nil;
                
                //  显示出 汉字键盘
                keyboardView.keyboardViewToNumberAndGrapheme.alpha = 0
                
                return;
            }
            
            if i.text != nil {
                
                i.text = nil;
                
                return;
            }
        }
        
        
    }
    
    // MARK:
    // MARK: 点击了对勾
    func XNKeyboardViewRightMethod() {
        // 文本框的隐藏
        keyboardViewShowOrHidden(false)
    }
}
