//
//  MonthPayHistoryTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MonthPayHistoryTableVC: UITableViewController {
    var payRecords=[
        ["carPlate": "粤BQC129","projectName":"中海华庭", "payFee":"5元", "payTime":"2017-10-13 09:55"],
        ["carPlate": "粤B432TT","projectName":"中海华庭", "payFee":"15元", "payTime":"2017-10-13 15:40"],
        ["carPlate": "粤B1A3P7","projectName":"中海华庭", "payFee":"10元", "payTime":"2017-10-12 10:42"],
        ["carPlate": "粤B36L46","projectName":"中海华庭", "payFee":"10元", "payTime":"2017-10-12 09:42"],
        ["carPlate": "粤BPI6M8","projectName":"中海华庭", "payFee":"15元", "payTime":"2017-10-11 09:01"],
        ["carPlate": "粤B7TY90","projectName":"中海华庭", "payFee":"10元", "payTime":"2017-10-11 09:40"],
        ["carPlate": "粤B630CP","projectName":"中海华庭", "payFee":"35元", "payTime":"2017-10-09 20:40"],
        ["carPlate": "粤BL70V6","projectName":"中海华庭", "payFee":"15元", "payTime":"2017-10-09 17:40"],
        ["carPlate": "粤BQC129","projectName":"中海华庭", "payFee":"5元", "payTime":"2017-10-09 09:55"],
        ["carPlate": "粤B432TT","projectName":"中海华庭", "payFee":"15元", "payTime":"2017-10-07 15:40"],
        ["carPlate": "粤B1A3P7","projectName":"中海华庭", "payFee":"10元", "payTime":"2017-10-07 10:42"],
        ["carPlate": "粤B36L46","projectName":"中海华庭", "payFee":"10元", "payTime":"2017-10-06 09:42"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return payRecords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayHIstoryCell", for: indexPath) as! PayHistoryCell
        cell.carPlate.text = self.payRecords[indexPath.row]["carPlate"] as! String
        cell.projectName.text = self.payRecords[indexPath.row]["projectName"] as! String
        cell.payFee.text = self.payRecords[indexPath.row]["payFee"] as! String
        cell.payTime.text = self.payRecords[indexPath.row]["payTime"] as! String

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
