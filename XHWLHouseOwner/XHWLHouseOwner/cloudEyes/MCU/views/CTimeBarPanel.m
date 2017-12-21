//
//  CTimeBarPanel.m
//  iVMSTest
//
//  Created by hikvision on 12-12-27.
//  Copyright (c) 2012年 hikvision. All rights reserved.
//

#import "CTimeBarPanel.h"
#import "Mcu_sdk/CRecordSegment.h"
#import "Mcu_sdk/VideoPlayUtility.h"

static int counter = 0;

@interface CTimeBarPanel(Pri)
- (void)createScrollBarView;
- (void)scrollDraggingHandle:(UIScrollView *)scrollView;
- (NSString *)genString:(int)i;
@end

@implementation CTimeBarPanel
@synthesize delegate = _delegate;
@synthesize bFullScreen = _bFullScreen;

- (id)initWithFrame:(CGRect)frame bFullScreen:(BOOL)bFullScreen
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _bFullScreen = bFullScreen;
        
        // Background
        UIImage *bgimg = nil;
        [self setBackgroundColor:[UIColor clearColor]];
        if (_bFullScreen) {
            bgimg = [UIImage imageNamed:@"playback_fullscreen_playbar.png"];
        }
        else {
            bgimg = [UIImage imageNamed:@"playback_playbar_bg.png"];
        }
        
        if (_bgImgView == nil) {
            _bgImgView = [[UIImageView alloc] initWithImage:bgimg];
            [_bgImgView setFrame:CGRectMake(0,
                                            0,
                                            self.frame.size.width,
                                            self.frame.size.height)];
        }
        [self addSubview:_bgImgView];
        
        // 日期
        if (_dateLab == nil) {
            _dateLab = [[UILabel alloc] initWithFrame:FRAME_DATELAB];
            [_dateLab setBackgroundColor:[UIColor clearColor]];
            [_dateLab setTextColor:[UIColor whiteColor]];
            [_dateLab setFont:[UIFont boldSystemFontOfSize:14]];
            _dateLab.textAlignment = NSTextAlignmentRight;
            _dateLab.numberOfLines = 1;
            [self addSubview:_dateLab];
        }
        
        // 时间
        if (_timeLab == nil) {
            _timeLab = [[UILabel alloc] initWithFrame:FRAME_TIMELAB];
            [_timeLab setBackgroundColor:[UIColor clearColor]];
            [_timeLab setTextColor:[UIColor whiteColor]];
            [_timeLab setFont:[UIFont boldSystemFontOfSize:14]];
            _timeLab.textAlignment = NSTextAlignmentLeft;
            _timeLab.numberOfLines = 1;
            [self addSubview:_timeLab];
        }
        
        // 创建滑动播放视图组
        if (_scrollView == nil) {
            _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                         0, 
                                                                         self.frame.size.width,
                                                                         self.frame.size.height)];
            if (_bFullScreen) {
                CALayer *layer = _scrollView.layer;
                layer.cornerRadius = 30;
                [layer setMasksToBounds:YES];
            }
            [_scrollView setBackgroundColor:[UIColor clearColor]];
            _scrollView.contentSize = SIZE_SCROLLCONTENT;
            _scrollView.userInteractionEnabled = YES;
            _scrollView.multipleTouchEnabled = YES;
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.bounces = NO;
            _scrollView.delegate = self;
            [self createScrollBarView];
            [self addSubview:_scrollView];
        }
        
        // 黄线
        if (_sliderImgView == nil) {
            UIImage *img = nil;
            if (_bFullScreen) {
                img = [UIImage imageNamed:@"playback_fullscreen_playbarline.png"];
                _sliderImgView = [[UIImageView alloc] initWithImage:img];
                [_sliderImgView setFrame:CGRectMake(self.frame.size.width/2, 
                                                    10,
                                                    _sliderImgView.frame.size.width/2,
                                                    _sliderImgView.frame.size.height/2)];
            }
            else {
                img = [UIImage imageNamed:@"playback_playbar_line.png"];
                _sliderImgView = [[UIImageView alloc] initWithImage:img];
                [_sliderImgView setFrame:CGRectMake(self.frame.size.width/2, 
                                                    0,
                                                    _sliderImgView.frame.size.width/2,
                                                    self.frame.size.height)];
            }
            [self addSubview:_sliderImgView];
        }
        
        // Init
        if (_recViewArray == nil) {
            _recViewArray = [[NSMutableArray alloc] initWithCapacity:1];
        }
    }
    return self;
}


#pragma mark - create view

/** @fn	createScrollBarView
 *  @brief  创建滑动条视图
 *  @param  
 *  @return 无
 */
- (void)createScrollBarView {
    float dateY = 0;
    if (_bFullScreen)  {
        dateY = 28;
    }
    else {
        dateY = 32;
    }
    // 填写24小时时间点
    for (int i = 0; i < 25; i++) {
        UILabel *dateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, dateY, 30, 10)];
        [dateLab setBackgroundColor:[UIColor clearColor]];
        [dateLab setTextColor:[UIColor redColor]];
        [dateLab setFont:[UIFont systemFontOfSize:9]];
        dateLab.textAlignment = NSTextAlignmentCenter;
        dateLab.numberOfLines = 1;
        
        NSString *date = [NSString stringWithFormat:@"%@:00", [self genString:i]];
        dateLab.text = date;
        CGPoint dateCentPoint = CGPointMake(i * self.frame.size.width / HOURS_PERPAGE + self.frame.size.width/2, dateY);
        dateLab.center = dateCentPoint;
        [_scrollView addSubview:dateLab];
    }
    
    // 添加录像片段绘制的父View
    if (_bFullScreen)  {
        _drawView = [[UIView alloc] initWithFrame:FRAME_FS_DRAWVIEW];
    }
    else  {
        _drawView = [[UIView alloc] initWithFrame:FRAME_DRAWVIEW];
    }
    [_drawView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:_drawView];
}

#pragma mark - delegate method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_recViewArray count] <= 0)  {
        return;
    }
    if (_delegate)  {
        [_delegate timeBarStartDraggingDelegate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    counter++;
    if (scrollView.dragging /*&& counter % 4 == 0*/)  {
        [self scrollDraggingHandle:scrollView];
        /*
        [self performSelectorOnMainThread:@selector(scrollDraggingHandle:) 
                               withObject:scrollView 
                            waitUntilDone:YES];
         */
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_recViewArray count] <= 0)  {
        return;
    }
    if (!scrollView.dragging && _delegate)  {
        [self scrollDraggingHandle:scrollView];
        
        if(_maxTime.dwHour < _curTime.dwHour) {
            NSTimeInterval temTime =0;
            [VideoPlayUtility transformStruct:_maxTime toNSTimeInterval:&temTime];
            [VideoPlayUtility transformNSTimeInterval:temTime - 10 - 8*3600 toStruct:&_tmpTime];
            _curTime = _tmpTime;
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:1];
        }
        else if((_maxTime.dwHour == _curTime.dwHour)
                &&(_maxTime.dwMinute < _curTime.dwMinute))  {
            NSTimeInterval temTime =0;
            [VideoPlayUtility transformStruct:_maxTime toNSTimeInterval:&temTime];
            [VideoPlayUtility transformNSTimeInterval:temTime - 10 - 8*3600 toStruct:&_tmpTime];
            _curTime = _tmpTime;
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:1];
        }
        else  {
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:0];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_recViewArray count] <= 0)  {
        return;
    }
    if (!scrollView.decelerating && _delegate)  {
        [self scrollDraggingHandle:scrollView];
        if(_maxTime.dwHour < _curTime.dwHour) {
            NSTimeInterval temTime =0;
            [VideoPlayUtility transformStruct:_maxTime toNSTimeInterval:&temTime];
            [VideoPlayUtility transformNSTimeInterval:temTime - 10 - 8*3600 toStruct:&_tmpTime];
            _curTime = _tmpTime;
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:1];
        }
        else if ((_maxTime.dwHour == _curTime.dwHour)
                &&(_maxTime.dwMinute < _curTime.dwMinute))  {
            NSTimeInterval temTime =0;
            [VideoPlayUtility transformStruct:_maxTime toNSTimeInterval:&temTime];
            [VideoPlayUtility transformNSTimeInterval:temTime - 10 - 8*3600 toStruct:&_tmpTime];
            _curTime = _tmpTime;
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:1];
        }
        else  {
            [_delegate timeBarStopScrollDelegate:&_curTime withFlag:0];
        }
    }
}

/** @fn	scrollDraggingHandle
 *  @brief  scroll停止滚动处理
 *  @param  scrollView - 滑动View对象
 *  @return 无
 */
- (void)scrollDraggingHandle:(UIScrollView *)scrollView {
//    memset(&_curTime, 0, sizeof(TIME_STRUCT));
    CGPoint curPoint = [scrollView contentOffset];
    if ((int)curPoint.x < 0) {
        [_timeLab setText:[NSString stringWithFormat:@"00:00:00"]];
    }
    else if ((int)curPoint.x > self.frame.size.width * 24 / HOURS_PERPAGE) {
        _curTime.dwHour = 24;
        [_timeLab setText:[NSString stringWithFormat:@"24:00:00"]];
    }
    else  {
        float secPerPix = (float)HOURS_PERPAGE*3600/self.frame.size.width;
        long secs = curPoint.x * secPerPix;  // 67.5 = HOURS_PERPAGE*3600/WIDTH_SCREEN
        _curTime.dwHour = (unsigned int)secs/3600;
        _curTime.dwMinute = secs%3600/60;
        _curTime.dwSecond = secs%60;
    }
    
    if ( _curTime.dwHour > 24)
    {
        _curTime.dwHour = 0;
    }
    if (_curTime.dwMinute > 60)
    {
        _curTime.dwMinute = 0;
    }
    if (_curTime.dwHour > 60)
    {
        _curTime.dwSecond = 0;
    }
    
    if (_delegate)
    {
        [_delegate timeBarScrollDraggingDelegate:&_curTime timeBarObj:self];
    }
}

#pragma mark - public method
/** @fn	setDate
 *  @brief  设置当前日期
 *  @param  sDate - 当前日期字符串
 *  @return 无
 */
- (void)setTimeBarDate:(NSString *)sDate
{
    // 设置时间条日期
    if (sDate)
    {
        _dateLab.text = sDate;
    }
    else
    {
        _dateLab.text = @"";
    }
    _timeLab.text = @"00:00:00";
    
    // 设置滚动条位置
    if (_scrollView)
    {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    // 保存当前日期
    NSString *sYear = [sDate substringToIndex:4];
    NSRange range = {5, 2};
    NSString *sMonth = [sDate substringWithRange:range];
    NSString *sDay = [sDate substringFromIndex:8];
    _curTime.dwYear = [sYear intValue];
    _curTime.dwMonth = [sMonth intValue];
    _curTime.dwDay = [sDay intValue];
}

/** @fn	drawContentBar
 *  @brief  绘制进度条
 *  @param  recorderArray - 录像文件数组
 *  @return 无
 */
- (BOOL)drawContentBar:(NSMutableArray *)recorderArray
{
    // 首先清空原录像视图View, 无论本次是否为空
    if ([_recViewArray count] > 0)
    {
        for (UIView *recView in _recViewArray)
        {
            [recView removeFromSuperview];
        }
        [_recViewArray removeAllObjects];
    }
    
    if (recorderArray == nil)
    {
        NSLog(@"array is nil");
        return NO;
    }
    NSInteger iRecorderCounter = [recorderArray count];
    
    if (iRecorderCounter == 0)
    {
        // 无录像提示
        NSLog(@"recorderArray count is 0");
        return NO;
    }
    [self drawViewNormalDevice:recorderArray];
    return YES;
}



- (void)drawViewNormalDevice:(NSMutableArray *)recorderArray {
    NSInteger iRecorderCounter = [recorderArray count];
    
    if (iRecorderCounter == 0)
    {
        // 无录像提示
        NSLog(@"recorderArray count is 0");
        return;
    }
    // 取出每段录像起始时间及结束时间并生成相应录像条视图
    for (CRecordSegment *recordSegment in recorderArray)
    {
        // 取出日期，然后得出秒数，算出长度，绘制视图
        UIView *recordView;
        
        // 处理如果录像文件开始时间早于00：00则将结束时间设为00：00
        if (recordSegment.beginTime.dwYear < _curTime.dwYear ||
            recordSegment.beginTime.dwMonth < _curTime.dwMonth ||
            recordSegment.beginTime.dwDay < _curTime.dwDay)
        {
            TIME_STRUCT time;
            memset(&time, 0, sizeof(TIME_STRUCT));
            time.dwYear    = _curTime.dwYear;
            time.dwMonth   = _curTime.dwMonth;
            time.dwDay     = _curTime.dwDay;
            time.dwHour    = 0;
            time.dwMinute  = 0;
            time.dwSecond  = 0;
            [recordSegment setBeginTime:time];
        }
        
        // 处理如果录像文件结束时间超过24：00则将结束时间设为24：00
        if (recordSegment.endTime.dwYear > _curTime.dwYear ||
            recordSegment.endTime.dwMonth > _curTime.dwMonth ||
            recordSegment.endTime.dwDay > _curTime.dwDay)
        {
            TIME_STRUCT time;
            memset(&time, 0, sizeof(TIME_STRUCT));
            time.dwYear    = _curTime.dwYear;
            time.dwMonth   = _curTime.dwMonth;
            time.dwDay     = _curTime.dwDay;
            time.dwHour    = 23;
            time.dwMinute  = 59;
            time.dwSecond  = 59;
            [recordSegment setEndTime:time];
        }
        
        long secs_x = recordSegment.beginTime.dwHour * 3600 + recordSegment.beginTime.dwMinute * 60 + recordSegment.beginTime.dwSecond;
        long secs_len = recordSegment.endTime.dwHour * 3600 + recordSegment.endTime.dwMinute * 60 + recordSegment.endTime.dwSecond - secs_x;
        
        // 竖屏FRAME
        CGRect frame = CGRectMake(secs_x * PIXELS_PERHOUR / 3600,
                                  0,
                                  secs_len * PIXELS_PERHOUR / 3600,
                                  _drawView.frame.size.height);
        recordView = [[UIView alloc] initWithFrame:frame];
        
        if (recordSegment.recordType == RECORD_TYPE_PLAN)
        {
            [recordView setBackgroundColor:CTimeUIColorFromRGB(0x0059B2, 1.0)];//blue
        }
        else if (recordSegment.recordType == RECORD_TYPE_MOVE)
        {
            [recordView setBackgroundColor:CTimeUIColorFromRGB(0x997F00, 1.0)];//yellow
        }
        else if (recordSegment.recordType == RECORD_TYPE_MANU)
        {
            [recordView setBackgroundColor:CTimeUIColorFromRGB(0x00802A, 1.0)];//green
        }
        else
        {
            [recordView setBackgroundColor:CTimeUIColorFromRGB(0x7F0000, 1.0)];//red
        }
        recordView.tag = iRecorderCounter++;
        [_recViewArray addObject:recordView];
        [_drawView addSubview:recordView];
        //找到最大的时间
        if((_maxTime.dwHour < recordSegment.endTime.dwHour))
        {
            _maxTime = recordSegment.endTime;
        }
        else if((_maxTime.dwHour = recordSegment.endTime.dwHour)
                &&((_maxTime.dwMinute < recordSegment.endTime.dwMinute)))
        {
            _maxTime = recordSegment.endTime;
        }
        else if((_maxTime.dwHour = recordSegment.endTime.dwHour)
                &&((_maxTime.dwMinute = recordSegment.endTime.dwMinute))
                &&((_maxTime.dwSecond < recordSegment.endTime.dwSecond)))
        {
            _maxTime = recordSegment.endTime;
        }
        
        
    }
}

/** @fn	cleanContentBar
 *  @brief  清除掉录像条
 *  @param  
 *  @return 无
 */
- (void)cleanContentBar
{
    // 首先清空原录像视图View, 无论本次是否为空
    if ([_recViewArray count] > 0)
    {
        for (UIView *recView in _recViewArray)
        {
            [recView removeFromSuperview];
        }
        [_recViewArray removeAllObjects];
    }
}

/** @fn	updateSlider
 *  @brief  更新进度位置
 *  @param  curTime - 当前播放时间
 *  @return 无
 */
- (BOOL)updateSlider:(TIME_STRUCT *)curTime;
{
    if (curTime == nil)
    {
        NSLog(@"curTime is nil");
        return NO;
    }
    
    if (_scrollView.dragging)
    {
        return YES;
    }
    
    // 更新进度条位置
    if (_scrollView != nil)
    {
        long secs_x = curTime->dwHour * 3600 + curTime->dwMinute * 60 + curTime->dwSecond;
        CGPoint curPoint = CGPointMake(secs_x * PIXELS_PERHOUR/3600, 0);
        [_scrollView setContentOffset:curPoint animated:YES];
    }
    
    return YES;
}

/** @fn	updateTimeBarTime
 *  @brief  更新时间标签内容
 *  @param  curTime - 当前时间
 *  @return 
 */
- (void)updateTimeBarTime:(TIME_STRUCT *)curTime
{
    if (curTime == nil)
    {
        return;
    }
    //更新日期标签
    [_dateLab setText:[NSString stringWithFormat:@"%d-%@-%@",
                       curTime->dwYear,
                       [self genString:curTime->dwMonth],
                       [self genString:curTime->dwDay]]];
    // 更新时间显示标签
    [_timeLab setText:[NSString stringWithFormat:@"%@:%@:%@", 
                       [self genString:curTime->dwHour],
                       [self genString:curTime->dwMinute],
                       [self genString:curTime->dwSecond]]];
}

/** @fn	genString
 *  @brief  由int生成string
 *  @param  i - int数
 *  @return NSString 对象
 */
- (NSString *)genString:(int)i
{
    if (i < 0 || i >= 60)
    {
        return @"00";
    }
    
    if (i < 10)
    {
        return [NSString stringWithFormat:@"0%d", i];
    }
    else
    {
        return [NSString stringWithFormat:@"%d", i];
    }
}

@end
