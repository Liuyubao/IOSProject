//
//  PassRecordTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/12.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit



class PassRecordTableVC: UITableViewController, XHWLNetworkDelegate {
    var visitorsInfo = [Dictionary<String, String>]()
    
    //let visitorsInfo = [
    //    ["name":"张浩然","type":"业主","time":"17:00-18:00"],
    //    ["name":"张浩然","type":"访客","time":"17:00-18:00"],
    //]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //从沙盒中取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        //从userModel中获得token
        XHWLNetwork.sharedManager().getGetEntryLogBtnClicked([userModel?.sysAccount.token], self)
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_GETENTRYLOG.rawValue:
            onGetEntryLog(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    

    func onGetEntryLog(_ response:[String : AnyObject]){
        //得到记录赋值给visitorInfoList
        
        let rows = (response["result"] as! NSDictionary)["rows"] as! NSArray
        if rows.count == 0{
            return
        }
//        print("@@@@@@@@",rows)
        for item in rows{
            let appEntryLog = (item as! NSDictionary)["appEntryLog"] as? NSDictionary

            let sysAccount = appEntryLog!["sysAccount"] as? NSDictionary
            
            //如果是业主
            if sysAccount != nil{
                var visitor = Dictionary<String, String>()
                visitor["name"] = (item as! NSDictionary)["yzName"] as! String
                visitor["type"] = appEntryLog!["type"] as! String
                visitor["time"] = Date.getDateWith(appEntryLog!["openTime"] as! Int, "YYYY-MM-dd HH:mm:ss")
                self.visitorsInfo.append(visitor)
            }
            print(sysAccount)
        }

        
        self.tableView.reloadData()
        
    }
    
//    if let userArray = try? JSONSerialization.jsonObject(with: jsonData,
//                                                         options: .allowFragments) as? [[String: AnyObject]],
//    let phones = userArray?[0]["phones"] as? [[String: AnyObject]],
//    let number = phones[0]["number"] as? String {
//        // 找到电话号码
//        print("第一个联系人的第一个电话号码：",number)
//    }

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
        return visitorsInfo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "visitorInfoCell", for: indexPath)
        
        // 从界面查找到控件元素并设置属性
        (cell.contentView.viewWithTag(1) as! UILabel).text = visitorsInfo[indexPath.item]["name"]
        (cell.contentView.viewWithTag(2) as! UILabel).text = visitorsInfo[indexPath.item]["type"]
        (cell.contentView.viewWithTag(3) as! UILabel).text = visitorsInfo[indexPath.item]["time"]

        return cell
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
