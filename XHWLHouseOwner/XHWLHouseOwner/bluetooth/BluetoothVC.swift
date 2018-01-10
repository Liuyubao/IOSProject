//
//  BluetoothVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/19.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import CoreBluetooth
import CardReaderSDK
import ElasticTransition

class BluetoothVC:UIViewController, UITableViewDelegate, UITableViewDataSource, XHWLNetworkDelegate {

    let macNo = "20c38ff4ffe0"
    let cardNo = "41516039624d0cb4c0f1b5e7"
    @IBOutlet weak var addDoorOpenView: UIView!
    
    var devices:[DeviceRecord] = []
    var curDevice:DeviceRecord? = nil
//    {
//        didSet {
//            if self.curDevice == nil {
//                self.btnBind.isEnabled = false
//                self.btnOpen.isEnabled = false
//                self.btnStop.isEnabled = false
//            }else{
//                self.btnBind.isEnabled = true
//                self.btnStop.isEnabled = true
//                if self.curDevice?.cardNo == nil {
//                    self.btnOpen.isEnabled = false
//                }else{
//                    self.btnOpen.isEnabled = true
//                }
//            }
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        //从沙盒中加载蓝牙的数据
        XHWLNetwork.shared.getBluetoothRecord([userModel?.sysAccount.id, "ios"], self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.bluetoothTableView.delegate = self
        self.bluetoothTableView.dataSource = self
//        initDevices()
        
        //初始化
        CardReaderAPI.Init()
        
    }
    
    func initDevices(){
        let device = DeviceRecord("测试","20c38ff4ffe0")
        device.cardNo = "b6e997df0864cbd51411dcd5"
//        let device2 = DeviceRecord("测试",mac: "20c38ff4ffe0")
//        device2.cardNo = "b6e997df0864cbd51411dcd5"
        self.devices.append(device)
//        self.devices.append(device)
    }
    
    class DeviceRecord {
        init(_ name: String,_ mac: String) {
            self.name = name
            self.mac = mac
            self.cardNo = ""
        }
        
        init(name: String,mac: String, cardNo: String) {
            self.name = name
            self.mac = mac
            self.cardNo = cardNo
        }
        
        var name: String       //blueToothCustomName
        var mac: String         //blueToothOrginName
        var cardNo: String
    }
    
    @IBOutlet weak var bluetoothTableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = self.devices[indexPath.row]
        self.curDevice = device
        
        self.bluetoothTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = self.devices[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "localBluetoothCell") as! LocalBlueToothTableViewCell
        cell.localDeviceName.text = device.name
        cell.getWhcihCellBlock = { curCell in
//            self.pleaseWaitWithMsg("正在开门中……")
            XHMLProgressHUD.shared.show()
            self.open(device: device)
        }
//        cell.localOpenDoorBtn.addTarget(self, action: #selector(self.open(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 要显示自定义的action,cell必须处于编辑状态
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
            //取出user的信息
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            
            let params = ["address": self.devices[indexPath.row].mac, "accountId": userModel?.sysAccount.id, "systemType": "ios"]
            XHWLNetwork.shared.postDeleteBluetooth(params as NSDictionary, self)
            
            self.devices.remove(at: indexPath.row)
            self.bluetoothTableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        delete.backgroundColor = UIColor.clear
        
        return [delete]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //删除
        let deleteRowAction:UIContextualAction = UIContextualAction.init(style: .destructive, title: "删除") { (action, sourceView, completionHandler) in
            //取出user的信息
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            
            let params = ["address": self.devices[indexPath.row].mac, "accountId": userModel?.sysAccount.id, "systemType": "ios"]
            XHWLNetwork.shared.postDeleteBluetooth(params as NSDictionary, self)
            
            self.devices.remove(at: indexPath.row)
            self.bluetoothTableView.deleteRows(at: [indexPath], with: .fade)
            
            completionHandler(true)
        }
        //        deleteRowAction.image = UIImage(named:"icon")
        deleteRowAction.backgroundColor = UIColor.clear
        
        let config:UISwipeActionsConfiguration = UISwipeActionsConfiguration.init(actions: [deleteRowAction])
        
        return config
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addDoorOpenView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addDoorOpenBtnClicked))
        tapGesture.numberOfTapsRequired = 1
        addDoorOpenView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func addDoorOpenBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BluetoothScanVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    //开门
    func open(device: DeviceRecord){
//        // autoDisconnect: false，不自动断开连接，可以手动屌用Stop方法断开连接
//        CardReaderAPI.OpenDoor(device.mac, cardNO: device.cardNo, timeOut: 10, autoDisconnect: true, callback: {(err) -> Void in
//            XHMLProgressHUD.shared.hide()
//            if err == nil {
//                //取出user的信息
//                let data = UserDefaults.standard.object(forKey: "user") as? NSData
//                let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
//
//                let curDate = Date()
//                let timeFormatter = DateFormatter()
//                timeFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
//                let timeStr = timeFormatter.string(from: curDate as Date) as String
//
//                //上传蓝牙开门记录
//                let params = ["blueToothOrginName": device.mac, "blueToothCustomName": device.name, "yzId": userModel?.sysAccount.id,"doorId": device.mac, "openTime": timeStr, "type": "业主"]
//                XHWLNetwork.shared.postSaveEntryLogBtnClicked(params as NSDictionary, self)
//
//                self.noticeSuccess("开门成功")
////                "开门成功".ext_debugPrintAndHint()
//            }else{
//                self.noticeError(err!.description!)
//            }
//        })
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_SAVEENTRYLOG.rawValue:
            onSaveEntryLog(response)
            break
        case XHWLRequestKeyID.XHWL_GETBLUETOOTH.rawValue:
            onGetBluetoothRecord(response)
            break
        case XHWLRequestKeyID.XHWL_DELETEBLUETOOTH.rawValue:
            onPostDeleteBluetooth(response)
            break
        default:
            break
        }
    }
    
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    //删除蓝牙绑卡设备记录
    func onPostDeleteBluetooth(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            "删除蓝牙记录成功".ext_debugPrintAndHint()
        }
        
    }
    
    //获取蓝牙绑卡设备记录
    func onGetBluetoothRecord(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            "获取蓝牙绑卡设备记录".ext_debugPrint()
            let result = response["result"] as! NSDictionary
            let rows = result["rows"] as! NSArray
            //如果蓝牙记录为0
            if rows.count == 0{
                return
            }
            print("@@@@@@@@@@@rows", rows)
            for row in rows{
                let tempName = (row as! NSDictionary)["name"] as! String
                let tempMac = (row as! NSDictionary)["address"] as! String
                let tempCardNo = (row as! NSDictionary)["currentCardStr"] as! String
                var newDeviceRecord = DeviceRecord(name: tempName, mac: tempMac, cardNo: tempCardNo)
                devices.append(newDeviceRecord)
            }
        }
        self.bluetoothTableView.reloadData()
    }
    
    func onSaveEntryLog(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            "保存蓝牙开门记录成功".ext_debugPrint()
        }
    }
    
    
    
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
