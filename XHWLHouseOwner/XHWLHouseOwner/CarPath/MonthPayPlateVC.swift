//
//  MonthPayPlateVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/13.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MonthPayPlateVC: UIViewController {
    
    /// 自定义的键盘View
    fileprivate let keyboardView = XNKeyboardView()
    
    /// 车牌号文本框
    fileprivate let inputCarNumebrButton = XNInputCarNumebrButton()

    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var monthPayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 车牌号显示的View
        initInputCarNumebrView()
        
        // 创建键盘
        initKeyboardView()

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
        
        // 创建 车牌号显示的View
        inputCarNumebrButton.frame = CGRect(x: 86, y: 89, width:monthPayView.frame.width-172, height: 21)
        
        monthPayView.addSubview(inputCarNumebrButton)
        
        // 加载里面内容
        inputCarNumebrButton.inputCarNumebrViewLoadContent()
        
        // 添加事件
        inputCarNumebrButton.addTarget(self, action: #selector(MonthPayPlateVC.clickInputCarNumebrButton(_:)), for: .touchDown)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 文本框的隐藏关闭
        keyboardViewShowOrHidden(false);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

}

// MARK:
// MARK: 自定义键盘的 代理方法
extension MonthPayPlateVC: XNKeyboardViewDelegate {
    
    // MARK:
    // MARK: 代理方法 监听点击 赋值
    func XNKeyboardViewMethod(_ title: String) {
        
        var number = 1
        
        for i in inputCarNumebrButton.labelArray {
            
            // 当输入到最后一个的时候 让其不被删除 可以赋值
            if number == inputCarNumebrButton.labelArray.count {
                
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
        for i in inputCarNumebrButton.labelArray.reversed() {
            
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
