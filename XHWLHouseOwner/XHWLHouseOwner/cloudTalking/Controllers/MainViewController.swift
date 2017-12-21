//
//  MainViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, XHWLNetworkDelegate{
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        let vc = self.view.window?.rootViewController
        vc?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var roomNameTextField: UITextField!
    
    fileprivate var videoProfile = AgoraRtcVideoProfile.defaultProfile()
    fileprivate var encryptionType = EncryptionType.xts128
    
    @IBAction func testBtnClicked(_ sender: UIButton) {
        let roomVC = self.storyboard?.instantiateViewController(withIdentifier: "DoorGuardRoomVC") as! DoorGuardRoomVC
        roomVC.roomName = "13123375305"
        roomVC.encryptionSecret = ""
        roomVC.encryptionType = encryptionType
        roomVC.videoProfile = videoProfile
        roomVC.modalTransitionStyle = .crossDissolve
        self.present(roomVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "mainToSettings":
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.videoProfile = videoProfile
            settingsVC.delegate = self
        case "mainToRoom":
            let roomVC = segue.destination as! RoomViewController
            roomVC.roomName = (sender as! String)
            roomVC.encryptionSecret = ""
            roomVC.encryptionType = encryptionType
            roomVC.videoProfile = videoProfile
        default:
            break
        }
    }
    
    @IBAction func doRoomNameTextFieldEditing(_ sender: UITextField) {
        if let text = sender.text , !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(from: text)
            sender.text = legalString
        }
    }
    
    
    @IBAction func callServiceCenterBtnClicked(_ sender: UIButton) {
//        {'videoRoom':'400','from':'xxxx','to':'xxx'，‘type’:video}
        //推送给400客服
        let params = ["alias": "test","title":"test", "msg": "test", "pushToWebMsg": "{\"videoRoom\":\"400\",\"from\":\"xx\",\"to\":\"xx\",\"type\": \"video\"}"]
        print("@@@@@params", params["pushToWebMsg"] as! String)
        XHWLNetwork.shared.postJPushMsg(params as NSDictionary, self)
        enter(roomName: "400")
    }
    
    
    @IBAction func doJoinPressed(_ sender: UIButton) {
        //取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        
        //推送给手机号
        let params = ["alias": self.roomNameTextField.text as! String,"title":"\(userModel?.name as! String)向您发起了云对讲！", "msg": self.roomNameTextField.text as! String]
        XHWLNetwork.shared.postJPushMsg(params as NSDictionary, self)
        enter(roomName: roomNameTextField.text)
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_JPUSHMSG.rawValue:
            onPostJPushMsg(response)
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
        if response["state"] as! Bool == true{
            "推送成功".ext_debugPrintAndHint()
        }
        
    }
}


private extension MainViewController {
    func enter(roomName: String?) {
        guard let roomName = roomName , !roomName.isEmpty else {
            return
        }
        performSegue(withIdentifier: "mainToRoom", sender: roomName)
    }
}

extension MainViewController: SettingsVCDelegate {
    func settingsVC(_ settingsVC: SettingsViewController, didSelectProfile profile: AgoraRtcVideoProfile) {
        videoProfile = profile
        dismiss(animated: true, completion: nil)
    }
}



extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case roomNameTextField:     enter(roomName: textField.text)
        default: break
        }
        
        return true
    }
}
