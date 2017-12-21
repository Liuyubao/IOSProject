//
//  MonthPayInfoVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MonthPayInfoVC: UIViewController {
    @IBOutlet weak var expirationFrom: UITextField!
    @IBOutlet weak var expirationTo: UITextField!
    @IBOutlet weak var carPlate: UILabel!
    
    @IBOutlet weak var monthInfoView: UIView!
    @IBOutlet weak var paySuccessView: UIView!
    @IBOutlet weak var carIV: UIImageView!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func seePayHistoryBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MonthPayHistoryVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true, completion: nil)
    }
    
    //确认微信支付
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(1)
        self.view.bringSubview(toFront: self.paySuccessView)
        self.monthInfoView.alpha = 0
        self.paySuccessView.alpha = 1
        
        UIView.commitAnimations()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        expirationFrom.layer.borderWidth = 0.5
        expirationFrom.layer.cornerRadius = 2
        expirationFrom.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        expirationTo.layer.borderWidth = 0.5
        expirationTo.layer.cornerRadius = 2
        expirationTo.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
    }


}
