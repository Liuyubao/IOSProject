//
//  PersonPassVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/12.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import JSQWebViewController

class PersonPassVC: UIViewController {
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    //访客邀请按钮点击事件
    @IBAction func inviteCustomerBtnClicked(_ sender: UIButton) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteVC")
//        vc?.modalTransitionStyle = .crossDissolve
//        self.present(vc!, animated: true, completion: nil)
        
        let controller = CallerInviteVC()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalTransitionStyle = .crossDissolve
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
