//
//  XHWLWiddogVideoVC.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/12/20.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit

import WilddogVideoCall
import MZTimerLabel
//import WilddogCore
//import WilddogAuth
//import WilddogVideoBase
//import WilddogSync

enum WilddogVideoEnum:Int {
    case calling   // 拨叫方
    case called    // 被叫方
    case callAudio // 语音
    case callVideo // 视频
}

class XHWLWiddogVideoVC: UIViewController {
    var localVideoView:WDGVideoView?
    var remoteVideoView:WDGVideoView?
    var manager:XHWLWilddogVideoManager!
    var uid:String = ""
    var name:String = ""
    
     // 静音
    fileprivate lazy var rejectBtn:UIButton = {
        let rejectBtn = UIButton.init(type: .custom)
        rejectBtn.setImage(UIImage(named:"cloudTalking_cancel"), for: .normal)
        rejectBtn.addTarget(self, action: #selector(onAudioClick(_:)), for: .touchUpInside)
        rejectBtn.frame = CGRect(x:0, y:0, width:73, height:94)
        rejectBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-80)
        self.view.addSubview(rejectBtn)
        
        return rejectBtn
    }()
    
    // 取消／挂断／拒绝
    fileprivate lazy var cancelBtn:UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setImage(UIImage(named:"cloudTalking_cancel"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancelClick(_:)), for: .touchUpInside)
        cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
        cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0-100, y:Screen_height-80)
        self.view.addSubview(cancelBtn)
        
        return cancelBtn
    }()
    
    // 接听/免提／切换摄像头
    fileprivate lazy var agreeBtn:UIButton = {
        let agreeBtn = UIButton.init(type: .custom)
        agreeBtn.setImage(UIImage(named:"cloudTalking_cancel"), for: .normal)
        agreeBtn.addTarget(self, action: #selector(onAgreeClick(_:)), for: .touchUpInside)
        agreeBtn.frame = CGRect(x:0, y:0, width:73, height:94)
        agreeBtn.center = CGPoint(x:self.view.bounds.size.width/2.0+100, y:Screen_height-80)
        self.view.addSubview(agreeBtn)
        
        return agreeBtn
    }()

    fileprivate lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = font_17
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    lazy fileprivate var timerLabel:MZTimerLabel = {
        
        let timerLabel:MZTimerLabel = MZTimerLabel.init(frame:CGRect(x:10, y:self.view.bounds.size.height/2.0+15, width:self.view.frame.size.width , height: 30))
        timerLabel.timerType = MZTimerLabelTypeStopWatch
        timerLabel.timeLabel.backgroundColor = UIColor.clear
        timerLabel.timeLabel.font = font_16
        timerLabel.timeLabel.textColor = UIColor.white
        timerLabel.timeLabel.textAlignment = .center;
        timerLabel.isHidden = true
        self.view.addSubview(timerLabel)
        
        return timerLabel
    }()
    
    fileprivate lazy var tipLabel:UILabel = {
        let tipLabel = UILabel()
        tipLabel.font = font_14
        tipLabel.textColor = UIColor.white
        tipLabel.textAlignment = .center
        self.view.addSubview(tipLabel)
        
        return tipLabel
    }()
    
    var wilddogVideoEnum:WilddogVideoEnum = .called { // 默认被叫
        willSet {
            switch newValue {
            case .calling: // 呼叫方，只有取消按钮
                self.localVideoView?.isHidden = false
                self.remoteVideoView?.isHidden = true
                self.localVideoView?.frame = self.view.bounds
                
                self.timerLabel.isHidden = true
                self.tipLabel.isHidden = false
                self.tipLabel.text = "正在等待对方接受通话。。。"
                self.cancelBtn.setImage(UIImage(named:"cloudTalking_cancel"), for: .normal)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-80)
                self.agreeBtn.isHidden = true
                self.rejectBtn.isHidden = true
                break
            case .called: // 被呼方， 拒接／接听按钮
                self.localVideoView?.isHidden = false
                self.remoteVideoView?.isHidden = true
                self.localVideoView?.frame = self.view.bounds
                
                self.timerLabel.isHidden = true
                self.tipLabel.isHidden = false
                self.tipLabel.text = "正在等待您的接听。。。"
                self.cancelBtn.setImage(UIImage(named:"wilddog_refuse"), for: .normal)
                self.agreeBtn.setImage(UIImage(named:"wilddog_answer"), for: .normal)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.agreeBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0-60, y:Screen_height-80)
                self.agreeBtn.center = CGPoint(x:self.view.bounds.size.width/2.0+60, y:Screen_height-80)
                self.agreeBtn.isHidden = false
                self.rejectBtn.isHidden = true
                break
            case .callAudio: // 静音／挂断／切换摄像头
                self.remoteVideoView?.isHidden = true
                self.localVideoView?.frame = self.view.bounds
                
                self.timerLabel.isHidden = false
                self.tipLabel.isHidden = true
                self.timerLabel.start()
                self.rejectBtn.setImage(UIImage(named:"wilddog_silence"), for: .normal)
                self.cancelBtn.setImage(UIImage(named:"wilddog_hangup"), for: .normal)
                self.agreeBtn.setImage(UIImage(named:"wilddog_switch"), for: .normal)
                self.rejectBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.agreeBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.rejectBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-80)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0-100, y:Screen_height-80)
                self.agreeBtn.center = CGPoint(x:self.view.bounds.size.width/2.0+100, y:Screen_height-80)
                self.agreeBtn.isHidden = false
                self.rejectBtn.isHidden = false
                break
            case .callVideo: // 挂断 ／ 免提
                
                self.remoteVideoView?.isHidden = false
                self.remoteVideoView?.frame = self.view.bounds
                self.localVideoView?.frame = CGRect(x:Screen_width/4*2.5, y:0, width:1.5*Screen_width/4, height:1.2*Screen_height/4)
                
                self.timerLabel.isHidden = false
                self.tipLabel.isHidden = true
                self.timerLabel.start()
                self.cancelBtn.setImage(UIImage(named:"wilddog_hangup"), for: .normal)
                self.agreeBtn.setImage(UIImage(named:"wilddog_handsfree"), for: .normal)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.agreeBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0-60, y:Screen_height-80)
                self.agreeBtn.center = CGPoint(x:self.view.bounds.size.width/2.0+60, y:Screen_height-80)
                self.agreeBtn.isHidden = false
                self.rejectBtn.isHidden = true
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        manager = XHWLWilddogVideoManager.shared
        manager.remoteVideoView = remoteVideoView
        manager.delegate = self
        manager.createLocalStream()
        previewLocalStream()
        manager.toggleSpeaker(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.titleLabel.text = self.name

        switch self.wilddogVideoEnum {
        case .calling:
            self.localVideoView?.frame = self.view.bounds
            callVideo()
            break
        case .called:
            self.localVideoView?.frame = self.view.bounds
            break
        case .callAudio:
            self.localVideoView?.frame = self.view.bounds
            break
        case .callVideo:
            
            UIView.animate(withDuration: 0.3, animations: {
                self.remoteVideoView?.frame = self.view.bounds
                self.localVideoView?.frame = CGRect(x:Screen_width/4*2.5, y:0, width:1.5*Screen_width/4, height:1.2*Screen_height/4)
            })
            break
        }
    }
    
    func setupView() {
        
//        self.view.backgroundColor = UIColor.clear
        
        let backImageView:UIImageView = UIImageView.init(frame: self.view.bounds)
        backImageView.image = UIImage(named:"home_bg")
        self.view.addSubview(backImageView)
        
        // 远程视频
        self.remoteVideoView = WDGVideoView.init(frame:self.view.bounds)
        self.remoteVideoView?.contentMode = UIViewContentMode.scaleAspectFill
        self.remoteVideoView?.backgroundColor = UIColor.clear
        self.view.addSubview(remoteVideoView!)
        
        // 本地视频
        self.localVideoView = WDGVideoView.init(frame:CGRect(x:Screen_width/4*2.5, y:0, width:1.5*Screen_width/4, height:1.2*Screen_height/4))
        self.localVideoView?.contentMode = UIViewContentMode.scaleAspectFill
        self.localVideoView?.backgroundColor = UIColor.clear
        self.localVideoView?.shouldMirror = true
        self.view.addSubview(localVideoView!)
        
        
        self.titleLabel.frame = CGRect(x:0, y:0, width:Screen_width-20, height:30)
        self.titleLabel.center = CGPoint(x:self.view.bounds.size.width/2.0, y:self.view.bounds.size.height/2.0)
        self.tipLabel.frame = CGRect(x:0, y:0, width:Screen_width-20, height:20)
        self.tipLabel.center = CGPoint(x:self.view.bounds.size.width/2.0, y:self.view.bounds.size.height/2.0+30)
        self.timerLabel.frame = CGRect(x:0, y:0, width:Screen_width-20, height:20)
        self.timerLabel.center = CGPoint(x:self.view.bounds.size.width/2.0, y:self.view.bounds.size.height/2.0+30)
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active // true 不锁屏
    }
    
    // 音频会话，打开近距离传感器
    func proximityMonitoring(_ enabled:Bool) {
        UIDevice.current.isProximityMonitoringEnabled = enabled // true 音频会话，打开近距离传感器 false 视频会话，关闭近距离传感器
    }
    
    func closePage() {
        manager.closeConversation()
        self.dismiss(animated: true, completion: nil)
    }
    // 静音
    func onAudioClick(_ btn:UIButton) {
//        manager.toggleAudio()
        let isMute:Bool = btn.isSelected
        manager.toggleSpeaker(isMute)
        btn.isSelected = !btn.isSelected
    }
    
    // 取消／拒绝／挂断
    func onCancelClick(_ btn:UIButton) {
        if self.wilddogVideoEnum == .calling {
             closePage()
        }
        else if self.wilddogVideoEnum == .called {
            manager.receiveVideo(false)
             closePage()
        }
        else {
            closePage()
            
            self.timerLabel.pause()
        }
    }
    
    // 接听/免提／切换摄像头
    func onAgreeClick(_ btn:UIButton) {
        
        if self.wilddogVideoEnum == .called {
            self.manager.receiveVideo(true)
            self.wilddogVideoEnum = .callVideo
            
            self.timerLabel.start()
            
            // 门口机旋转
            //                self.remoteVideoView?.frame = CGRect(x:0, y:0, width:Screen_height, height:Screen_width)
            //                self.remoteVideoView?.center = CGPoint(x:self.view.bounds.size.width/2.0, y:self.view.bounds.height/2.0)
            //                self.remoteVideoView?.transform = CGAffineTransform(rotationAngle:CGFloat.pi / 2)
        }
        else if self.wilddogVideoEnum == .callVideo {
            manager.toggleAudio()
        }
        else if self.wilddogVideoEnum == .callAudio {
            manager.switchCamera()
            self.localVideoView?.shouldMirror = !(self.localVideoView?.shouldMirror)!
        }
    }
    
    func callVideo() {
        
        print("uid :\(uid)")
        manager.callVideo(self.uid)
    }
    
    // 播放本地视频
    func previewLocalStream() {
        
        let isSuccess:Bool = manager.previewLocalStream(self.localVideoView!)
        if isSuccess == false {
            self.localVideoView?.isHidden = true
        }
    }
    
    deinit {
        manager.closeRemoteStream(self.remoteVideoView!)
        manager.closeLocalStream(self.localVideoView!)
        
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [[self.usersReference child:self.user.uid] removeValue];
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

extension XHWLWiddogVideoVC:XHWLWilddogVideoManagerDelegate {
    
    func managerWithOtherResponse(_ state:Int) {
        if state == 0 {
             self.wilddogVideoEnum = .callVideo
        } else if state == 1 {
            manager.closeConversation()
            self.dismiss(animated: true, completion: nil)
        } else if state == 2 {
            manager.closeConversation()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
