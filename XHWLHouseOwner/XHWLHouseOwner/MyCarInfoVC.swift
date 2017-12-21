//
//  MyCarInfoVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/8.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyCarInfoVC: UIViewController {
    
    @IBOutlet weak var brandTF: UITextField!
    @IBOutlet weak var carTypeTF: UITextField!
    @IBOutlet weak var carPlateTF: UITextField!
    
    
    @IBOutlet weak var colorBtn: UIButton!
    
    @IBOutlet weak var projectTypeTF: UITextField!
    
    @IBOutlet weak var payWayBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureViews(){
        //设置所有按钮tf不可操作
        self.brandTF.isEnabled = false
        self.carTypeTF.isEnabled = false
        self.carPlateTF.isEnabled = false
        self.colorBtn.isEnabled = false
        self.projectTypeTF.isEnabled = false
        self.payWayBtn.isEnabled = false
        self.cameraBtn.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        brandTF.layer.borderWidth = 0.5
        brandTF.layer.cornerRadius = 2
        brandTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        carTypeTF.layer.borderWidth = 0.5
        carTypeTF.layer.cornerRadius = 2
        carTypeTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        carPlateTF.layer.borderWidth = 0.5
        carPlateTF.layer.cornerRadius = 2
        carPlateTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        //        carPlateTF.layer.borderWidth = 0.5
        //        carPlateTF.layer.cornerRadius = 2
        //        carPlateTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        colorBtn.layer.borderWidth = 0.5
        colorBtn.layer.cornerRadius = 2
        colorBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        projectTypeTF.layer.borderWidth = 0.5
        projectTypeTF.layer.cornerRadius = 2
        projectTypeTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        payWayBtn.layer.borderWidth = 0.5
        payWayBtn.layer.cornerRadius = 2
        payWayBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        cameraBtn.contentMode = .scaleAspectFit // 缩放显示, 便于查看全部的图片
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
