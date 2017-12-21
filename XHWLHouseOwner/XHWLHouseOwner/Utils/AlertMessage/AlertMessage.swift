//
//  AlertMessage.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/25.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class AlertMessage{
    static func showAlertMessage(vc: UIViewController, alertMessage: String, duration: Int){
        let alertController = UIAlertController(title: alertMessage,message: nil, preferredStyle: .alert)
        //显示提示框
        vc.present(alertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            vc.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    static func showAlertMessage(vc: UIViewController, alertMessage: String, block: @escaping (()->())){
        let alertController = UIAlertController(title: alertMessage,message: nil, preferredStyle: .alert)
        
        let action1:UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            alertController.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        alertController.addAction(action1)
        
        let action2:UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            
            block()
            vc.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        alertController.addAction(action2)
        
        //显示提示框
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func showOneAlertMessage(vc: UIViewController, alertMessage: String, block: @escaping (()->())){
        let alertController = UIAlertController(title: alertMessage,message: nil, preferredStyle: .alert)
        
        let action2:UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            
            block()
            vc.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action2)
        
        //显示提示框
        vc.present(alertController, animated: true, completion: nil)
    }
}
