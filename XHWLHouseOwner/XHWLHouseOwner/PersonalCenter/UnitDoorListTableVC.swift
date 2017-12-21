//
//  UnitDoorListTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/10.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class UnitDoorListTableVC: UITableViewController {
    var unitDoorList = [String]()   //保存单元门禁列表
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //从沙盒中加载所有room列表
        let roomListData = UserDefaults.standard.object(forKey: "roomList") as? NSData
        let roomListArray = XHWLRoomModel.mj_objectArray(withKeyValuesArray: roomListData?.mj_JSONObject())
        
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        //添加当前项目下的unit到门禁列表中
        for room in roomListArray!{
            let roomModel = room as? XHWLRoomModel
            if roomModel?.projectName == curInfoModel?.curProject.name{
                self.unitDoorList.append("\(roomModel?.projectName as! String)\(roomModel?.buildingName as! String)\(roomModel?.unitName as! String)")
            }
        }

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
        return self.unitDoorList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "unitDoorListCell", for: indexPath)
        
        // 设置cell的值
        (cell.contentView.viewWithTag(1) as! UILabel).text = self.unitDoorList[indexPath.row]
        
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
