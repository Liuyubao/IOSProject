//
//  XHWLWilddogVideoManager.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/12/20.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import AVFoundation
import WilddogVideoCall
import WilddogCore
import WilddogAuth
import WilddogVideoBase
import WilddogSync

protocol XHWLWilddogVideoManagerDelegate:NSObjectProtocol {
    // 对方接受到通话时，拒绝或同意
    func managerWithOtherResponse(_ state:Int)
}

class XHWLWilddogVideoManager:NSObject, XHWLNetworkDelegate  {
    fileprivate var remoteStream:WDGRemoteStream?    // 远程流
    fileprivate var conversation:WDGConversation?   // 通话对象
    fileprivate var usersReference:WDGSyncReference!
    var user:WDGUser? = nil
    var remoteVideoView:WDGVideoView!
    var isVideo:Bool = true // 视频对讲， false 语音对讲
    weak var delegate:XHWLWilddogVideoManagerDelegate?
    
    // 使用 token 初始化 Video Client。
    fileprivate lazy var videoClient:WDGVideoCall? = {
        let videoClient:WDGVideoCall = WDGVideoCall.sharedInstance()
        videoClient.delegate = self
        
        return videoClient
    }()
    
    
    // 创建本地视频流
    fileprivate var localStream:WDGLocalStream?
//        = {    // 本地流
//        let localStreamOption:WDGLocalStreamOptions = WDGLocalStreamOptions()
//        localStreamOption.shouldCaptureAudio = true // 音／视频采集的开关, 默认为 YES；
//        localStreamOption.shouldCaptureVideo = true // 音／视频采集的开关, 默认为 YES；
//        localStreamOption.dimension = WDGVideoDimensions.dimensions120p //设置视频的最大尺寸， 默认为 480p
//        localStreamOption.maxFPS = 10               // 设置视频的最大帧率，默认为 16 帧／秒
//        let localStream:WDGLocalStream = WDGLocalStream.init(options: localStreamOption)!
//        localStream.delegate = self // 美颜
//
//        return localStream
//    }()
    
    func createLocalStream() {
        let localStreamOption:WDGLocalStreamOptions = WDGLocalStreamOptions()
        localStreamOption.shouldCaptureAudio = true // 音／视频采集的开关, 默认为 YES；
        localStreamOption.shouldCaptureVideo = true // 音／视频采集的开关, 默认为 YES；
        localStreamOption.dimension = WDGVideoDimensions.dimensions120p //设置视频的最大尺寸， 默认为 480p
        localStreamOption.maxFPS = 10               // 设置视频的最大帧率，默认为 16 帧／秒
        let localStream:WDGLocalStream = WDGLocalStream.init(options: localStreamOption)!
        localStream.audioEnabled = true
        localStream.delegate = self // 美颜
        self.localStream = localStream
    }
    
    class var shared: XHWLWilddogVideoManager {
        struct Static {
            static let instance = XHWLWilddogVideoManager.init()
        }
        return Static.instance
    }
    
    override init() {

    }
    
    // 配置一对一视频通话
    func config() {
        WDGVideoCall.sharedInstance().delegate = self  // WDGVideoCallDelegate
    }
    
    // 预览本地视频
    func previewLocalStream(_ localVideoView:WDGVideoView) -> Bool {
        if (self.localStream != nil) {
            if self.isVideo == false {
                self.localStream?.videoEnabled = false
            } else {
                self.localStream?.videoEnabled = true
                self.localStream?.attach(localVideoView) // 播放视频流
            }
            return true
        }else {
            self.localStream?.videoEnabled = false
            return false
        }
    }
    
    // 发起通话邀请 ， 默人会挂断前一次通话, 通话接收方的 uid
    func callVideo(_ uid:String) {
        // 传递自定义信息
        let options:WDGVideoCallOptions = WDGVideoCallOptions()
        options.customData = "附加信息：你好"
        options.iceTransportPolicy = WDGIceTransportPolicy.relay
 
        self.conversation = self.videoClient?.call(withUid: uid, localStream: self.localStream!, options:options)
        self.conversation?.delegate = self // WDGConversationDelegate
        self.conversation?.statsDelegate = self // WDGConversationStatsDelegate
    }
    
    // 接收/拒绝通话请求
    func receiveVideo(_ isAgree:Bool) {
        if isAgree {
            self.conversation?.accept(with: self.localStream!)
        } else {
            self.conversation?.reject()
        }
    }
    
    // 取消呼叫或者结束通话
    func closeConversation() {
        self.conversation?.close()
//        self.conversation = nil
    }
    
    // 关闭远程流
    func closeRemoteStream(_ remoteVideoView:WDGVideoView) {
        self.conversation?.close()
        self.remoteStream?.detach(remoteVideoView)
//        self.remoteStream = nil
    }
    
    // 关闭本地流
    func closeLocalStream(_ localVideoView:WDGVideoView) {
        self.localStream?.detach(localVideoView)
        self.localStream?.close()
//        self.localStream = nil
    }
    
    // 切换前后摄像头
    func switchCamera() {
        self.localStream?.switchCamera()
    }

    
    // 显示／因此本地视频
    func toggleLocalVideo() {
        self.localStream?.videoEnabled = !(self.localStream?.videoEnabled)!
    }
    
    // 开关听筒
    func toggleSpeaker(_ isMute:Bool) {
        if isMute {
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch {
            
            }
                    
        } else {
            do {
             try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch {
            
            }
        }
        
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
//
//
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    
    // 开关声音
    func toggleAudio() {
        self.localStream?.audioEnabled = !(self.localStream?.audioEnabled)!
    }
    
    // 保存用户
    func saveUser(_ user:WDGUser) {
        self.user = user
        usersReference = WDGSync.sync().reference().child("123/user")
        usersReference.child(user.uid).setValue(true)
        usersReference.child(user.uid).onDisconnectRemoveValue()
    }
    
    // 同意访客邀请，添加
    func agreeReq() {
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        usersReference = WDGSync.sync().reference().child("\(curInfoModel?.curProject.projectCode as! String)/visitOperator")
        usersReference.child((self.conversation?.remoteUid)!).setValue("y")
        usersReference.child((self.conversation?.remoteUid)!).onDisconnectRemoveValue()
    }
    
    // 拒绝访客邀请，添加
    func rejectReq() {
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        
        usersReference = WDGSync.sync().reference().child("\(curInfoModel?.curProject.projectCode as! String)/visitOperator")
        usersReference.child((self.conversation?.remoteUid)!).setValue("n")
        usersReference.child((self.conversation?.remoteUid)!).onDisconnectRemoveValue()
    }
    
    
    
    // 显示远程视频
    func previewRemoteView() {
        self.remoteStream?.attach(self.remoteVideoView);
        
        self.remoteStream?.audioEnabled = true
        // 语音对讲
        if self.isVideo == false {
            self.remoteStream?.videoEnabled = false
            self.remoteVideoView.isHidden = true
        }
        else {
            self.remoteStream?.videoEnabled = true
            self.remoteVideoView.isHidden = false
        }
    }
    
    func openDoor(projectCode: String){
        self.usersReference = WDGSync.sync().reference().child("\(projectCode)/openDoor")
        let remoteUid = self.conversation?.remoteUid
        self.usersReference?.child((remoteUid)!).setValue(true)
        self.usersReference?.child((remoteUid)!).onDisconnectRemoveValue()
        //【调用远程开门接口】取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        var doorStrIndex = remoteUid?.substring(from: "123-door-".endIndex)
        let params = ["id":doorStrIndex,"token":userModel?.sysAccount.token as! String]
        XHWLNetwork.sharedManager().postOpenDoorByCall(params as NSDictionary, self)
        
        var ref = WDGSync.sync().reference(withPath: "\(projectCode)/openDoor/\(remoteUid)")
        ref.observe(.value, with: { (snapshot) in
            if snapshot.value == nil {
                "已为您开门".ext_debugPrintAndHint()
                ref.removeAllObservers()
            }
        }) { (error) in
        }
    }
    
    // MARK: -network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_OPENDOORBYCALL.rawValue:
//            (response["message"] as! String).ext_debugPrintAndHint()
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
}

extension XHWLWilddogVideoManager:WDGConversationStatsDelegate {
    
    /**
     * `WDGConversation` 通过调用该方法通知代理处理当前视频通话中本地视频流的统计信息。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     * @param report 包含统计信息的 `WDGLocalStreamStatsReport` 实例。
     */
    func conversation(_ conversation: WDGConversation, didUpdate report: WDGLocalStreamStatsReport) {
        
    }

    /**
     * `WDGConversation` 通过调用该方法通知代理处理当前视频通话中远程视频流的统计信息。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     * @param report 包含统计信息的 `WDGRemoteStreamStatsReport` 实例。
     */
    func conversation(_ conversation: WDGConversation, didUpdate report: WDGRemoteStreamStatsReport) {
        
    }
}

// 美颜
extension XHWLWilddogVideoManager:WDGLocalStreamDelegate {
    
//    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> Unmanaged<CVPixelBuffer> {
//
//        // 使用第三方 SDK 处理当前视频流。
//        return [BeautySDK process:pixelBuffer];
//    }
}

extension XHWLWilddogVideoManager:WDGConversationDelegate {
    
    /**
     * `WDGConversation` 通过调用该方法通知代理视频通话状态发生变化。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     * @param callStatus 表示视频通话的状态，有`Accepted`、`Rejected`、`Busy`、`Timeout` 四种。
     */
    func conversation(_ conversation: WDGConversation, didReceiveResponse callStatus: WDGCallStatus) {
        switch (callStatus) {
        case .accepted:
            print("通话被接受")
            if (self.delegate != nil)  {
                self.delegate?.managerWithOtherResponse(0)
            }
            break
        case .rejected:
            print("通话被拒绝")
            if (self.delegate != nil) {
                self.delegate?.managerWithOtherResponse(1)
            }
            break
        case .busy:
            print("正忙")
            break
        case .timeout:
            print("超时")
//            if (self.delegate != nil) {
//                self.delegate?.managerWithOtherResponse(2)
//            }
            break
        default:
            print("状态未识别")
            if (self.delegate != nil) {
                self.delegate?.managerWithOtherResponse(2)
            }
            break
        }
    }
    
    /**
     * `WDGConversation` 通过调用该方法通知代理收到对方传来的媒体流。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     * @param remoteStream `WDGRemoteStream` 实例，表示对方传来的媒体流。
     */
    func conversation(_ conversation: WDGConversation, didReceive remoteStream: WDGRemoteStream) {
        self.remoteStream = remoteStream
        self.previewRemoteView()
    }
    
    /**
     * `WDGConversation` 通过调用该方法通知代理当前视频通话发生错误而未能建立连接。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     * @param error 错误信息，描述未能建立连接的原因。
     */
    func conversation(_ conversation: WDGConversation, didFailedWithError error: Error) {
        
    }
    /**
     * `WDGConversation` 通过调用该方法通知代理当前视频通话已被关闭。
     * @param conversation 调用该方法的 `WDGConversation` 实例。
     */
    func conversationDidClosed(_ conversation: WDGConversation) {
        XHWLSoundPlayer.stop()
        print("通话已结束")
//        释放不使用的资源
//        self.conversation = nil
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        print("test-removedelegate---\(conversation)--")
        
        conversation.close()
        if localStream != nil {
            localStream?.close()
        }
        
        let curVC = UIViewController.currentViewController()
        curVC?.dismiss(animated: true, completion: nil)
        conversation.delegate = nil
    }
}

extension XHWLWilddogVideoManager: WDGVideoCallDelegate {
//    "type":2 , // 1:通讯对讲 2:访客对讲
//    "isVideo":true, //  true视频对讲， false 语音对讲
//    "role":userModel.wyAccount.wyRole.name, // 角色：安管主任、门岗、项目经理、工程、业主
//    "name":userModel.wyAccount.name // 名字

    /**
     * `WDGVideoCall` 通过调用该方法通知当前用户收到新的视频通话邀请。
     * @param videoCall 调用该方法的 `WDGVideoCall` 实例。
     * @param conversation 代表收到的视频通话的 `WDGConversation` 实例。
     * @param data 随通话邀请传递的 `NSString` 类型的数据。
     */
    func wilddogVideoCall(_ videoCall: WDGVideoCall, didReceiveCallWith conversation: WDGConversation, data: String?) {
        print("**************************\(data)")
        XHWLSoundPlayer.playSound(.caller)
//        XHWLSoundPlayer.viberate()
        self.conversation = conversation
        self.conversation?.delegate = self  // WDGConversationDelegate
        
        let dataDic = data?.dictionaryFromJSONString()
        //从沙盒中获取在前台还是后台，如果是后台就发推送
        let appBackgound = UserDefaults.standard.object(forKey: "isAPPBackground") as! Bool
        if appBackgound{
            // 1.创建通知
            let localNotification:UILocalNotification = UILocalNotification()
            // 2.设置通知的必选参数
            // 设置通知显示的内容
            localNotification.alertBody = "来自" + (dataDic!["name"] as! String) + "的通话"
            // 设置通知的发送时间,单位秒
            localNotification.fireDate = Date.init(timeIntervalSinceNow: 10)
            //解锁滑动时的事件
            localNotification.alertAction = "来自" + (dataDic!["name"] as! String) + "的通话"
            //收到通知时App icon的角标
            //                    localNotification.applicationIconBadgeNumber = 1
            //推送是带的声音提醒，设置默认的字段为UILocalNotificationDefaultSoundName
            //                    localNotification.soundName = UILocalNotificationDefaultSoundName
            // 3.发送通知( : 根据项目需要使用)
            // 方式一: 根据通知的发送时间(fireDate)发送通知
            //                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            // 方式二: 立即发送通知
            UIApplication.shared.presentLocalNotificationNow(localNotification)
        }
        
        if dataDic!["type"] as! Int == 3{
            let curVC = UIViewController.currentViewController()
            let doorVC = DoorVideoVC()
            doorVC.wilddogVideoEnum = .called
            doorVC.name = dataDic!["name"] as! String
            curVC?.present(doorVC, animated: true, completion: nil)
        }else if dataDic!["type"] as! Int == 1{
            let curVC = UIViewController.currentViewController()
            let visitorCallVC = VisitorCallVC()
            visitorCallVC.wilddogVideoEnum = .called
            visitorCallVC.name = dataDic!["name"] as! String
            curVC?.present(visitorCallVC, animated: true, completion: nil)
        }
        
    }
    
    /**
     * `WDGVideoCall` 通过调用该方法通知当前用户配置 `WDGVideoCall` 时发生 token 错误。
     * @param videoCall 调用该方法的 `WDGVideoCall` 实例。
     * @param error 代表错误信息。
     */
    func wilddogVideoCall(_ videoCall: WDGVideoCall, didFailWithTokenError error: Error?) {
        
    }
}
