//  ChooseDistrictViewController.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/21.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.

import UIKit
import ElasticTransition

class ChooseDistrictViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ElasticMenuTransitionDelegate, XHWLNetworkDelegate {
    
    @IBOutlet weak var districtPickerView: UIPickerView!

    var projectListData: NSData?
    var projectListArray: NSArray?
    var contentLength:CGFloat = 320
    var dismissByBackgroundTouch = true
    var dismissByBackgroundDrag = true
    var dismissByForegroundDrag = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return UIStatusBarStyle.lightContent }
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        //从沙盒中获得curInfomodel，并且更新curProject
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        if #available(iOS 10.0, *) {
            AppDelegate.shared().getWilddogToken(curInfoModel?.curProject.projectCode as! String, userModel?.telephone as! String)
        } else {
            
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        if (curInfoModel?.isFirstToSpace)! {
            self.view.window?.rootViewController = vc
            curInfoModel?.setValue(false, forKey: "isFirstToSpace")
        }
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
    //释放自己，跳转到spaceVC
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //从沙盒中获得curInfomodel，并且更新curProject
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        curInfoModel?.setValue(self.projectListArray![districtPickerView.selectedRow(inComponent: 0)] as! XHWLProjectModel, forKey: "curProject")
        UserDefaults.standard.synchronize()
        //重新请求更新沙盒授权门禁列表
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let strNowTime = timeFormatter.string(from: date)
        let dateToken = (strNowTime+"adminXH").md5
        let params = ["projectCode":curInfoModel?.curProject.projectCode,"token":dateToken,"userName":userModel?.name,"phone":userModel?.telephone]
        XHWLNetwork.shared.postGetAllDoors(params as NSDictionary, self)
        
        self.dismiss(animated: true, completion: nil)
        //重新保存到沙盒
        self.noticeSuccess("您选择了 \((self.projectListArray![districtPickerView.selectedRow(inComponent: 0)] as! XHWLProjectModel).name)",autoClearTime:1)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        districtPickerView.dataSource = self
        districtPickerView.delegate = self
        configureProjectList()
        //设置选择框的默认值
        districtPickerView.selectRow(1,inComponent:0,animated:true)
    }
    
    func configureProjectList(){
        //从沙盒中加载数据
        projectListData = UserDefaults.standard.object(forKey: "projectList") as? NSData
        projectListArray = XHWLProjectModel.mj_objectArray(withKeyValuesArray: projectListData?.mj_JSONObject()) as? NSArray
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.projectListArray!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (self.projectListArray?[row] as? XHWLProjectModel)?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let viewlabel = UILabel()
        viewlabel.text = (self.projectListArray?[row] as? XHWLProjectModel)?.name
        viewlabel.textColor = UIColor(red: 82/255.0, green: 239/255.0, blue: 254/255.0, alpha: 1.0)
//        viewlabel.textColor = UIColor.white
        viewlabel.textAlignment = .center
        return viewlabel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_GETALLDOORS.rawValue:
            onSaveDoorValues(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    //保存门禁列表到沙盒中
    func onSaveDoorValues(_ response:[String : AnyObject]){
        switch response["errorCode"] as! Int {
        case 200:
            let result = response["result"] as! NSDictionary
            UserDefaults.standard.set("1419231E0606060606A8", forKey: "openData")
            UserDefaults.standard.set(result["personId"] as! String, forKey: "personId")
            //保存所有门禁列表
            if let doorList:NSArray = result["doorList"] as? NSArray{
                let modelData3:NSData = doorList.mj_JSONData()! as NSData
                UserDefaults.standard.set(modelData3, forKey: "allDoorList")
            }
            UserDefaults.standard.synchronize()
            break
        case 111,-1,2:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    

}
