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

class XHWLWilddogVideoManager:NSObject  {

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
    
//    NotificationCenter.default.addOb
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    
//    func appWillEnterForegroundNotification(_ notification:NSNotification) {
//    [[self.usersReference child:self.user.uid] setValue:@YES];
//    [[self.usersReference child:self.user.uid] onDisconnectRemoveValue];
//    }
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
            
//            if (self.delegate != nil) {
//                self.delegate?.managerWithOtherResponse(2)
//            }
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
        print("通话已结束")
        // 释放不使用的资源
//        self.conversation = nil
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            print("test-removedelegate---\(conversation)--")
//            conversation.delegate = nil
            conversation.close()
//            self.conversation = nil
        if localStream != nil {
                localStream?.close()
//                localStream = nil
            }
            
//            });
        if #available(iOS 10.0, *) {
            let vc:UIViewController = AppDelegate.shared().getCurrentVC()
            vc.dismiss(animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }

}

extension XHWLWilddogVideoManager: WDGVideoCallDelegate {

    /**
     * `WDGVideoCall` 通过调用该方法通知当前用户收到新的视频通话邀请。
     * @param videoCall 调用该方法的 `WDGVideoCall` 实例。
     * @param conversation 代表收到的视频通话的 `WDGConversation` 实例。
     * @param data 随通话邀请传递的 `NSString` 类型的数据。
     */
    func wilddogVideoCall(_ videoCall: WDGVideoCall, didReceiveCallWith conversation: WDGConversation, data: String?) {
        
        print("\(data)")
        self.conversation = conversation
        self.conversation?.delegate = self  // WDGConversationDelegate
        
        if #available(iOS 10.0, *) {
            let vc:UIViewController = AppDelegate.shared().getCurrentVC()
            let jumpVC:XHWLWiddogVideoVC = XHWLWiddogVideoVC()
            jumpVC.wilddogVideoEnum = .called
            jumpVC.name = data!
            vc.present(jumpVC, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
//        let vc:UIViewController = AppDelegate.shared().getCurrentVC()
//
//        let alertController = UIAlertController(title:"来了电话", message: nil, preferredStyle: .alert)
//
//        let action1:UIAlertAction = UIAlertAction(title: "拒绝", style: UIAlertActionStyle.cancel) { (action) in
//            self.receiveVideo(false) // 收到通话请求
//            alertController.presentedViewController?.dismiss(animated: false, completion: nil)
////            vc.presentedViewController?.dismiss(animated: false, completion: nil)
//        }
//        alertController.addAction(action1)
//
//        let action2:UIAlertAction = UIAlertAction(title: "接收", style: UIAlertActionStyle.default) { (action) in
//
//            self.receiveVideo(true) // 收到通话请求
//            alertController.presentedViewController?.dismiss(animated: false, completion: nil)
//        }
//        alertController.addAction(action2)
//
//        //显示提示框
//        vc.present(alertController, animated: true, completion: nil)
    }
    
    /**
     * `WDGVideoCall` 通过调用该方法通知当前用户配置 `WDGVideoCall` 时发生 token 错误。
     * @param videoCall 调用该方法的 `WDGVideoCall` 实例。
     * @param error 代表错误信息。
     */
    func wilddogVideoCall(_ videoCall: WDGVideoCall, didFailWithTokenError error: Error?) {
        
    }
}
