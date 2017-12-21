//
//  PublicDoorLIstTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/10.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class PublicDoorLIstTableVC: UITableViewController, XHWLNetworkDelegate {
    var publicDoorList = [String]()   //保存公区门禁列表
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        //添加公区门到门禁列表中
        let publicParams = ["projectId": curInfoModel?.curProject.id]
        XHWLNetwork.shared.postPublicDoorList(publicParams as NSDictionary, self)

    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_GETPUBLICDOORLIST.rawValue:
            onSavePublicRoomList(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    //加入公区门禁到列表
    func onSavePublicRoomList(_ response:[String : AnyObject]){
        let doorList = response["result"] as! NSArray
        for door in doorList{
            let tempDoor = door as! NSDictionary
            self.publicDoorList.append("\(tempDoor["projectName"] as! String)\(tempDoor["buildingName"] as! String)\(tempDoor["unitName"] as! String)")
        }
        self.tableView.reloadData()
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
        return self.publicDoorList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "publicDoorListCell", for: indexPath)
        
        // 设置cell的值
        (cell.contentView.viewWithTag(1) as! UILabel).text = self.publicDoorList[indexPath.row]
        
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
