//
//  ServiceCenterVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/11.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class ServiceCenterVC: UIViewController,XHWLNetworkDelegate, UITableViewDelegate, UITableViewDataSource {
    var serviceList = [[String: String]]()
    
    @IBOutlet weak var serviceTableView: UITableView!       //客服列表的tableView
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let device = self.serviceList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell") as! ServiceCell
        cell.serviceName.text = self.serviceList[indexPath.row]["name"]
        //实现闭包绑定cloudBtn按钮事件
        cell.clickWhichCloud = {curCell in
            XHMLProgressHUD.shared.show()
            self.callService400(to:"400")
        }
        //实现闭包绑定phoneBtn按钮事件
        cell.clickWhichPhone = {curCell in
            self.callServicePhone(to: self.serviceList[indexPath.row]["telephone"]!)
        }
        
        return cell
    }
    
    func callServicePhone(to:String){
        let alert = UIAlertController(title: "客服", message: "请联系\(to)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let conformAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
            UIApplication.shared.openURL(NSURL.init(string: "tel://\(to)")! as URL)
        })
        alert.addAction(cancelAction)
        alert.addAction(conformAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func callService400(to:String){
        //推送给400客服
        let params = ["alias": "test","title":"test", "msg": "test", "pushToWebMsg": "{\"videoRoom\":\"400\",\"from\":\"xx\",\"to\":\"xx\",\"type\": \"video\"}"]
        print("@@@@@params", params["pushToWebMsg"] as! String)
        XHWLNetwork.sharedManager().postJPushMsg(params as NSDictionary, self)
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC") as! MainViewController
        mainVC.modalTransitionStyle = .crossDissolve
        self.present(mainVC, animated: true, completion: nil)
        mainVC.performSegue(withIdentifier: "mainToRoom", sender: to)
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_JPUSHMSG.rawValue:
            onPostJPushMsg(response)
            break
        case XHWLRequestKeyID.XHWL_SERVICELIST.rawValue:
            onServiceList(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        "请求失败".ext_debugPrintAndHint()
    }
    
    
    //推送
    func onPostJPushMsg(_ response:[String : AnyObject]){
        print("%%%%%%%%response",response)
        XHMLProgressHUD.shared.hide()
        if response["state"] as! Bool == true{
            "推送成功".ext_debugPrintAndHint()
        }
        
    }
    
    //获取客服列表之后的操作
    func onServiceList(_ response:[String : AnyObject]){
        print("%%%%%%%%response\n",response)
        let result = response["result"] as! NSDictionary
        let rows = result["rows"] as! NSArray
        if rows.count != 0{
            for row in rows{
                let tempRow = row as! NSDictionary
                let serviceItem = ["name": tempRow["name"] as! String, "cloudTalking":"400", "telephone": tempRow["telephone"] as! String]
                self.serviceList.append(serviceItem)
            }
        }
        self.serviceTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serviceTableView.delegate = self
        self.serviceTableView.dataSource = self
        self.serviceTableView.tableFooterView = UIView()
        
        //沙盒获取user
        let data:NSData = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel:XHWLUserModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        
        //从沙盒中获得curInfomodel
        let curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        let curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        let params = ["projectId": curInfoModel?.curProject.id, "token": userModel.sysAccount.token]
        XHWLNetwork.sharedManager().postServiceList(params as NSDictionary, self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
