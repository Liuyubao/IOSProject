//
//  CloudTalkingCallVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/10/17.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class CloudTalkingCallVC: UIViewController,XHWLNetworkDelegate {
    var roomName = ""                       //房间名
    var wyAlias = ""                        //物业的id
    @IBOutlet weak var from: UILabel!       //呼叫进入的楼栋地址
    var callType = 1                        //打进来的通话类型
    
    @IBAction func rejectBtnClicked(_ sender: UIButton) {
        if callType == 2{
            let params = ["wyAlias":self.wyAlias,"yzOperator":"refuse","msg":"挂断"]
            XHWLNetwork.shared.postVisitorReply(params as NSDictionary, self)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptBtnClicked(_ sender: UIButton) {
        switch self.callType {
        case 1:
            let roomVC = self.storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
            roomVC.roomName = self.roomName
            roomVC.encryptionSecret = ""
            roomVC.encryptionType = EncryptionType.xts128
            roomVC.videoProfile = AgoraRtcVideoProfile.defaultProfile()
            roomVC.modalTransitionStyle = .crossDissolve
            self.present(roomVC, animated: true, completion: nil)
            break
        case 2:
            let roomVC = self.storyboard?.instantiateViewController(withIdentifier: "DoorGuardRoomVC") as! DoorGuardRoomVC
            roomVC.roomName = self.wyAlias
            roomVC.encryptionSecret = ""
            roomVC.encryptionType = EncryptionType.xts128
            roomVC.videoProfile = AgoraRtcVideoProfile.defaultProfile()
            roomVC.modalTransitionStyle = .crossDissolve
            self.present(roomVC, animated: true, completion: nil)
            break
        default:
            break
        }
        
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_VISITORREPLY.rawValue:
            onVisitorReply(response)
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
    func onVisitorReply(_ response:[String : AnyObject]){
        print("%%%%%%%%response",response)
        if response["state"] as! Bool == true{
            "推送成功".ext_debugPrintAndHint()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

