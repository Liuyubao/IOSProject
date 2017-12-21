//
//  PersonalCenterVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.

import UIKit

class PersonalCenterVC: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func serviceBtnClicked(_ sender: UIButton) {
//        let alert = UIAlertController(title: "客服", message: "请联系13123375305", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        let conformAction = UIAlertAction(title: "确定", style: .default, handler: {
//            action in
//                UIApplication.shared.openURL(NSURL.init(string: "tel://13123375305")! as URL)
//        })
//        alert.addAction(cancelAction)
//        alert.addAction(conformAction)
//        self.present(alert, animated: true, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceCenterVC")
        self.present(vc!, animated: true)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.01)
        
        //约束根据屏幕高度做适配
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        print("屏幕高度：\(screenHeight)")
        switch screenHeight {
        case 480.0://4s
            scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.6)
        case 568.0://5s
            scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.3)
        case 667.0://6s
            scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.3)
        default:
            break
        }
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
