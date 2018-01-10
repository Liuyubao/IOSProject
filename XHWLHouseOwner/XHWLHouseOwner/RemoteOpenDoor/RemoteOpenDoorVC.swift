//
//  RemoteOpenDoorVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/21.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.

import UIKit
import Alamofire

class RemoteOpenDoorVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, XHWLNetworkDelegate {
    @IBOutlet weak var doorPickerView: UIPickerView!
    @IBOutlet weak var conformBtn: UIButton!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var jyDoors = [[String:String]]()
//        ["doorID": "test", "serverGuid": "XH0001", "name": "兴海物联正门"],

    var doors = [[String: String]]()
//        ["reqId": "test", "upid": "XH0001", "bldgId":"001", "unitId":"02", "personType":"YZ", "name": "兴海物联正门"],
//        ["reqId": "test", "upid": "XH0001", "bldgId":"001", "unitId":"02", "personType":"YZ", "name": "兴海物联正门"],
//        ["reqId": "test", "upid": "XH0001", "bldgId":"001", "unitId":"02", "personType":"YZ", "name": "兴海物联正门"],
//        ["reqId": "test", "upid": "XH0001", "bldgId":"001", "unitId":"02", "personType":"YZ", "name": "兴海物联正门"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doorPickerView.dataSource = self
        doorPickerView.delegate = self
        
        initDoors()
        
        //设置选择框的默认值
        doorPickerView.selectRow(self.selectedRow,inComponent:0,animated:true)
        doorPickerView.showsSelectionIndicator = false
    }

//    reqId    string    是    请求代码（随意填）
//    upid    string    是    项目编号（使用unitList数组中sysProject实体的entranceCode字段）
//    bldgId    string    是    楼栋编号（使用unitList数组中sysBuilding实体的code字段）
//    unitId    string    是    单元编号（使用unitList数组中的code字段）
//    personType    string    是    人员类型（直接写YZ）
    
    func initDoors(){
        //从沙盒中加载所有room列表
        let roomListData = UserDefaults.standard.object(forKey: "roomList") as? NSData
        let roomListArray = XHWLRoomModel.mj_objectArray(withKeyValuesArray: roomListData?.mj_JSONObject())

        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        //如果是锦阳公馆，初始化jyDoorList
        if curInfoModel?.curProject.name == "长春锦阳公馆D地块"{
            initJYDoors()
            return
        }
        
        //从沙盒中加载数据
        let doorListData = UserDefaults.standard.object(forKey: "allDoorList") as? NSData
        let doorListArray = XHWLDoorInfoModel.mj_objectArray(withKeyValuesArray: doorListData?.mj_JSONObject()) as? NSArray
        
        let personId = UserDefaults.standard.object(forKey: "personId") as! String//参数1
        let date = Date()
        let timeFormatter2 = DateFormatter()
        timeFormatter2.dateFormat = "yyyy-MM-dd-HH-mm"
        let strNowTime = timeFormatter2.string(from: date)
        let dateToken = (strNowTime+"adminXH").md5//参数2
        
        for door in doorListArray!{
            let curDoor = door as! XHWLDoorInfoModel
            let unitDoor = ["doorName":curDoor.doorName,"projectCode": curInfoModel?.curProject.projectCode, "token": dateToken, "doorId":curDoor.doorID, "type": "6", "personId":personId]
            self.doors.append(unitDoor as! [String : String])
        }
        
//        //添加公区门到门禁列表中
//        let publicParams = ["projectId": curInfoModel?.curProject.id]
//        XHWLNetwork.shared.postPublicDoorList(publicParams as NSDictionary, self)
    }
    
    //初始化锦阳公馆的门禁列表
    func initJYDoors(){
        Alamofire.request("http://yan.maxkmtest.com/od/door/list", method: .get).responseJSON{ response in
            switch response.result {
            case .success(let value):
//                print("success:\(value)")
                let data = (value as! NSDictionary)["data"] as! NSArray
//                print("array data:",data)
                for jYDoor in data{
                    let doorDic = jYDoor as! NSDictionary
                    let singleDoor = ["doorID": (doorDic["DoorID"] as! NSNumber).stringValue, "serverGuid": "\(doorDic["ServerGuid"] as! String)", "name": "\(doorDic["Name"] as! String)"]
                    self.jyDoors.append(singleDoor)
                }
                self.doorPickerView.reloadAllComponents()
                
                
            case .failure(let error):
                print("error:\(error)")
                "请求失败！".ext_debugPrintAndHint()
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //从沙盒中获得curInfomodel,如果是锦阳公馆，则初始化jyDoors
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        if curInfoModel?.curProject.name == "长春锦阳公馆D地块"{
            return self.jyDoors.count
        }
        return doors.count
    }
    
    var selectedRow = 1
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let pickedView = UIView()
        let pickedBtn = UIButton()
        
        //从沙盒中获得curInfomodel,如果是锦阳公馆，则初始化jyDoors
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        if curInfoModel?.curProject.name == "长春锦阳公馆D地块"{
            pickedBtn.setTitle(self.jyDoors[row]["name"], for: .normal)
        }else{
            pickedBtn.setTitle(self.doors[row]["doorName"], for: .normal)
        }
        
        pickedBtn.setTitleColor(UIColor.white, for: .normal)
        if row == selectedRow{
            pickedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            pickedBtn.setBackgroundImage(UIImage(named: "Common_pickBg"), for: .normal)
        }else{
            pickedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        pickedBtn.titleLabel?.textAlignment = .center
        pickedBtn.isEnabled = false
        return pickedBtn
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
        self.doorPickerView.reloadAllComponents()
    }
    
    //选中开门
    @IBAction func conformBtnClicked(_ sender: UIButton) {
//        self.conformBtn.isEnabled = false
        
        //从沙盒中获得curInfomodel,如果是锦阳公馆，则调用openJYDoor
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        if curInfoModel?.curProject.name == "长春锦阳公馆D地块"{
            //取出user的信息
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            
            let params = ["token": userModel?.sysAccount.token, "doorID": self.jyDoors[selectedRow]["doorID"], "serverGuid": jyDoors[selectedRow]["serverGuid"]]
            XHWLNetwork.shared.postOpenJYDoor(params as NSDictionary, self)
        }else{
            //远程开门
            let doorName = doors[selectedRow]["doorName"]
            let projectCode = doors[selectedRow]["projectCode"]
            let token = doors[selectedRow]["token"]
            let doorId = doors[selectedRow]["doorId"]
            let personId = doors[selectedRow]["personId"]
            let params2 = ["doorName":doorName,"projectCode": projectCode, "token": token, "doorId":doorId, "type": "6", "personId":personId]
            XHWLNetwork.shared.postRemoteOpenDoorBtnClicked(params2 as NSDictionary, self)
//            //取出user的信息
//            let data = UserDefaults.standard.object(forKey: "user") as? NSData
//            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
//
//            let curDate = Date()
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let timeStr = timeFormatter.string(from: curDate as Date) as String
//
//            //上传远程开门记录
//            let params2 = ["yzId": userModel?.sysAccount.id,"reqId": "test", "upid": doors[selectedRow]["upid"], "doorId": doors[selectedRow]["doorId"], "openTime": timeStr, "type": "业主"]
//            XHWLNetwork.shared.postSaveEntryLogBtnClicked(params2 as NSDictionary, self)
        }
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_REMOTEOPENDOOR.rawValue:
            onRemoteOpenDoor(response)
            break
        case XHWLRequestKeyID.XHWL_SAVEENTRYLOG.rawValue:
            onSaveEntryLog(response)
            break
        case XHWLRequestKeyID.XHWL_GETPUBLICDOORLIST.rawValue:
            onSavePublicRoomList(response)
            break
        case XHWLRequestKeyID.XHWL_OPENJYDOOR.rawValue:
            onOpenJyDoor(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        self.conformBtn.isEnabled = true
    }
    
    //锦阳公馆开门成功调用
    func onOpenJyDoor(_ response:[String : AnyObject]){
        self.noticeSuccess("开门成功！", autoClearTime:1)
        self.dismiss(animated: true, completion: nil)
    }
    
    //开门成功调用
    func onRemoteOpenDoor(_ response:[String : AnyObject]){
        self.noticeSuccess("开门成功！", autoClearTime:1)
        self.dismiss(animated: true, completion: nil)
    }
    
    //加入公区门禁到列表
    func onSavePublicRoomList(_ response:[String : AnyObject]){
        let doorList = response["result"] as! NSArray
        for door in doorList{
            let tempDoor = door as! NSDictionary
            let unitDoor = ["reqId": "test", "upid": tempDoor["projectCode"], "bldgId":tempDoor["buildingCode"], "unitId": tempDoor["unitCode"], "personType":"YZ", "name": "\(tempDoor["projectName"] as! String)\(tempDoor["buildingName"] as! String)\(tempDoor["unitName"] as! String)"]
            self.doors.append(unitDoor as! [String : String])
        }
    }
    
    //保存远程看门记录成功调用
    func onSaveEntryLog(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            "保存远程开门记录成功".ext_debugPrint()
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
