//
//  RealPlayViewController.m
//  Mcu_sdk_demo
//
//  预览视图

//  Created by apple on 16/3/29.
//  Copyright © 2016年 hikvision. All rights reserved.
//

#import "RealPlayViewController.h"
#import "Mcu_sdk/RealPlayManager.h"
#import "Mcu_sdk/VPCaptureInfo.h"
#import "Mcu_sdk/VPRecordInfo.h"
#import "QualityPanelView.h"
#import "PtzPanelView.h"
#import "PtzPopView.h"
#import "PtzPresetPositionPopView.h"
#import "PlayView.h"
#import "TalkChannelView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil] show]

static const NSInteger buttonInterval = 5;/**< 按钮间距*/

static dispatch_queue_t video_intercom_queue() {
    static dispatch_queue_t url_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url_request_queue = dispatch_queue_create("voice.intercom.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return url_request_queue;
}

@interface RealPlayViewController ()
<
RealPlayManagerDelegate,
UIScrollViewDelegate,
QualityPanelViewDelegate,
PtzPanelViewDelegate,
PtzPopViewDelegate,
PtzPresetPositionPopViewDelegate,
PlayViewDelegate,
TalkChannelDelegate
>

@property (nonatomic, assign) BOOL presetPositionState;
@property (nonatomic, strong) UIButton        *talkButton; /**< 对讲按钮*/
@property (nonatomic, strong) TalkChannelView        *talkChannelView; /**< 对讲通道视图*/

@end

@implementation RealPlayViewController {
    PlayView                    *g_playView;/**< 播放块*/
    RealPlayManager             *g_playMamager;/**<  预览管理类对象*/
    UIActivityIndicatorView     *g_activity;    /**< 加载动画*/
    UIButton                    *g_refreshButton;/**< 刷新按钮*/
    
    
    UIButton                    *g_captureButton;/**< 抓图按钮*/
    UIButton                    *g_stopButton;/**< 停止预览按钮*/
    UIButton                    *g_recordButton;/**< 录像按钮*/
    UIButton                    *g_qualityButton;/**< 码流切换按钮*/
    UIButton                    *g_audioButton;/**< 声音按钮*/
    UIButton                    *g_eleZoomButton;/**< 电子放大按钮*/
    UIButton                    *g_ptzButton;/**< 云台控制按钮*/
    
    QualityPanelView            *g_qualityPanel;/**< 码流切换工具栏*/
    PtzPanelView                *g_ptzPanel;/**< 云台控制工具栏*/
    
    VP_STREAM_TYPE              g_currentQuality;/**< 当前播放码流*/
    
    PtzPopView                  *g_ptzPopView;/**< ptz弹出框*/
    PtzPresetPositionPopView    *g_ptzPresetPositionPopView;/**< 预置点弹出框*/
    VPRecordInfo                *recordInfo;//记录一下当前的录像信息
    BOOL                        isHaveTalkResult;//当前是否有对讲回调
}

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
#warning 正在播放视频时,APP进入后台,必须停止播放.未处理当前播放状态,在APP重新变活跃时会出现崩溃,画面卡死的现象
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRealPlay) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRealPlay) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //首先初始化预览管理类对象,并设置其代理,遵循RealPlayManagerDelegate并实现其代理方法
    g_playMamager = [[RealPlayManager alloc] initWithDelegate:self];
    [g_activity startAnimating];
    
    //设置要播放视频的清晰度.0高清,1标清,2流畅.此处用户可以存储视频清晰度到本地,下次需要重新选择清晰度时,直接在本地读取和修改
    g_currentQuality = STREAM_MAG;
    
    //开始预览操作
    //需要传入三个参数.cameraSyscode是监控点的唯一标识.   g_currentQuality 是上面设置的视频清晰度  playView是用户自己指定一个用来播放视频的视图
    [g_playMamager startRealPlay:_cameraSyscode videoType:g_currentQuality playView:g_playView.playView complete:^(BOOL finish,NSString *message) {
        //finish返回YES时,代表当前操作成功.finish返回NO时,message会返回预览过程中的失败信息
        if (finish) {
            NSLog(@"调用预览成功%@", message);
#warning  刷新UI操作必须在主线程操作
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_activity stopAnimating];
            });

        } else {
            NSLog(@"调用预览失败 %@",message);
            dispatch_async(dispatch_get_main_queue(), ^{
#warning  刷新UI操作必须在主线程操作
                [g_activity stopAnimating];
                g_refreshButton.hidden = NO;
            });
            
        }
    }];
    /*[g_playManagerEx startRealPlay:@"rtsp://10.33.47.131:8890/realplay://42a392d7f42d444a849917ece59fd5e9:SUB:TCP?cnid=1&pnid=0&token=&bitrate=100&framerate=10&videotype=2&systemformat=2" playView:g_playView.playView complete:^(BOOL finish, NSString *message) {
        if (finish) {
            NSLog(@"%@",message);
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_activity stopAnimating];
            });

        }
    }];*/
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#warning 退出界面必须进行停止播放操作和停止对讲操作,防止因为播放句柄未释放而造成的崩溃
    if (g_playView.isTalking) {
        dispatch_async(video_intercom_queue(), ^{
            [g_playMamager stopTalking];
        });
    }
    [g_playMamager stopRealPlay];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    g_playView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    
    [g_activity  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.center.equalTo(g_playView);
    }];
    
    [g_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(g_activity);
        make.center.equalTo(g_playView);
    }];
    
    [g_qualityPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(g_playView.mas_bottom).with.offset(10);
        make.left.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 74));
    }];
    
    [g_ptzPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(g_playView.mas_bottom).with.offset(10);
        make.left.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 74));
    }];
    
    //按钮布局
    [g_captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10);
        make.top.equalTo(g_qualityPanel.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [g_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_stopButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.equalTo(g_captureButton);
    }];
    
    [g_ptzButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_recordButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.equalTo(g_captureButton);
    }];
    
    [g_audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_ptzButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.equalTo(g_captureButton);
    }];
    
    [g_qualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_audioButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.equalTo(g_captureButton);
    }];
    
    [g_stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_captureButton);
        make.top.equalTo(g_captureButton.mas_bottom).with.offset(10);
        make.size.equalTo(g_captureButton);
    }];
    
    [g_eleZoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_stopButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_stopButton);
        make.size.equalTo(g_captureButton);
    }];
    
    [self.talkButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_eleZoomButton.mas_right).offset(buttonInterval);
        make.top.equalTo(g_eleZoomButton);
        make.size.equalTo(g_captureButton);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - initUI
- (void)initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    g_playView = [[PlayView alloc]init];
    g_playView.delegate = self;
    [g_playView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:g_playView];
    
    g_activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    g_activity.hidesWhenStopped = YES;
    [g_playView addSubview:g_activity];
    
    g_refreshButton = [[UIButton alloc]init];
    [g_refreshButton setBackgroundColor:[UIColor whiteColor]];
    [g_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [g_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [g_refreshButton addTarget:self action:@selector(refreshRealPlay) forControlEvents:UIControlEventTouchUpInside];
    g_refreshButton.hidden = YES;
    [g_playView addSubview:g_refreshButton];
    
    //工具栏按钮
    g_captureButton = [[UIButton alloc]init];
    [g_captureButton setBackgroundColor:[UIColor blueColor]];
    [g_captureButton setTitle:@"抓图" forState:UIControlStateNormal];
    [g_captureButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_captureButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_captureButton];
    
    g_stopButton = [[UIButton alloc]init];
    [g_stopButton setBackgroundColor:[UIColor blueColor]];
    [g_stopButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [g_stopButton addTarget:self action:@selector(stopRealPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_stopButton];
    
    g_recordButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_recordButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_recordButton setTitle:@"录像" forState:UIControlStateNormal];
    [g_recordButton setBackgroundColor:[UIColor blueColor]];
    [g_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_recordButton];
    
    g_audioButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_audioButton setBackgroundColor:[UIColor blueColor]];
    [g_audioButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_audioButton setTitle:@"声音" forState:UIControlStateNormal];
    [g_audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_audioButton addTarget:self action:@selector(audio:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_audioButton];
    
    g_eleZoomButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_eleZoomButton setBackgroundColor:[UIColor blueColor]];
    [g_eleZoomButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_eleZoomButton setTitle:@"电子放大" forState:UIControlStateNormal];
    [g_eleZoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_eleZoomButton addTarget:self action:@selector(eleZoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_eleZoomButton];
    
    g_qualityButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_qualityButton setBackgroundColor:[UIColor blueColor]];
    [g_qualityButton setTitle:@"码流" forState:UIControlStateNormal];
    [g_qualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_qualityButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_qualityButton addTarget:self action:@selector(chageQuality:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_qualityButton];
    
    g_ptzButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_ptzButton setBackgroundColor:[UIColor blueColor]];
    [g_ptzButton setTitle:@"云台控制" forState:UIControlStateNormal];
    [g_ptzButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_ptzButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_ptzButton addTarget:self action:@selector(ptzController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_ptzButton];
    
    //码流切换和云台控制工具栏
    g_qualityPanel = [[QualityPanelView alloc]initWithFrame:CGRectZero];
    g_qualityPanel.alpha = 0;
    g_qualityPanel.delegate = self;
    [g_qualityPanel selectButton:1];
    [self.view addSubview:g_qualityPanel];
    
    g_ptzPanel = [[PtzPanelView alloc]initWithFrame:CGRectZero];
    g_ptzPanel.alpha = 0;
    g_ptzPanel.delegate = self;
    [self.view addSubview:g_ptzPanel];
    
    //对讲
    self.talkButton = [[UIButton alloc] init];
    [self.talkButton setBackgroundColor:[UIColor blueColor]];
    [self.talkButton setTitle:@"开启对讲" forState:UIControlStateNormal];
    [self.talkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.talkButton.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.talkButton addTarget:self action:@selector(talking:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.talkButton];
}

#pragma mark - RealPlayManagerDelegate播放库预览状态回调代理方法和语音对讲回调
/**
 播放库预览状态回调
 
 用户可通过播放库返回的不同播放状态进行自己的业务处理
 
 @param playState 当前播放状态
 @param realPlayManager 预览管理类
 */
- (void)realPlayCallBack:(PLAY_STATE)playState realManager:(RealPlayManager *)realPlayManager {
    [g_activity stopAnimating];
    switch (playState) {
        case PLAY_STATE_PLAYING: {//正在播放
            NSLog(@"playing");
            break;
        }
        case PLAY_STATE_STOPED: {//停止播放
            NSLog(@"stoped");
            g_refreshButton.hidden = NO;
            break;
        }
        case PLAY_STATE_STARTED: {//开始播放
            NSLog(@"started");
            break;
        }
        case PLAY_STATE_FAILED: {//播放失败
            NSLog(@"failed");
            g_refreshButton.hidden = NO;
            break;
        }
        case PLAY_STATE_EXCEPTION: {//播放异常
            NSLog(@"exception");
            g_refreshButton.hidden = NO;
            break;
        }
        default:
            break;
    }
}

/**
 对讲开启成功或失败的状态回调
 
 用户可根据开启对讲的状态回调进行自己的业务处理
 
 @param isFailed 开始对讲是否失败  YES:失败,  NO:成功
 */
- (void)talkingFailedCallBack:(BOOL)isFailed {
    isHaveTalkResult = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isFailed) {
            kTipAlert(@"开启对讲失败");
            NSLog(@"开启对讲失败");
            g_playView.isTalking = NO;
            [self.talkButton setBackgroundColor:[UIColor blueColor]];
        }
        else {
            kTipAlert(@"开启对讲成功");
            NSLog(@"开启对讲成功");
            g_playView.isTalking = YES;
            [self.talkButton setBackgroundColor:[UIColor redColor]];
        }
    });
}

#pragma mark ******************************demo中云台控制的操作示例**********************************************
#pragma mark --云台控制  自动巡航操作
/**
 自动巡航操作
 
 此方法是PtzPanelViewDelegate的代理方法.用户可以不关注demo中的UI实现.在使用自动巡航功能时,可以在自己工程中,直接调用开始巡航和结束巡航的方法,即可实现自动巡航操作
 
 自动巡航的实现是:  开始巡航,调用预览管理类RealPlayManager开始云台控制操作的方法
                                        - startPtzControl: withParam1:
                            结束巡航,调用预览管理类RealPlayManager结束云台控制操作的方法
                                        - stopPtzControl: withParam1:
 ptzCommond 云台命令   此处自动巡航操作的命令是 29
 param1          云台参数   此处填写云台控制速度(1 - 10) demo中选择值为5.
 */
- (void)ptzPanelViewPanAutoButtonTouchUpInside {
    if (!g_ptzPanel.isPanAutoState) {
        [g_playMamager startPtzControl:29 withParam1:5];
    } else {
        [g_playMamager stopPtzControl:29 withParam1:5];
    }
    g_ptzPanel.isPanAutoState = !g_ptzPanel.isPanAutoState;
}

#pragma mark --云台控制  手动巡航,光圈,焦距,聚焦操作
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
- (void)ptzOperationInControl:(int)ptzCommand stop:(BOOL)stop end:(BOOL)end{
    if (g_ptzPanel.isPanAutoState) {
        [g_playMamager stopPtzControl:ptzCommand withParam1:5];
        g_ptzPanel.isPanAutoState = NO;
    }
    if (end) {
        [g_playMamager stopPtzControl:ptzCommand withParam1:5];
//        [g_playManagerEx stopPtzControl:ptzCommand withParam1:5 syscode:@"42a392d7f42d444a849917ece59fd5e9" magStreamSerAddr:@"10.33.47.131" magHttpSerPort:@"6713" isCascadeFlag:NO];
    }else{
        [g_playMamager startPtzControl:ptzCommand withParam1:5];
//        [g_playManagerEx startPtzControl:ptzCommand withParam1:5 syscode:@"42a392d7f42d444a849917ece59fd5e9" magStreamSerAddr:@"10.33.47.131" magHttpSerPort:@"6713" isCascadeFlag:NO];

    }
}

#pragma mark --云台控制  预置点操作
/**
 预置点操作
 
 预置点操作的实现是:
        调用预览管理类RealPlayManager开始云台控制操作的方法
            - startPtzControl: withParam1:,
 
 预置点命令: 8 设置预置点. 9清除预置点. 39调用预置点.

 @param command 预置点命令. 命令如上所示
 @param index 预置点编号     预置点编号只支持001--256
 */
- (void)ptzPresetPositionOperation:(int)command index:(int)index {
    if (g_ptzPanel.isPanAutoState) {
        [g_playMamager stopPtzControl:29 withParam1:5];
        g_ptzPanel.isPanAutoState = NO;
    }
    [g_playMamager startPtzControl:command withParam1:index];
}

#pragma mark *********demo中停止预览,重新开始预览,抓图,录像,切换清晰度,电子放大操作的操作示例********************
#pragma mark --对预览画面进行抓图操作
/**
 对预览画面进行抓图操作
 
 抓图操作,需要先设置抓图信息,然后再开始抓图操作
 抓图操作实现:
        1.创建一个抓图信息VPCaptureInfo对象
        2.生成抓图信息 调用VideoPlayUtility类方法:
                + getCaptureInfo: toCaptureInfo:,
        3.设置 抓图信息对象 的抓图质量  VPCaptureInfo的 nPicQuality属性.1-100 越高质量越高
        4. 对播放画面进行抓图  调用预览管理类RealPlayManager方法
                - capture:,
 */
- (void)capture {
#warning 录像和截图操作不能同时进行
    //1.创建一个抓图信息VPCaptureInfo对象
    VPCaptureInfo *captureInfo = [[VPCaptureInfo alloc] init];
    
    //2.生成抓图信息
    //此处参数 camera01 是用户自定义参数,可传入监控点名称,用作在截图成功后,拼接在图片名称的前部.如:camera01_20170302202334565.jpg
    if (![VideoPlayUtility getCaptureInfo:@"camera01" toCaptureInfo:captureInfo]) {
        NSLog(@"getCaptureInfo failed");
        return;
    }
    // 3.设置抓图质量 1-100 越高质量越高
    captureInfo.nPicQuality = 80;
    //4.开始抓图
    BOOL result = [g_playMamager capture:captureInfo];
    if (result) {
        NSLog(@"截图成功，图片路径:%@",captureInfo.strCapturePath);
    } else {
        NSLog(@"截图失败");
    }
    
    //下面是对截图进行处理的操作,如果用户项目中没有这项功能需求,可不用关注.
    
    //对截图重新进行保存,方便客户能够获取到截图,根据项目需求自行操作.
    //截图统一放在document文件夹下,自定义文件夹capture里面,用户也可按照自己的项目需求建立新的文件夹
    //获取document文件夹
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //自定义新的文件夹capture
    NSString *capture = [documentPath stringByAppendingPathComponent:@"capture"];
    //如果capture文件夹不存在,先创建capture文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:capture]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:capture withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //分割原文件路径,获取文件名称
    NSString *fileName = [captureInfo.strCapturePath componentsSeparatedByString:@"/"].lastObject;
    //新的文件路径
    NSString *newPath = [capture stringByAppendingPathComponent:fileName];
    NSLog(@"newPath :%@", newPath);
    //把截图移动到自定义文件夹,方便用户获取文件,并对其进行操作
    [[NSFileManager defaultManager] moveItemAtPath:captureInfo.strCapturePath toPath:newPath error:nil];
    //删除原来文件夹, 原文件夹是以截图时日期为名称
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    //获取当前日期字符串
    NSString *dateString = [formatter stringFromDate:date];
    NSString *oldPath = [NSString stringWithFormat:@"%@/%@", documentPath, dateString];
    [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
}

#pragma mark --对预览画面进行录像操作
/**
 对预览画面进行录像操作
 
 录像操作需要先设置录像信息,再进行录像操作
 录像操作实现:
        1.创建一个录像信息VPRecordInfo类对象
        2.生成录像信息. 调用VideoPlayUtility类的方法
                + getRecordInfo:  toRecordInfo:,
        3.对预览视频进行录像操作.调用预览管理类RealPlayManager方法
                - startRecord:,
            此方法会返回一个BOOL值,YES代表开始录像成功.NO代表录像失败.
        4.开始录像成功,则可以进行结束录像操作. 调用预览管理类RealPlayManager方法
                - stopRecord;
            此方法会返回一个BOOL值,YES代表结束录像成功,NO代表结束录像失败. 结束录像成功,则进行获取录像文件操作
 */
- (void)record:(UIButton *)recordButton {
#warning 录像和截图操作不能同时进行
    if (!g_playView.isRecording) {
        [recordButton setBackgroundColor:[UIColor redColor]];
        g_playView.isRecording = YES;
        
        // 获取录像信息
        recordInfo = [[VPRecordInfo alloc]init];
        if (![VideoPlayUtility getRecordInfo:@"222_12" toRecordInfo:recordInfo]) {
            NSLog(@"获取录像信息失败");
        }
        
        //开始录像
        if (![g_playMamager startRecord:recordInfo]) {
            NSLog(@"VP_StartRecord failed");
        } else {
            NSLog(@"开启录像成功，录像路径：%@",recordInfo.strRecordPath);
        }
    } else {
        [recordButton setBackgroundColor:[UIColor blueColor]];
        g_playView.isRecording = NO;
        
        //结束录像操作
        BOOL finish = [g_playMamager stopRecord];
        if (finish) {
            NSLog(@"关闭录像成功");
        } else {
            NSLog(@"关闭录像失败");
        }
        
        //下面是对录像进行处理的操作,如果用户项目中没有这项功能需求,可不用关注.
        
        //对录像重新进行保存,方便客户能够获取到录像,根据项目需求自行操作.
        //截图统一放在document文件夹下,自定义文件夹video里面,用户也可按照自己的项目需求建立新的文件夹
        //获取document文件夹
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        //自定义新的文件夹video
        NSString *video = [documentPath stringByAppendingPathComponent:@"video"];
        //如果video文件夹不存在,先创建video文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:video]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:video withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //分割原文件路径,获取文件名称
        NSString *fileName = [recordInfo.strRecordPath componentsSeparatedByString:@"/"].lastObject;
        //新的文件路径
        NSString *newPath = [video stringByAppendingPathComponent:fileName];
        NSLog(@"newPath :%@", newPath);
        //把截图移动到自定义文件夹,方便用户获取文件,并对其进行操作
        [[NSFileManager defaultManager] moveItemAtPath:recordInfo.strRecordPath toPath:newPath error:nil];
        //删除原来文件夹, 原文件夹是以录像时日期为名称
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMdd"];
        //获取当前日期字符串
        NSString *dateString = [formatter stringFromDate:date];
        NSString *oldPath = [NSString stringWithFormat:@"%@/%@", documentPath, dateString];
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    }
}

#pragma mark --停止预览操作
/**
 对预览画面停止预览操作.
 
 停止预览实质上是退出播放库的登录状态. 当播放功能停止使用时,停止预览操作是必须的.这可以有效的避免由于播放库的内存问题导致的程序异常.
 停止预览操作实现: 调用预览管理类RealPlayManager方法
            - stopRealPlay;
 */
- (void)stopRealPlay:(UIButton *)sender {
    //停止播放前,如果在对讲,请先停止对讲,防止出现内存问题
    if ([sender.titleLabel.text  isEqualToString:@"停止"]) {
        //如果在进行对讲操作,请关闭对讲
        if (g_playView.isTalking) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.talkButton setBackgroundColor:[UIColor blueColor]];
                g_playView.isTalking = NO;
            });
            //停止对讲
            dispatch_async(video_intercom_queue(), ^{
                [g_playMamager stopTalking];
//                [g_playManagerEx stopTalking];
            });
        }

        [sender setTitle:@"开始" forState:UIControlStateNormal];
        
        //停止预览操作
        BOOL result = [g_playMamager stopRealPlay];
//        BOOL result = [g_playManagerEx stopRealPlay];
        if (result) {
            NSLog(@"停止成功");
        } else {
            NSLog(@"停止失败");
        }
    }
    else{
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        
        //开始预览操作
        [g_playMamager startRealPlay:_cameraSyscode videoType:g_currentQuality playView:g_playView.playView complete:^(BOOL finish,NSString *message) {
            if (finish) {
#warning 刷新UI必须在主线程操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"调用预览成功");
                    [g_activity stopAnimating];
                });
            } else {
#warning 刷新UI必须在主线程操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"调用预览失败 %@",message);
                    [g_activity stopAnimating];
                    g_refreshButton.hidden = NO;
                });
            }
        }];
    }
    
}

#pragma mark --重新预览
/**
 重新预览 就是重新调用开始预览的方法
 */
- (void)refreshRealPlay {
    g_activity.hidden = NO;
    [g_activity startAnimating];
    g_refreshButton.hidden = YES;
    [g_playMamager startRealPlay:_cameraSyscode videoType:STREAM_SUB playView:g_playView.playView complete:^(BOOL finish,NSString *message) {
        if (finish) {
            NSLog(@"调用预览成功");
#warning 刷新UI必须在主线程操作
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_activity stopAnimating];
            });
        } else {
            NSLog(@"调用预览失败 %@",message);
#warning 刷新UI必须在主线程操作
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_activity stopAnimating];
                g_refreshButton.hidden = NO;
            });
        }
    }];
    
}

#pragma mark --切换视频清晰度
/**
 *  切换视频清晰度
 *
 *  切换视频清晰度的实现是:
        1.先停止正在预览的视频.
        2.重新调用开始预览的方法,传入监控点syscode,新的视频清晰度,原来设置的播放视图.开始预览
 *
 *  @param qualityType 重新选择的视频清晰度
 */
- (void)qualityChange:(VP_STREAM_TYPE)qualityType {
    if (g_currentQuality == qualityType) {
        return;
    }
    g_currentQuality = qualityType;
    //如果在录像，先停止录像
    if (g_playView.isRecording) {
        g_playView.isRecording = NO;
        // 结束录像
        if (![g_playMamager stopRecord])
        {
            NSLog(@"VP_StopRecord failed");
        }
    }
    //切换码流需要先停止预览,然后再重新播放
    [g_playMamager stopRealPlay];
    [g_audioButton setBackgroundColor:[UIColor blueColor]];
    g_playView.isAudioing = NO;
    [g_activity startAnimating];
    g_refreshButton.hidden = YES;
    [g_playMamager startRealPlay:_cameraSyscode videoType:qualityType playView:g_playView.playView complete:^(BOOL finish,NSString *message) {
        if (finish) {
#warning 刷新UI必须在主线程操作
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"调用预览成功");
                [g_activity stopAnimating];
            });
        } else {
#warning 刷新UI必须在主线程操作
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"调用预览失败 %@",message);
                [g_activity stopAnimating];
                g_refreshButton.hidden = NO;
            });
        }
    }];
}

#pragma mark --声音控制
/**
 声音开关按钮
 
 如果监控设备是支持传递声音,那么就可以进行声音开关控制
 开关声音实现:
        1.开启声音.调用预览管理类RealPlayManager方法
                - openAudio,
        2.关闭声音.调用预览管理类RealPlayManager方法
                - turnoffAudio;
 */
- (void)audio:(UIButton *)audioButton {
    if (g_playView.isAudioing) {
        g_playView.isAudioing = NO;
        [audioButton setBackgroundColor:[UIColor blueColor]];
        
        //关闭声音
        BOOL finish = [g_playMamager turnoffAudio];
        if (finish) {
            NSLog(@"关闭声音成功");
        } else {
            NSLog(@"关闭声音失败");
        }
    } else {
        g_playView.isAudioing = YES;
        [audioButton setBackgroundColor:[UIColor redColor]];
        
        //开启声音
        BOOL finish = [g_playMamager openAudio];
        if (finish) {
            NSLog(@"开启声音成功");
        } else {
            NSLog(@"开启声音失败");
        }
    }
}

#pragma mark --电子放大操作
/**
 对预览画面进行放大操作
 
 此功能是对UIScrollView的缩放比例操作而实现的.用户可以将自定义播放视图在scrollview上实现
 */
- (void)eleZoom:(UIButton *)eleZoomButton {
    if (g_playView.isEleZooming) {
        [eleZoomButton setBackgroundColor:[UIColor blueColor]];
    } else {
        if (g_playView.isPtz) {
            g_playView.isPtz = NO;
            g_ptzPanel.alpha = 0;
            [g_ptzButton setBackgroundColor:[UIColor blueColor]];
        }
        if (g_playView.isChangeQuality) {
            g_playView.isChangeQuality = NO;
            g_qualityPanel.alpha = 0;
            [g_qualityButton setBackgroundColor:[UIColor blueColor]];
        }
        [eleZoomButton setBackgroundColor:[UIColor redColor]];
    }
    g_playView.isEleZooming = !g_playView.isEleZooming;
}

#pragma mark --对讲
- (void)talking:(UIButton *)sender {
    //判断是否有对讲权限
    if (!g_playMamager.deviceInfo.hasTalkAuthority) {
        NSLog(@"你无此权限");
        return;
    }
    if (g_playView.isTalking) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.talkButton setBackgroundColor:[UIColor blueColor]];
            g_playView.isTalking = NO;
        });
        //停止对讲
        dispatch_async(video_intercom_queue(), ^{
            if ([g_playMamager stopTalking]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    kTipAlert(@"关闭对讲成功");
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    kTipAlert(@"关闭对讲失败");
                });
            };
        });
    }
    else {
        [self.talkButton setBackgroundColor:[UIColor redColor]];
        //添加对讲通道选择视图
        if (!self.talkChannelView) {
            self.talkChannelView = [[TalkChannelView alloc]  initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.talkChannelView.delegate = self;
        }
        //只对模拟通道数进行处理
        self.talkChannelView.simulateCount = g_playMamager.deviceInfo.analogVoiceChannelNum;
        if (self.talkChannelView.simulateCount == 0) {
            kTipAlert(@"该设备无可支持的对讲通道");
            [self.talkButton setBackgroundColor:[UIColor blueColor]];
            return;
        }
        else if (self.talkChannelView.simulateCount == 1) {//通道为1时默认选择通道1
            NSInteger channel = 1;
            [self talkChannelChoose:channel];
            return;
        }
        else {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:self.talkChannelView];
        }
    }
}

#pragma mark --TalkChannelDelegate对讲通道视图代理
/**
 *  确认选择通道
 *
 *  @param talkChannel 通道号
 */
- (void)talkChannelChoose:(NSInteger)talkChannel {
    [self startTalkWithChannel:talkChannel];
    
}

/**
 *  取消对讲通道选择
 */
- (void)cancelTalkChannel {
    self.talkChannelView = nil;
    g_playView.isTalking = NO;
    [self.talkButton setBackgroundColor:[UIColor blueColor]];
}


#pragma mark ***********************demo中展示云台控制顶部命令操作视图的画面展示示例*************************
#pragma mark --点击焦距按钮,展示焦距按钮顶部操作视图
- (void)ptzPanelViewZoomButtonTouchUpInside {
    g_ptzPanel.isZoomState = !g_ptzPanel.isZoomState;
    g_ptzPanel.isFocusState = NO;
    g_ptzPanel.isIrisState = NO;
    g_ptzPanel.isPresetPositionState = NO;
    self.presetPositionState = g_ptzPanel.isPresetPositionState;
    //展示焦距功能操作视图
    [self showPtzPopView:g_ptzPanel.isZoomState ptzPopInterface:PtzPopZoomInterface];
    [self showPtzPresetPositionPopView:NO];
}

#pragma mark --点击聚焦按钮,展示聚焦按钮顶部操作视图
- (void)ptzPanelViewFocusButtonTouchUpInside {
    g_ptzPanel.isFocusState = !g_ptzPanel.isFocusState;
    g_ptzPanel.isZoomState = NO;
    g_ptzPanel.isIrisState = NO;
    g_ptzPanel.isPresetPositionState = NO;
    self.presetPositionState = g_ptzPanel.isPresetPositionState;
    //展示聚焦功能操作视图
    [self showPtzPopView:g_ptzPanel.isFocusState ptzPopInterface:PtzPopFocusInterface];
    [self showPtzPresetPositionPopView:NO];
}

#pragma mark --点击光圈按钮,展示光圈按钮顶部操作视图
- (void)ptzPanelViewIrisButtonTouchUpInside {
    g_ptzPanel.isIrisState = !g_ptzPanel.isIrisState;
    g_ptzPanel.isFocusState = NO;
    g_ptzPanel.isZoomState = NO;
    g_ptzPanel.isPresetPositionState = NO;
    self.presetPositionState = g_ptzPanel.isPresetPositionState;
    //展示光圈功能的操作视图
    [self showPtzPopView:g_ptzPanel.isIrisState ptzPopInterface:PtzPopIrisInterface];
    [self showPtzPresetPositionPopView:NO];
}

#pragma mark --点击预置点按钮,展示预置点按钮顶部操作视图
- (void)ptzPanelViewPresetPositionButtonTouchUpInside {
    g_ptzPanel.isPresetPositionState = !g_ptzPanel.isPresetPositionState;
    self.presetPositionState = g_ptzPanel.isPresetPositionState;
    g_ptzPanel.isFocusState = NO;
    g_ptzPanel.isZoomState = NO;
    g_ptzPanel.isIrisState = NO;
    //展示预置点功能的操作视图
    [self showPtzPresetPositionPopView:g_ptzPanel.isPresetPositionState];
    [self showPtzPopView:NO ptzPopInterface:PtzPopUndefineInterface];
}

#pragma mark ***********************************************************************************
#pragma mark --云台控制顶部操作面板的点击事件代理,用来处理demo中自定义动画
//对手动巡航 焦距 聚焦 光圈进行的UI操作  command值不同 对应不同的操作类型 根据云台操作命令,设置播放视图上的自定义播放动画状态
//此方法是处理demo中的UI交互动画,用户可不必关注.只需关注对手动巡航 焦距 聚焦 光圈进行的操控命令方法即可
- (void)ptzPopViewOperation:(int)command stop:(BOOL)stop end:(BOOL)end {
    if (g_ptzPanel.isPanAutoState) {
        [g_playMamager stopPtzControl:command withParam1:5];
        g_ptzPanel.isPanAutoState = NO;
    }
    [g_playView ptzOperation:command stop:stop end:end];
}

#pragma mark --预置点顶部操作面板的点击事件
- (void)ptzPresetPositionPopViewButtonTouchUpInside {
    NSLog(@"预置点操作按钮被点击");
}

- (void)ptzPresetPositionPopViewDialIsSpinningChanged:(BOOL)isSpinning {
    NSLog(@"预定点滑动选择中");
}


#pragma mark ****************demo中切换按钮颜色等UI交互实现实现部分*********************************
/**
 *  更换码流
 *
 *  @param qualityButton 码流按钮
 */
- (void)chageQuality:(UIButton *)qualityButton {
    if (g_playView.isChangeQuality) {
        g_playView.isChangeQuality = NO;
        g_qualityPanel.alpha = 0;
        [qualityButton setBackgroundColor:[UIColor blueColor]];
    } else {
        if (g_playView.isPtz) {
            g_ptzPanel.alpha = 0;
            g_playView.isPtz = NO;
            [g_ptzButton setBackgroundColor:[UIColor blueColor]];
        }
        if (g_playView.isEleZooming) {
            g_playView.isEleZooming = NO;
            [g_eleZoomButton setBackgroundColor:[UIColor blueColor]];
        }
        g_playView.isChangeQuality = YES;
        g_qualityPanel.alpha = 1;
        [qualityButton setBackgroundColor:[UIColor redColor]];
    }
}

/**
 *  云台控制
 *
 *  @param ptzButton 云台控制按钮
 */
- (void)ptzController:(UIButton *)ptzButton {
    if (g_playView.isPtz) {
        g_playView.isPtz = NO;
        g_ptzPanel.alpha = 0;
        [self cancelChoosePtz];
        [ptzButton setBackgroundColor:[UIColor blueColor]];
    } else {
        if (g_playView.isChangeQuality) {
            g_qualityPanel.alpha = 0;
            g_playView.isChangeQuality = NO;
            [g_qualityButton setBackgroundColor:[UIColor blueColor]];
        }
        if (g_playView.isEleZooming) {
            g_playView.isEleZooming = NO;
            [g_eleZoomButton setBackgroundColor:[UIColor blueColor]];
        }
        g_playView.isPtz = YES;
        g_ptzPanel.alpha = 1;
        [ptzButton setBackgroundColor:[UIColor redColor]];
    }
}

#pragma mark  -----程序进入后台和变为活跃时的通知实现
//程序进入后台时,停止预览操作
- (void)stopRealPlay {
    //如果在进行对讲操作,请关闭对讲
    if (g_playView.isTalking) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.talkButton setBackgroundColor:[UIColor blueColor]];
            g_playView.isTalking = NO;
        });
        //停止对讲
        dispatch_async(video_intercom_queue(), ^{
            [g_playMamager stopTalking];
        });
    }
    [g_playMamager stopRealPlay];
}

//程序变为活跃状态时,重新开始预览
- (void)resetRealPlay {
    if (self.cameraSyscode != nil) {
        [self refreshRealPlay];
    }
}

#pragma mark - private method
/**
 该方法适用于用户平台与msp进行对接
 确认对讲通道选择,开始请求对讲

 该方法主要是为了进行确认麦克风的访问权限
 
 @param channel 对讲通道
 @param indexCode 设备编号
 */
- (void)startTalkWithChannel:(NSInteger)channel{
    NSLog(@"当前对讲通道号是:%@", [NSNumber numberWithInteger:channel]);
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            //开始对讲
            dispatch_async(video_intercom_queue(), ^{
                [g_playMamager startTalkingWithChannel:channel];
            });
        }
        else {
            NSLog(@"请在设置中允许使用麦克风");
        }
    }];
}

/**
 *  显示ptzpop面板 云台控制顶部功能操作视图
 *
 *  @param show             是否显示
 *  @param ptzPopInterface  面板类型
 */
- (void)showPtzPopView:(BOOL)show ptzPopInterface:(PtzPopInterface)ptzPopInterface {
    if (show) {
        if (!g_ptzPopView) {
            g_ptzPopView = [[PtzPopView alloc] init];
            g_ptzPopView.delegate = self;
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
                g_ptzPopView.center = CGPointMake(SCREEN_WIDTH/2,g_playView.center.y + 100);
            }
        }
        [self.view addSubview:g_ptzPopView];
        g_ptzPopView.ptzPopInterface = ptzPopInterface;
    }
    else {
        [g_ptzPopView removeFromSuperview];
        g_ptzPopView = nil;
    }
}

#pragma mark --显示ptzpresetpostionpopview的面板
- (void)showPtzPresetPositionPopView:(BOOL)show {
    if (show) {
        if (!g_ptzPresetPositionPopView) {
            g_ptzPresetPositionPopView = [[PtzPresetPositionPopView alloc] init];
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
                g_ptzPresetPositionPopView.center = CGPointMake(SCREEN_WIDTH/2,g_playView.center.y + 100);
            }
            g_ptzPresetPositionPopView.delegate = self;
        }
        [self.view addSubview:g_ptzPresetPositionPopView];
    }
    else {
        [g_ptzPresetPositionPopView removeFromSuperview];
        g_ptzPresetPositionPopView = nil;
    }
}

//取消ptz的选中项
- (void)cancelChoosePtz {
    g_ptzPanel.isZoomState = NO;
    g_ptzPanel.isFocusState = NO;
    g_ptzPanel.isIrisState = NO;
    g_ptzPanel.isPresetPositionState = NO;
    if(g_ptzPanel.isPanAutoState) {
        g_ptzPanel.isPanAutoState = NO;
        [g_playMamager stopPtzControl:29 withParam1:5];
    }
    [self showPtzPopView:NO ptzPopInterface:PtzPopUndefineInterface];
    [self showPtzPresetPositionPopView:NO];
}

@end
