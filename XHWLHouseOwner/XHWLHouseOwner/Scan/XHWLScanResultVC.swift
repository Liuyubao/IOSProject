//
//  XHWLScanResultVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/28.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLScanResultVC: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var codeInfo: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    @IBOutlet weak var resultImg: UIImageView!
    
    
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
