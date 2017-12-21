//
//  MyCarTableVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class MyCarTableVC: UITableViewController {
    
//    var carInfoClosure: (NSDictionary)->()={para in}    //查看carInfo
    
    var carsArray = [
        ["brandName": "宝马 528Li", "plateNum": "粤B12345", "color": "白色", "pic": UIImage(named:"car1.jpeg"),"project": "中海华庭", "payWay": "临停缴费"],
        ["brandName": "雷克萨斯 RX200t", "plateNum": "粤B6X888", "color": "白色", "pic": UIImage(named:"car2.jpeg"), "project": "中海华庭", "payWay": "月卡缴费"],
        ["brandName": "路虎 星脉S", "plateNum": "粤BAB999", "color": "棕色", "pic": UIImage(named:"car3.jpeg"), "project": "中海华庭", "payWay": "临停缴费"]
    ]
    
    @IBOutlet weak var addCarView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addCarView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addCarInfoBtnClicked))
        tapGesture.numberOfTapsRequired = 1
        addCarView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func addCarInfoBtnClicked(_ sender: UIButton) {
        let applyVC = storyboard?.instantiateViewController(withIdentifier: "CarApplyVC") as! CarApplyVC
        applyVC.addCarClosure = {para in
            print(para)
            self.carsArray.append(para as! [String : Any])
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.carsArray.count-1, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
        applyVC.modalTransitionStyle = .crossDissolve
        self.present(applyVC, animated: true, completion: nil)
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
        return self.carsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCarCell", for: indexPath) as! MyCarCell
        cell.carPicIV.image = self.carsArray[indexPath.row]["pic"] as! UIImage
        cell.brandName.text = self.carsArray[indexPath.row]["brandName"]! as! String
        cell.color.text = self.carsArray[indexPath.row]["color"]! as! String
        cell.plateNum.text = self.carsArray[indexPath.row]["plateNum"]! as! String

        return cell
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            self.carsArray.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 要显示自定义的action,cell必须处于编辑状态
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let carInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCarInfoVC") as! MyCarInfoVC
        carInfoVC.modalTransitionStyle = .crossDissolve
        self.present(carInfoVC, animated: true, completion: nil)
        
        carInfoVC.brandTF.text = (self.carsArray[indexPath.row]["brandName"] as! String).components(separatedBy: " ")[0]
        carInfoVC.carTypeTF.text = (self.carsArray[indexPath.row]["brandName"] as! String).components(separatedBy: " ")[1]
        carInfoVC.carPlateTF.text = self.carsArray[indexPath.row]["plateNum"] as! String
        carInfoVC.colorBtn.setTitle(self.carsArray[indexPath.row]["color"] as! String, for: .normal)
        carInfoVC.projectTypeTF.text = self.carsArray[indexPath.row]["project"] as! String
        carInfoVC.payWayBtn.setTitle(self.carsArray[indexPath.row]["payWay"] as! String, for: .normal)
        carInfoVC.cameraBtn.setBackgroundImage(self.carsArray[indexPath.row]["pic"] as! UIImage, for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "删除") { action, index in
            self.carsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        delete.backgroundColor = UIColor.clear

        return [delete]
    }


    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
