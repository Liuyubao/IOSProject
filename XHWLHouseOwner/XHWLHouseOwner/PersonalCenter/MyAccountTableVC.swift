//
//  MyAccountTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/11/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyAccountTableVC: UITableViewController, XHWLNetworkDelegate {
    var accountArray = [
        ["name": "张浩然", "type": "家人", "telephone": "15757172281", "state": "N","createTime": "2017-12-10 14:11:02"],
        ["name": "张浩然", "type": "家人", "telephone": "15757172281", "state": "N","createTime": "2017-12-10 14:11:02"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAccountList()
    }
    
    //初始化附属账号列表
    func initAccountList(){
        let data = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        let params = ["token":userModel?.sysAccount.token,"ownerId":userModel?.sysAccount.id]
        XHWLNetwork.shared.postAccountList(params as NSDictionary, self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.accountArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountCell", for: indexPath) as! MyAccountCell
        cell.nameLabel.text = self.accountArray[indexPath.row]["name"]! as! String
        cell.typeLabel.text = self.accountArray[indexPath.row]["type"]! as! String
        cell.telephoneLabel.text = self.accountArray[indexPath.row]["telephone"]! as! String
        cell.createTimeLabel.text = self.accountArray[indexPath.row]["createTime"]! as! String
        //通过闭包设置deleteBtn事件监听
        cell.deleteWhichCellClosure = {curCell in
            let data = UserDefaults.standard.object(forKey: "user") as! NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
            let params = ["attachedTelephone":self.accountArray[indexPath.row]["telephone"] as! String,"token":userModel?.sysAccount.token]
            XHWLNetwork.shared.postDeleteAccount(params as NSDictionary, self)
        }
        if self.accountArray[indexPath.row]["state"] == "N"{
            cell.stopBtn.setTitle("停用", for: .normal)
            cell.indicateColor.image = UIImage(named: "PersonalCenter_greenPoint")
            //通过闭包设置stopBtn事件监听
            cell.setWhichCellClosure = {curCell in
                let data = UserDefaults.standard.object(forKey: "user") as! NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
                let params = ["stat":"D","attachedTelephone":self.accountArray[indexPath.row]["telephone"] as! String,"token":userModel?.sysAccount.token]
                XHWLNetwork.shared.postSetAccountState(params as NSDictionary, self)//设置成功之后，tableview会在viewdidload中自己更新indicatorColor
            }
        }else{
            cell.stopBtn.setTitle("启用", for: .normal)
            cell.indicateColor.image = UIImage(named: "PersonalCenter_redPoint")
            //通过闭包设置stopBtn事件监听
            cell.setWhichCellClosure = {curCell in
                let data = UserDefaults.standard.object(forKey: "user") as! NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
                let params = ["stat":"N","attachedTelephone":self.accountArray[indexPath.row]["telephone"] as! String,"token":userModel?.sysAccount.token]
                XHWLNetwork.shared.postSetAccountState(params as NSDictionary, self)//设置成功之后，tableview会在viewdidload中自己更新indicatorColor
            }
        }
        
        return cell
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_ACCOUNTLIST.rawValue:
            doInitAccountList(response)
            break
        case XHWLRequestKeyID.XHWL_SETACCOUNTSTATE.rawValue:
            doSetAccountState(response)
            break
        case XHWLRequestKeyID.XHWL_DELETEACCOUNT.rawValue:
            doDeleteAccount(response)
            break
        default:
            break
        }
    }
    func doDeleteAccount(_ response:[String : AnyObject]){
        let errorCode = response["errorCode"] as! Int
        switch errorCode {
        case 200:
            self.viewDidLoad()
            break
        case 400,401,201,116:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    func doSetAccountState(_ response:[String : AnyObject]){
        let errorCode = response["errorCode"] as! Int
        switch errorCode {
        case 200:
            self.viewDidLoad()
            break
        case 400,401,116:
            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
        
    func doInitAccountList(_ response:[String : AnyObject]){
        let result = response["result"] as! NSArray
        self.accountArray = []
        for account in result{
            let name = (account as! NSDictionary)["name"] as! String
            var type = (account as! NSDictionary)["type"] as! String
            if type == "family"{
                type = "家人"
            }
            if type == "renter"{
                type = "租户"
            }
            let telephone = (account as! NSDictionary)["telephone"] as! String
            let state = (account as! NSDictionary)["stat"] as! String
            let createTime = (account as! NSDictionary)["createTime"] as! String
            let tempAccount = ["name": name, "type": type, "telephone": telephone, "state": state,"createTime": createTime]
            self.accountArray.append(tempAccount)
            self.tableView.reloadData()
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
