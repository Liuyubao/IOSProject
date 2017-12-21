//
//  ChooseDistrictViewController.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/21.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import ElasticTransition

class ChooseDistrictViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ElasticMenuTransitionDelegate {

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
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        if (curInfoModel?.isFirstToSpace)! {
            self.view.window?.rootViewController = vc
            curInfoModel?.setValue(false, forKey: "isFirstToSpace")
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //释放自己，跳转到spaceVC
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //从沙盒中获得curInfomodel，并且更新curProject
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        curInfoModel?.curProject = self.projectListArray![districtPickerView.selectedRow(inComponent: 0)] as! XHWLProjectModel
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
//        if (curInfoModel?.isFirstToSpace)! {
//            self.view.window?.rootViewController = vc
//            curInfoModel?.setValue(false, forKey: "isFirstToSpace")
//        }
        self.dismiss(animated: true, completion: nil)
        //重新保存到沙盒
        curInfoData = curInfoModel?.mj_JSONData() as! NSData
        UserDefaults.standard.set(curInfoData, forKey: "curInfo")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
