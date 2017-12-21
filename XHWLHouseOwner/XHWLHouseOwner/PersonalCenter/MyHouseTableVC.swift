//
//  MyHouseTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/22.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyHouseTableVC: UITableViewController {
    
    var tempArray = [
        [1],
        [2],
        [3]
    ]
    var roomListData: NSData?
    var roomListArray: NSArray?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //从沙盒中加载数据
        roomListData = UserDefaults.standard.object(forKey: "roomList") as? NSData
        roomListArray = XHWLRoomModel.mj_objectArray(withKeyValuesArray: roomListData?.mj_JSONObject())
        if roomListArray == nil{
            self.noticeError("您的账户未绑定", autoClearTime: 1)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }

        //初始化个人信息
        
        
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
        if roomListArray == nil{
            return 0
        }
        return self.roomListArray!.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyHouseCell", for: indexPath) as! MyHouseCell
//        cell.projectName.text = (self.unitListArray?[indexPath.row] as? XHWLUnitModel)?.building.projectName
        cell.projectName.text = (self.roomListArray?[indexPath.row] as? XHWLRoomModel)?.projectName
        cell.buildingName.text = (self.roomListArray?[indexPath.row] as? XHWLRoomModel)?.buildingName
        cell.unitName.text = "\((self.roomListArray?[indexPath.row] as? XHWLRoomModel)?.unitName as! String) \((self.roomListArray?[indexPath.row] as? XHWLRoomModel)?.name as! String)"

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
