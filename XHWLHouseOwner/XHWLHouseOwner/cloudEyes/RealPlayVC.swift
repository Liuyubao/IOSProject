//
//  RealPlayVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/6.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

typealias ImageClosureType = (UIImage) -> Void   //定义闭包类型（特定的函数类型函数类型）

class RealPlayVC: UIViewController,RealPlayManagerDelegate, PlayViewDelegate {
    @IBOutlet weak var containPlayView: UIView!
    var playView: PlayView!
    var cameraSyscode:String!                   /**< 监控点syscode*/
    var backClosure:ImageClosureType?           //接收上个页面穿过来的闭包块
    
    var isLogin:Bool!{
        didSet{
            if isLogin{
                realPlay(cameraSyscode: cameraSyscode)
            }
        }
    }
    
    var g_playManager:RealPlayManager!             /**<  预览管理类对象*/
    var g_activity:UIActivityIndicatorView!         /**< 加载动画*/
//    UIButton                    *g_refreshButton;/**< 刷新按钮*/
//    UIButton                    *g_captureButton;/**< 抓图按钮*/
    
    @IBOutlet weak var g_stopButton: UIButton!      /**< 停止预览按钮*/
//    UIButton                    *g_recordButton;/**< 录像按钮*/
//    UIButton                    *g_qualityButton;/**< 码流切换按钮*/
    @IBOutlet weak var g_audioBtn: UIButton!        /**< 声音按钮*/
//    UIButton                    *g_eleZoomButton;/**< 电子放大按钮*/
//    UIButton                    *g_ptzButton;/**< 云台控制按钮*/
    
//    QualityPanelView            *g_qualityPanel;/**< 码流切换工具栏*/
//    PtzPanelView                *g_ptzPanel;/**< 云台控制工具栏*/
    
    var g_currentQuality:VP_STREAM_TYPE!         /**< 当前播放码流*/
    
//    PtzPopView                  *g_ptzPopView;/**< ptz弹出框*/
//    PtzPresetPositionPopView    *g_ptzPresetPositionPopView;/**< 预置点弹出框*/
//    VPRecordInfo                *recordInfo;//记录一下当前的录像信息
//    BOOL                        isHaveTalkResult;//当前是否有对讲回调
    
    @IBAction func returnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        #warning 正在播放视频时,APP进入后台,必须var止播放.未处理当前播放状态,在APP重新变活跃时会出现崩溃,画面卡死的现象
//        NotificationCenter.default.addObserver(self, selector: #selector(stopRealPlay), name: UIApplicationDidEnterBackgroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(resetRealPlay), name: UIApplicationDidBecomeActiveNotification, object: nil)
        loginButtonClicked()
        
//        cameraSyscode = "99dd872e77d944ca94454fe277c93af9"
        
        //初始化playView
        playView = PlayView()
        playView?.backgroundColor = UIColor.black
        playView?.frame = self.containPlayView.bounds
        playView?.delegate = self
        self.containPlayView.addSubview(playView)
        
        g_activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        g_activity?.hidesWhenStopped = true
        playView?.addSubview(g_activity!)//为playView添加 预览管理对象
        g_activity.center = (g_activity.superview?.center)!
            
        
        //首先初始化预览管理类对象,并设置其代理,遵循RealPlayManagerDelegate并实现其代理方法
        g_playManager = RealPlayManager.init(delegate: self)
        g_activity.startAnimating()
        
        //设置要播放视频的清晰度.0高清,1标清,2流畅.此处用户可以存储视频清晰度到本地,下次需要重新选择清晰度时,直接在本地读取和修改
        g_currentQuality = STREAM_SUB
        
        playView.isPausing = true
        
//        //开始预览操作
//        realPlay(cameraSyscode: "426b767f78744939a5d8ea02d8e880dc")
        
        

    }
    
    func realPlay(cameraSyscode:String) {
        self.cameraSyscode = cameraSyscode
        
        
        g_activity?.startAnimating()
        //开始预览操作
        //需要传入三个参数.cameraSyscode是监控点的唯一标识.   g_currentQuality 是上面设置的视频清晰度  playView是用户自己指定一个用来播放视频的视图
        g_playManager?.startRealPlay(cameraSyscode, videoType: g_currentQuality!, play: playView?.playView , complete: { (finish, message) in
            //finish返回YES时,代表当前操作成功.finish返回NO时,message会返回预览过程中的失败信息
            if (finish) {
                self.playView.isPausing = false
                print("调用预览成功\(message)")
                //        #warning  刷新UI操作必须在主线程操作
                
                DispatchQueue.main.async {
                    self.g_activity?.stopAnimating()
                }
                
            } else {
                print("调用预览失败\(message)")
                
                DispatchQueue.main.async {
                    //                    #warning  刷新UI操作必须在主线程操作
                    self.g_activity?.stopAnimating()
                }
            }
        })
        
        
    }
    
    /**
     重新预览 就是重新调用开始预览的方法
     */
    func refreshRealPlay() {
        
        g_activity?.isHidden = false
        g_activity?.startAnimating()
        g_playManager?.startRealPlay("99dd872e77d944ca94454fe277c93af9", videoType: STREAM_SUB, play: playView?.playView, complete: { (finish, message) in
            if (finish) {
                //                NSLog(@"调用预览成功");
                //                #warning 刷新UI必须在主线程操作
                DispatchQueue.main.async {
                    self.g_activity?.stopAnimating()
                }
            } else {
                //                NSLog(@"调用预览失败 %@",message);
                //                #warning 刷新UI必须在主线程操作
                DispatchQueue.main.async {
                    self.g_activity?.stopAnimating()
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //#warning 退出界面必须进行停止播放操作和停止对讲操作,防止因为播放句柄未释放而造成的崩溃
        if !playView.isPausing{
            //将最后的截图保存到前面的画面当中
            //1.创建一个抓图信息VPCaptureInfo对象
            var captureInfo:VPCaptureInfo = VPCaptureInfo.init()
            
            //2.生成抓图信息
            //此处参数 camera01 是用户自定义参数,可传入监控点名称,用作在截图成功后,拼接在图片名称的前部.如:camera01_20170302202334565.jpg
            if !VideoPlayUtility.getCaptureInfo("camera01", to:captureInfo){
                NSLog("getCaptureInfo failed!")
                return
            }
            
            // 3.设置抓图质量 1-100 越高质量越高
            captureInfo.nPicQuality = 80
            //4.开始抓图
            let result = g_playManager.capture(captureInfo)
            if result{
                NSLog("截图成功，图片路径:%@",captureInfo.strCapturePath)
            }else{
                NSLog("截图失败");
            }
            
            let savedImg = UIImage.init(contentsOfFile: captureInfo.strCapturePath)
            self.backClosure!(savedImg!)
        }
        
        g_playManager.stopRealPlay()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playView?.frame = self.containPlayView.bounds
        g_activity.center = (g_activity.superview?.center)!
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    #pragma mark - RealPlayManagerDelegate播放库预览状态回调代理方法和语音对讲回调
    /**
     播放库预览状态回调
     
     用户可通过播放库返回的不同播放状态进行自己的业务处理
     
     @param playState 当前播放状态
     @param realPlayManager 预览管理类
     */
    func realPlayCallBack(_ playState: PLAY_STATE, realManager realPlayManager: RealPlayManager!) {
        g_activity.stopAnimating()
        switch playState {
        case PLAY_STATE_PLAYING://正在播放
            NSLog("playing")
            break
            
        case PLAY_STATE_STOPED: //停止播放
            NSLog("stoped")
            break
            
        case PLAY_STATE_STARTED: //开始播放
            NSLog("started")
            break
        
        case PLAY_STATE_FAILED: //播放失败
            NSLog("failed")
            break
        
        case PLAY_STATE_EXCEPTION: //播放异常
            NSLog("exception")
            break
        
        default:
            break

        }
    }
    
    //#pragma mark --停止预览操作
    /**
     对预览画面停止预览操作.
     
     停止预览实质上是退出播放库的登录状态. 当播放功能停止使用时,停止预览操作是必须的.这可以有效的避免由于播放库的内存问题导致的程序异常.
     停止预览操作实现: 调用预览管理类RealPlayManager方法
     - stopRealPlay;
     */
    @IBAction func g_stopBtnClicked(_ sender: UIButton) {
        //停止播放前,如果在对讲,请先停止对讲,防止出现内存问题
        if sender.titleLabel?.text == "停止"{
            sender.setTitle("开始", for: .normal)//设置为开始
            //停止预览操作
            let result = g_playManager.stopRealPlay()
            if result {
                self.playView.isPausing = true
                NSLog("停止成功")
            } else {
                NSLog("停止失败")
            }
        }else{
            sender.setTitle("停止", for: .normal)
            //开始预览操作
            g_playManager.startRealPlay(cameraSyscode, videoType: g_currentQuality, play: playView, complete: { (finish, message) in
                if finish{
                    DispatchQueue.main.async {
                        NSLog("调用预览成功");
                        self.playView.isPausing = false
                        self.g_activity.stopAnimating()
                    }
                }else{
                    DispatchQueue.main.async {
                        NSLog("调用预览失败\(message)")
                        self.g_activity.stopAnimating()
                    }
                }
            })
            
        }
        

    }
    
    
    //抓图操作
    @IBAction func captureBtnClicked(_ sender: UIButton) {
        //如果此时暂停状态，不允许截图
        if playView.isPausing{
            return
        }
        //1.创建一个抓图信息VPCaptureInfo对象
        let captureInfo:VPCaptureInfo = VPCaptureInfo.init()
        
        //2.生成抓图信息
        //此处参数 camera01 是用户自定义参数,可传入监控点名称,用作在截图成功后,拼接在图片名称的前部.如:camera01_20170302202334565.jpg
        if !VideoPlayUtility.getCaptureInfo("camera01", to:captureInfo){
            NSLog("getCaptureInfo failed!")
            return
        }
        
        // 3.设置抓图质量 1-100 越高质量越高
        captureInfo.nPicQuality = 80
        //4.开始抓图
        let result = g_playManager.capture(captureInfo)
        if result{
            NSLog("截图成功，图片路径:%@",captureInfo.strCapturePath)
        }else{
            NSLog("截图失败");
        }
        
        let savedImg = UIImage.init(contentsOfFile: captureInfo.strCapturePath)

//        g_audioBtn.setBackgroundImage(savedImg, for: .normal)
        UIImageWriteToSavedPhotosAlbum(savedImg!, nil, nil, nil)
//        self.backClosure!(savedImg!)
        
        

    }
    
    //#pragma mark --声音控制
    /**
     声音开关按钮
     
     如果监控设备是支持传递声音,那么就可以进行声音开关控制
     开关声音实现:
     1.开启声音.调用预览管理类RealPlayManager方法
     - openAudio,
     2.关闭声音.调用预览管理类RealPlayManager方法
     - turnoffAudio;
     */
    @IBAction func audioBtnClicked(_ sender: UIButton) {
        if playView.isAudioing{
            playView.isAudioing = false
            
            //关闭声音
            let finish = g_playManager.turnoffAudio()
            if finish {
                sender.setTitle("开声音", for: .normal)
                NSLog("关闭声音成功")
            } else {
                NSLog("关闭声音失败")
            }
        }else{
            playView.isAudioing = true
            
            //开启声音
            let finish = g_playManager.openAudio()
            if finish {
                sender.setTitle("关声音", for: .normal)
                NSLog("开启声音成功")
            } else {
                NSLog("开启声音失败")
            }
        }
        
    }
    
    
    
    
    //    #pragma mark ---点击登录按钮
    /**
     *  点击登录按钮
     */
    func loginButtonClicked() {
        
        let password:String = MSP_PASSWORD.md5
        
        //调用 登录平台接口,完成登录操作
        //注意:登录密码必须是经过MD5加密的
        MCUVmsNetSDK.shareInstance().loginMsp(withUsername: MSP_USERNAME, password: password, success: { (responseDic) in
            
            let obj:NSDictionary = responseDic as! NSDictionary
            let status:String = obj["status"] as! String
            
            if (status.compare("200").rawValue == 0) {
                ////                [SVProgressHUD dismiss];
                
                self.isLogin = true
            } else {
                print("登陆失败2")
                //                //返回码为200,代表登录成功.返回码为202,203,204时,分别代表的意思是初始密码登录,密码强度不符合要求,密码过期.这三种情况都需要修改密码.请开发者使用当前账号登录BS端平台,按要求进行密码修改后,再进行APP的开发测试工作.其他返回码,请根据平台返回提示信息进行提示或处理
                ////                [SVProgressHUD showErrorWithStatus:responseDic[@"description"]];
            }
        }) { (error) in
            
            print("登陆失败3")
            //            [SVProgressHUD showErrorWithStatus:@"服务器连接失败"];
        }
    }
    
//    #pragma mark --云台控制  手动巡航,光圈,焦距,聚焦操作
    /**
     手动巡航,光圈,焦距,聚焦操作
     
     手动巡航命令:  21 上, 22下, 23,左, 24右, 25左上, 26右上, 27左下, 28 右下
     焦距命令: 11 焦距增大, 12焦距减小
     聚焦命令: 13聚焦增大, 14聚焦减小
     光圈命令: 15光圈增大, 16光圈减小
     
     手动巡航,光圈,焦距,聚焦操作的实现是:
     开始巡航,调用预览管理类RealPlayManager开始云台控制操作的方法
     - startPtzControl: withParam1:,
     结束巡航,调用预览管理类RealPlayManager结束云台控制操作的方法
     - stopPtzControl: withParam1:,
     ptzCommond 云台命令   此处填写的云台命令在上面已仔细说明
     param1          云台参数   此处填写云台控制速度(1 - 10) demo中选择值为5.
     
     @param ptzCommand 云台命令
     @param stop demo云台动画中传递过来的参数
     @param end demo云台动画中传递过来的参数
     */

    func ptzOperation(inControl ptzCommand: Int32, stop: Bool, end: Bool) {
//        if end{
//            g_playManager.stopPtzControl(Int(ptzCommand), withParam1: 5)
//        }else{
//            g_playManager.startPtzControl(Int(ptzCommand), withParam1: 5)
//        }
    }
    
    
    //闭包变量的Seter方法
    func setBackMyClosure(tempClosure:@escaping ImageClosureType) {
        self.backClosure = tempClosure
    }


}
