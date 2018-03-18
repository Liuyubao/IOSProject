//
//  DoorVideoVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2018/1/5.
//  Copyright © 2018年 xinghaiwulian. All rights reserved.
//

import UIKit
import WilddogVideoCall
import MZTimerLabel
import WilddogSync

class DoorVideoVC: UIViewController {
    var localVideoView:WDGVideoView?    //本地视频View
    var remoteVideoView:WDGVideoView?   //对方画面
    var manager:XHWLWilddogVideoManager!
    var uid:String = ""
    var name:String = ""
    var reference:WDGSyncReference?
    
    // 头像
    fileprivate lazy var headIcon:UIImageView = {
        let headIconIV = UIImageView.init()
        headIconIV.image = UIImage(named: "NewCloudTalking_headIcon")
        headIconIV.frame = CGRect(x:0, y:0, width:95, height:95)
        headIconIV.center = CGPoint(x: self.view.bounds.size.width/2.0, y:self.view.bounds.size.height/2.0 - 100)
        self.view.addSubview(headIconIV)
        return headIconIV
    }()
    
    // MARK: - 远程开门
    fileprivate lazy var openDoorBtn:UIButton = {
        let openDoorBtn = UIButton.init(type: .custom)
        openDoorBtn.setImage(UIImage(named:"NewCloudTalking_openDoor"), for: .normal)
        openDoorBtn.addTarget(self, action: #selector(onOpenDoorClicked(_:)), for: .touchUpInside)
        openDoorBtn.frame = CGRect(x:0, y:0, width:55, height:65)
        openDoorBtn.center = CGPoint(x: self.view.bounds.size.width*2.0/3.0, y:Screen_height-80)
        self.view.addSubview(openDoorBtn)
        return openDoorBtn
    }()
    
    // 静音
    fileprivate lazy var silenceBtn:UIButton = {
        let silenceBtn = UIButton.init(type: .custom)
        silenceBtn.setImage(UIImage(named:"NewCloudTalking_silence"), for: .normal)
        silenceBtn.addTarget(self, action: #selector(onAudioClick(_:)), for: .touchUpInside)
        silenceBtn.frame = CGRect(x:0, y:0, width:55, height:65)
        silenceBtn.center = CGPoint(x:self.view.bounds.size.width/3.0, y:Screen_height-80)
        self.view.addSubview(silenceBtn)
        
        return silenceBtn
        
    }()
    
    
    // 取消／挂断／拒绝
    fileprivate lazy var cancelBtn:UIButton = {
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setImage(UIImage(named:"NewCloudTalking_reject"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(onCancelClick(_:)), for: .touchUpInside)
        cancelBtn.frame = CGRect(x:0, y:0, width:59, height:88)
        cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-180)
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
            case .calling:  // 呼叫方，只有取消按钮
                
                self.localVideoView?.isHidden = false
                self.remoteVideoView?.isHidden = true
                self.localVideoView?.frame = self.view.bounds
                
                self.timerLabel.isHidden = true
                self.tipLabel.isHidden = false
                self.tipLabel.text = "正在等待对方接受通话。。。"
                self.cancelBtn.setImage(UIImage(named:"NewCloudTalking_rejectBtnImage"), for: .normal)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-80)
                self.agreeBtn.isHidden = true
                self.silenceBtn.isHidden = true
                break
            case .called: // 被呼方， 拒接／接听按钮
                self.headIcon.isHidden = true
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
                self.silenceBtn.isHidden = true
                break
            case .callAudio: // 静音／挂断／切换摄像头
                self.remoteVideoView?.isHidden = true
                self.localVideoView?.frame = self.view.bounds
                
                self.timerLabel.isHidden = false
                self.tipLabel.isHidden = true
                self.timerLabel.start()
                self.silenceBtn.setImage(UIImage(named:"wilddog_silence"), for: .normal)
                self.cancelBtn.setImage(UIImage(named:"wilddog_hangup"), for: .normal)
                self.agreeBtn.setImage(UIImage(named:"wilddog_switch"), for: .normal)
                self.silenceBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.cancelBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.agreeBtn.frame = CGRect(x:0, y:0, width:73, height:94)
                self.silenceBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-80)
                self.cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0-100, y:Screen_height-80)
                self.agreeBtn.center = CGPoint(x:self.view.bounds.size.width/2.0+100, y:Screen_height-80)
                self.agreeBtn.isHidden = false
                self.silenceBtn.isHidden = false
                break
            case .callVideo: // 挂断 ／ 免提
                self.headIcon.isHidden = true
                self.localVideoView?.isHidden = true
                self.remoteVideoView?.isHidden = false
                self.remoteVideoView?.frame = self.view.bounds
                self.localVideoView?.frame = CGRect(x:Screen_width/4*2.5, y:0, width:1.5*Screen_width/4, height:1.2*Screen_height/4)
                self.timerLabel.isHidden = false
                self.tipLabel.isHidden = true
                self.timerLabel.start()
                
                self.agreeBtn.isHidden = true
                self.titleLabel.text = "单元门口机"
                self.titleLabel.isHidden = false
                self.tipLabel.isHidden = true
                
//                let cancelBtn = UIButton.init(type: .custom)
                cancelBtn.setImage(UIImage(named:"NewCloudTalking_reject"), for: .normal)
                cancelBtn.frame = CGRect(x:0, y:0, width:59, height:88)
                cancelBtn.center = CGPoint(x:self.view.bounds.size.width/2.0, y:Screen_height-180)
                
                self.silenceBtn.isHidden = false
                self.openDoorBtn.isHidden = false
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
        
//        self.navigationController?.navigationBar.isHidden = true
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
        //修改静音按钮图标
        if isMute{
            silenceBtn.setImage(UIImage(named:"NewCloudTalking_silence"), for: .normal)
        }else{
            silenceBtn.setImage(UIImage(named:"NewCloudTalking_silenced"), for: .normal)
        }
        
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
    
    func onOpenDoorClicked(_ btn:UIButton){
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        manager.openDoor(projectCode: (curInfoModel?.curProject.projectCode)!)
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
}

extension DoorVideoVC:XHWLWilddogVideoManagerDelegate {
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

