//
//  PlayBackViewController.m
//  Mcu_sdk_demo
//  回放视图

//  Created by apple on 16/4/5.
//  Copyright © 2016年 hikvision. All rights reserved.
//

#import "PlayBackViewController.h"
#import "Mcu_sdk/PlayBackManager.h"
#import "CTimeBarPanel.h"
#import "PickerView.h"
#import "Mcu_sdk/VPCaptureInfo.h"
#import "Mcu_sdk/VPRecordInfo.h"
#import "PlayView.h"
#import "Mcu_sdk/CRecordSegment.h"
#import "Masonry.h"
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

static const NSInteger buttonInterval = 5;/**< 按钮间距*/

@interface PlayBackViewController ()
<
CTimeBarDelegate,
PlayBackManagerDelegate,
PlayBackManagerDelegate,
PickerViewDelegate,
UIScrollViewDelegate
>

@property (strong, nonatomic) NSDate            *curDate;/**< 当前时间*/
@property (assign, nonatomic) TIME_STRUCT       startTime;/**< 开始时间*/
@property (nonatomic, retain) NSTimer           *refreshTimer;/**< 定时器*/
//@property (nonatomic, strong) dispatch_source_t refreshTimer;
@property (nonatomic, retain) PickerView        *pickerView;/**< 时间选择器*/
@property (nonatomic, retain) PlayBackManager   *backManager;

@end

@implementation PlayBackViewController {
    PlayView                    *g_playBackView;/**<回放视图*/
    NSDateFormatter             *g_formatter;
    CTimeBarPanel               *g_timePanel;/**< 时间进度条*/
    UIActivityIndicatorView     *g_activity;/**< 等待框*/
    UIButton                    *g_refreshButton;/**< 重新播放按钮*/
    PLAY_STATE                  g_playState;/**< 当前播放状态*/
    dispatch_queue_t            serialQueue;//串行队列
    
    UIButton                    *g_captureButton;/**< 截屏*/
    UIButton                    *g_recordButton;/**< 录像*/
    UIButton                    *g_pauseButton;/**< 暂停*/
    UIButton                    *g_audioButton;/**< 声音*/
    UIButton                    *g_eleZoomButton;/**< 电子放大*/
}

#pragma mark - UIViewController life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
#warning 正在回放视频时,APP进入后台,必须停止播放.未处理当前播放状态,在APP重新变活跃时会出现崩溃,画面卡死的现象
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlayBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayBack) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //首先初始化回放管理类对象,设置其代理,并实现其代理方法
    _backManager = [[PlayBackManager alloc]init];
    _backManager.delegate = self;
    g_formatter = [[NSDateFormatter alloc] init];
    [g_formatter setDateFormat:@"yyyy-MM-dd"];
    
    //设置查询录像时间为当前日期
    _curDate = [NSDate date];
    [self setTimeBarDate:_curDate];
    [self setCurrentTime:_curDate];
    [g_activity startAnimating];
    WS(weakSelf);
    
    //开始回放操作.
    //用户需要传入三个参数.cameraSyscode是监控点的唯一标识  playView是用户自己指定一个用来播放视频的视图, date是用来查询回放录像的日期
    [_backManager startPlayBack:_cameraSyscode playView:g_playBackView.playView date:_curDate complete:^(BOOL finish, NSString *message) {
        if (finish) {
            NSLog(@"调用回放成功 %@",message);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.pickerView = [[PickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, weakSelf.view.frame.size.width, 220) andPos:[weakSelf.backManager.cameraInfo.recordPos componentsSeparatedByString:@","]];
                weakSelf.pickerView.curDate = [NSDate date];
                weakSelf.pickerView.delegate = weakSelf;
                weakSelf.pickerView.hidden = YES;
                [weakSelf.view addSubview:weakSelf.pickerView];
                [weakSelf.refreshTimer setFireDate:[NSDate distantPast]];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"调用回放失败 %@",message);
                [weakSelf showPlayBackButton];
                weakSelf.pickerView = [[PickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, weakSelf.view.frame.size.width, 220) andPos:[weakSelf.backManager.cameraInfo.recordPos componentsSeparatedByString:@","]];
                weakSelf.pickerView.curDate = [NSDate date];
                weakSelf.pickerView.delegate = weakSelf;
                weakSelf.pickerView.hidden = YES;
                [weakSelf.view addSubview:weakSelf.pickerView];
                [weakSelf.refreshTimer setFireDate:[NSDate distantPast]];
            });
        }
    }];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    g_playBackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    
    [g_activity  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.center.equalTo(g_playBackView);
    }];
    
    [g_refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(g_activity);
        make.center.equalTo(g_playBackView);
    }];
    
    [g_captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.top.equalTo(g_timePanel.mas_bottom).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [g_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_captureButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [g_pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_recordButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [g_audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_pauseButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [g_eleZoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(g_audioButton.mas_right).with.offset(buttonInterval);
        make.top.equalTo(g_captureButton);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    [self.view layoutSubviews];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //定时器用来更新timebar上的进度条和时间
    if (!_refreshTimer) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUITime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_refreshTimer forMode:NSRunLoopCommonModes];
        [_refreshTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //退出回放界面时,要进行停止回放操作
    BOOL finish = [_backManager stopPlayBack];
    if (finish) {
        NSLog(@"停止成功");
    } else {
        NSLog(@"停止失败");
    }
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - initUI
- (void)initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    g_playBackView = [[PlayView alloc]init];
    [g_playBackView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:g_playBackView];
    
    g_timePanel = [[CTimeBarPanel alloc]initWithFrame:CGRectMake(0, 384, SCREEN_WIDTH, 74) bFullScreen:NO];
    g_timePanel.delegate = self;
    g_timePanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:g_timePanel];
    
    g_activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    g_activity.hidesWhenStopped = YES;
    [g_playBackView addSubview:g_activity];
    
    g_refreshButton = [[UIButton alloc]init];
    [g_refreshButton setBackgroundColor:[UIColor whiteColor]];
    [g_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [g_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [g_refreshButton addTarget:self action:@selector(refreshPlayBack) forControlEvents:UIControlEventTouchUpInside];
    g_refreshButton.hidden = YES;
    [g_playBackView addSubview:g_refreshButton];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, 48, 44);
    [editButton setImage:[UIImage imageNamed:@"more_image_edit_sel"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    [self.navigationItem setRightBarButtonItem:buttonItem];
    
    //工具栏
    g_captureButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_captureButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_captureButton setTitle:@"抓图" forState:UIControlStateNormal];
    [g_captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_captureButton setBackgroundColor:[UIColor blueColor]];
    [g_captureButton addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_captureButton];
    
    g_recordButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_recordButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_recordButton setTitle:@"录像" forState:UIControlStateNormal];
    [g_recordButton setBackgroundColor:[UIColor blueColor]];
    [g_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_recordButton];
    
    g_pauseButton = [[UIButton alloc]initWithFrame:CGRectZero];
    [g_pauseButton setBackgroundColor:[UIColor blueColor]];
    [g_pauseButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [g_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [g_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [g_pauseButton addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:g_pauseButton];
    
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
    
//定制需求 文城科技OEM合作开发
    
    
}

#pragma mark - PlayBackManagerDelegate播放库回放状态回调代理方法
/**
 播放库回放回调函数
 
 用户可通过播放库返回的不同播放状态进行自己的业务处理
 
 @param playState 当前播放状态
 @param playBackManager 回放管理类
 */
- (void)playBackCallBack:(PLAY_STATE)playState playBackManager:(PlayBackManager *)playBackManager {
    g_playState = playState;
    [g_activity stopAnimating];
    switch (playState) {
        case PLAY_STATE_PLAYING: {//正在播放
            [_refreshTimer setFireDate:[NSDate distantPast]];
            NSLog(@"playing");
            //此处是用来绘制demo中的进度条
            [g_timePanel drawContentBar:playBackManager.recordInfo.recSegmentList];            
            break;
        }
        case PLAY_STATE_STOPED: {//停止
            g_refreshButton.hidden = NO;
            NSLog(@"stoped");
            break;
        }
        case PLAY_STATE_STARTED: {//开始
            NSLog(@"started");
            break;
        }
        case PLAY_STATE_FAILED: {//失败
            g_refreshButton.hidden = NO;
            NSLog(@"failed");
            break;
        }
        case PLAY_STATE_PAUSE: {//暂停
            NSLog(@"pause");
            break;
        }
        case PLAY_STATE_EXCEPTION: {//异常
            //播放异常时停止回放操作,同时也会退出播放库
            [playBackManager stopPlayBack];
            g_refreshButton.hidden = NO;
            NSLog(@"exception");
            break;
        }
        default:
            break;
    }
}

#pragma mark  -----程序进入后台和变为活跃时的通知实现
- (void)stopPlayBack {
    [_backManager stopPlayBack];
}

- (void)resetPlayBack {
    if (self.cameraSyscode != nil) {
        [self refreshPlayBack];
    }
}

#pragma mark **************demo中抓图\录像\暂停\声音\电子放大等操作的示例***************************
#pragma mark --抓图操作
/**
 对回放画面进行抓图操作
 
 抓图操作,需要先设置抓图信息,然后再开始抓图操作
 抓图操作实现:
        1.创建一个抓图信息VPCaptureInfo对象
        2.生成抓图信息 调用VideoPlayUtility类方法:
                + getCaptureInfo: toCaptureInfo:,
        3.设置 抓图信息对象 的抓图质量  VPCaptureInfo的 nPicQuality属性.1-100 越高质量越高
        4. 对播放画面进行抓图  调用预览管理类PlayBackManager方法
                - capture:,

 */
- (void)capture:(UIButton *)captureButton {
    //创建抓图信息对象
    VPCaptureInfo *captureInfo = [[VPCaptureInfo alloc] init];
    
    //生成抓图信息
    if (![VideoPlayUtility getCaptureInfo:@"camera01" toCaptureInfo:captureInfo]) {
        NSLog(@"getCaptureInfo failed");
        return;
    }
    
    // 设置抓图质量 1-100 越高质量越高
    captureInfo.nPicQuality = 80;
    
    //开始抓图操作
    BOOL result = [_backManager capture:captureInfo];
    if (result) {
        NSLog(@"截图成功");
    } else {
        NSLog(@"截图失败");
    }
    
    //对抓图文件文件的操作,可参照预览视图RealPlayViewController中,对抓图文件的操作处理
}

#pragma mark --录像操作
/**
 对回放画面进行录像操作
 
 录像操作需要先设置录像信息,再进行录像操作
 录像操作实现:
        1.创建一个录像信息VPRecordInfo类对象
        2.生成录像信息. 调用VideoPlayUtility类的方法
                + getRecordInfo:  toRecordInfo:,
        3.对预览视频进行录像操作.调用预览管理类PlayBackManager方法
                - startRecord:,
            此方法会返回一个BOOL值,YES代表开始录像成功.NO代表录像失败.
        4.开始录像成功,则可以进行结束录像操作. 调用预览管理类PlayBackManager方法
                - stopRecord;
            此方法会返回一个BOOL值,YES代表结束录像成功,NO代表结束录像失败. 结束录像成功,则进行获取录像文件操作
 */
- (void)record:(UIButton *)recordButton {
    if (g_playBackView.isRecording) {
        [recordButton setBackgroundColor:[UIColor blueColor]];
        g_playBackView.isRecording = NO;
        //结束录像
        [_backManager stopRecord];
        
        //结束录像之后,对录像文件的操作处理,可参照RealPlayViewController中,对录像文件的操作示例
    } else {
        [recordButton setBackgroundColor:[UIColor redColor]];
        g_playBackView.isRecording = YES;
        
        //创建录像信息对象
        VPRecordInfo *recordInfo = [[VPRecordInfo alloc]init];
        // 生成录像信息
        if (![VideoPlayUtility getRecordInfo:@"222_12" toRecordInfo:recordInfo]) {
            NSLog(@"获取录像信息失败");
        } else {
            NSLog(@"录像路径:%@",recordInfo.strRecordPath);
        }
        //开始录像
        if (![_backManager startRecord:recordInfo]) {
            NSLog(@"VP_StartRecord failed");
        }
    }
}

#pragma mark --暂停与重新播放操作
/**
 暂停与重新回放操作
 
 对正在回放的视频,可以执行暂停播放和继续回放操作
 暂停回放实现: 
        调用回放管理类PlayBackManager方法
                - pausePlayBack, 
                返回值为YES代表暂停成功,NO代表暂停回放失败
 重新开始回放实现:
        调用回放管理类PlayBackManager方法
                - resumePlayBack,
                返回值为YES代表重新回放成功,NO代表重新回放失败
  */
- (void)pause:(UIButton *)pauseButton {
    if (g_playBackView.isPausing) {
        g_playBackView.isPausing = NO;
        [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        [pauseButton setBackgroundColor:[UIColor blueColor]];
        //重启回放
        [_backManager resumePlayBack];
    } else {
        g_playBackView.isPausing = YES;
        [pauseButton setTitle:@"开始" forState:UIControlStateNormal];
        [pauseButton setBackgroundColor:[UIColor redColor]];
        //暂停回放
        [_backManager pausePlayBack];
    }
}

#pragma mark ---声音开关操作
/**
 对回放视频进行是否开启声音的设置

 开启声音的实现:
        调用回放管理类PlayBackManager方法
                - openAudio,
                返回值YES代表开启声音成功,NO代表开启声音失败.
        调用回放管理类PlayBackManager方法
                - turnoffAudio,
                返回值YES代表关闭声音成果,NO代表关闭声音失败
 */
- (void)audio:(UIButton *)audioButton {
    if (g_playBackView.isAudioing) {
        g_playBackView.isAudioing = NO;
        [audioButton setBackgroundColor:[UIColor blueColor]];
        //关闭声音
        [_backManager turnoffAudio];
    } else {
        g_playBackView.isAudioing = YES;
        [audioButton setBackgroundColor:[UIColor redColor]];
        //开启声音
        [_backManager openAudio];
    }
}

#pragma mark --电子放大
/**
 电子放大

 对回放画面进行放大操作
 
 此功能是对UIScrollView的缩放比例操作而实现的.用户可以将自定义播放视图在scrollview上实现
 */
- (void)eleZoom:(UIButton *)eleZoomButton {
    if (g_playBackView.isEleZooming) {
        g_playBackView.isEleZooming = NO;
        [eleZoomButton setBackgroundColor:[UIColor blueColor]];
    } else {
        g_playBackView.isEleZooming = YES;
        [eleZoomButton setBackgroundColor:[UIColor redColor]];
    }
}

#pragma mark - 刷新按钮
/**
 *  重新回放
 */
- (void)refreshPlayBack {
    [g_activity startAnimating];
    [_backManager startPlayBack:_cameraSyscode playView:g_playBackView.playView date:_curDate complete:^(BOOL finish, NSString *message) {
        if (finish) {
            dispatch_async(dispatch_get_main_queue(), ^{
                g_refreshButton.hidden = YES;
            });
        }
    }];

}

//定时器用来更新timebar上的进度条和时间
- (void)updateUITime:(NSTimer *)timer {
    NSTimeInterval nTmpTime = 0;
    TIME_STRUCT curTime;
    TIME_STRUCT tmpTime = _startTime;
    tmpTime.dwHour = 00;
    tmpTime.dwMinute = 00;
    tmpTime.dwSecond = 00;
    
    if(g_playState == PLAY_STATE_PLAYING) {
        NSTimeInterval osdTime = [_backManager getOsdTime];
        if (osdTime != 0) {
            [VideoPlayUtility transformNSTimeInterval:osdTime-8*3600 toStruct:&curTime];
            [VideoPlayUtility transformStruct:tmpTime toNSTimeInterval:&nTmpTime];
            if (osdTime <= nTmpTime) {
                [g_timePanel updateTimeBarTime:&curTime];
                return;
            }
            [g_timePanel updateSlider:&curTime];
            [g_timePanel updateTimeBarTime:&curTime];
            
            _startTime.dwHour = curTime.dwHour;
            _startTime.dwMinute = curTime.dwMinute;
            _startTime.dwSecond = curTime.dwSecond;
        }
    }
}

- (void)showPicker:(UIButton *)sender {
    [_pickerView preDateAndPos];
    _pickerView.hidden = NO;
    _pickerView.datePicker.hidden = NO;
    _pickerView.posPicker.hidden = YES;
}

#pragma mark --CTimeBarDelegate

- (void)timeBarStartDraggingDelegate {
    NSLog(@"timeBarStartDraggingDelegate");
}

- (void)timeBarScrollDraggingDelegate:(TIME_STRUCT *)sTime timeBarObj:(id)timeBar {
    // 更新时间标签内容
    [g_timePanel updateTimeBarTime:sTime];
    
    //更新滑动条
    [g_timePanel updateSlider:sTime];
}

- (void)timeBarStopScrollDelegate:(TIME_STRUCT *)sTime withFlag:(NSInteger)flag
{
    if (flag == 1) {
        NSLog(@"无录像文件");
        return;
    }
    [_refreshTimer setFireDate:[NSDate distantFuture]];
    _startTime.dwHour = sTime->dwHour;
    _startTime.dwMinute = sTime->dwMinute;
    _startTime.dwSecond = sTime->dwSecond;
    [_refreshTimer setFireDate:[NSDate distantFuture]];
    g_refreshButton.hidden = YES;
    [g_activity startAnimating];

    if ([_backManager stopPlayBack]) {
        [_backManager updatePlayBackTime:_startTime complete:^(BOOL finish, NSString *message) {
            NSLog(@"%@:%@",@(finish),message);
        }];
    } 
}

//时间、介质选择框代理
- (void)pickerView:(PickerView *)picker forDate:(NSDate*)date forPos:(NSString*) pos {
    if(!serialQueue){
        serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    }

    dispatch_async(serialQueue, ^{
        if (![_backManager stopPlayBack])
        {
            NSLog(@"VP_StopPlay failed");
        }
    });
    [self setCurDate:date];
    [self setTimeBarDate:date];
    [self setCurrentTime:date];
    
    [g_timePanel cleanContentBar];
    
    g_refreshButton.hidden = YES;
    [g_activity startAnimating];
    
    [_backManager pickerStartPlayBack:date currentPos:pos cameraSyscode:_cameraSyscode complete:^(BOOL finish, NSString *message) {
        if (finish) {
            NSLog(@"调用回放成功 %@",message);
        }else {
            NSLog(@"调用回放失败 %@",message);
            dispatch_async(dispatch_get_main_queue(), ^{
                [g_activity stopAnimating];
                g_refreshButton.hidden = NO;
            });
        }
    }];
}


#pragma mark - private method
- (void)showPlayBackButton {
    [g_activity stopAnimating];
    g_refreshButton.hidden = NO;
}

- (void) setCurrentTime:(NSDate *)date {
    TIME_STRUCT startTime;
    
    if (date == nil)
    {
        return;
    }
    
    NSString *dateString= [g_formatter stringFromDate:date];
    
    NSString *strYear = [dateString substringToIndex:4];
    NSRange range = {5, 2};
    NSString *strMonth = [dateString substringWithRange:range];
    NSString *strDay = [dateString substringFromIndex:8];
    
    startTime.dwYear = [strYear intValue];
    startTime.dwMonth = [strMonth intValue];
    startTime.dwDay = [strDay intValue];
    startTime.dwHour = 00;
    startTime.dwMinute = 00;
    startTime.dwSecond = 00;
    
    _startTime = startTime;
    
}

- (void)setTimeBarDate:(NSDate*) date {
    if (date == nil) {
        return;
    }
    NSString *dateString= [g_formatter stringFromDate:date];
    [g_timePanel setTimeBarDate:dateString];
}



@end
