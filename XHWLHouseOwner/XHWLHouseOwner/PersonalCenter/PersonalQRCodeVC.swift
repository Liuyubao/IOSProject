//
//  PersonalQRCodeVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/15.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class PersonalQRCodeVC: UIViewController {
    @IBOutlet weak var yzName: UILabel!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var headIconIV: UIImageView!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let userData = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: userData?.mj_JSONObject())
        let curInfoData = UserDefaults.standard.object(forKey: "curInfo") as? NSData
        let curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData?.mj_JSONObject())
        yzName.text = userModel?.name
        projectName.text = curInfoModel?.curProject.name
        //修改头像
        if let headImgUrl = UserDefaults.standard.object(forKey: "imageUrl") as? String{
            /**
             *  初始化data。从URL中获取数据
             */
            var data = NSData(contentsOf: URL(string: headImgUrl)!)
            /**
             *  创建图片
             */
            var image = UIImage(data:data as! Data, scale: 1.0)
            self.headIconIV.image = image
            
            self.headIconIV.contentMode = .scaleAspectFill
            self.headIconIV.layer.masksToBounds = true
            self.headIconIV.layer.cornerRadius = self.headIconIV.frame.width/2
            
        }else{
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
