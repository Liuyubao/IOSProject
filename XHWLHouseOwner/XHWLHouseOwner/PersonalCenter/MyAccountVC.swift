//
//  MyAccountVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyAccountVC: UIViewController {
    
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var embededTableVC = UIViewController()
    
    @IBAction func addBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditAccountVC") as! EditAccountVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
