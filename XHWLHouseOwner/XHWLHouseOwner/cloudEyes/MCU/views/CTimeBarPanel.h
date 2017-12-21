//
//  CTimeBarPanel.h
//  iVMSTest
//
//  Created by hikvision on 12-12-27.
//  Copyright (c) 2012年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mcu_sdk/VideoPlaySDK.h>

// 录像类型
#define RECORD_TYPE_PLAN        1       // 计划录像
#define RECORD_TYPE_MOVE        2       // 移动录像
#define RECORD_TYPE_MANU        16      // 手动录像
#define RECORD_TYPE_ALARM       4       // 报警录像

// 颜色值
#define CTimeUIColorFromRGB(rgbValue, alp)	[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                                                        green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
                                                         blue:((float)(rgbValue & 0xFF)) / 255.0 \
                                                        alpha:alp]

#define HOURS_PERPAGE                       6                                   // 每屏小时数
#define PIXELS_PERHOUR                      self.frame.size.width/HOURS_PERPAGE // 每秒像素数

#define SIZE_SCROLLCONTENT                  CGSizeMake(self.frame.size.width*(24/HOURS_PERPAGE + 1), self.frame.size.height)
#define FRAME_SLIDER                        CGRectMake(self.frame.size.width/2, 0, 2, self.frame.size.height)
#define FRAME_DRAWVIEW                      CGRectMake(self.frame.size.width/2, 48, self.frame.size.width*24/HOURS_PERPAGE, 10)

// 竖屏
#define LEN_LAB                             85
#define FRAME_DATELAB                       CGRectMake(self.frame.size.width/2 - LEN_LAB - 5, 9, LEN_LAB, 15)
#define FRAME_TIMELAB                       CGRectMake(self.frame.size.width/2 + 5, 9, LEN_LAB, 15)

#define FRAME_FS_DRAWVIEW                   CGRectMake(self.frame.size.width/2, 36, self.frame.size.width*24/HOURS_PERPAGE, 4)

@protocol CTimeBarDelegate <NSObject>

/**
 timeBar开始拖动
 */
- (void)timeBarStartDraggingDelegate;

/**
 timebar拖动中处理

 @param sTime 当前选择播放时刻
 @param timeBar timebar
 */
- (void)timeBarScrollDraggingDelegate:(TIME_STRUCT *)sTime timeBarObj:(id)timeBar;

/**
 timebar结束拖动处理

 @param sTime 当前选择播放时刻
 @param flag 当前时刻是否有录像片段
 */
- (void)timeBarStopScrollDelegate:(TIME_STRUCT *)sTime withFlag:(NSInteger) flag;

@end

@interface CTimeBarPanel : UIView
<UIScrollViewDelegate>
{
    UIImageView             *_bgImgView;                                        // 背景
    UIImageView             *_sliderImgView;                                    // 黄线图标
    UILabel                 *_dateLab;                                          // 年月日标签
    UILabel                 *_timeLab;                                          // 时分秒标签
    
    UIScrollView            *_scrollView;
    UIView                  *_drawView;                                         // 用于绘制的父视图
    
    NSMutableArray          *_recViewArray;                                     // 录像片段视图数组
    
    TIME_STRUCT                 _curTime;
    TIME_STRUCT                 _maxTime;
    TIME_STRUCT                 _tmpTime;
    BOOL                    _bFullScreen;                       //是否横屏
}

@property (nonatomic, assign) id<CTimeBarDelegate> delegate;
@property BOOL bFullScreen;

// Init
- (id)initWithFrame:(CGRect)frame bFullScreen:(BOOL)bFullScreen;

/**
 设置当前日期

 @param sDate 当前日期字符串
 */
- (void)setTimeBarDate:(NSString *)sDate;

/**
  绘制进度条

 @param recorderArray 录像文件数组
 @return 绘制是否成功
 */
- (BOOL)drawContentBar:(NSMutableArray *)recorderArray;

// 清除绘制条
- (void)cleanContentBar;

/**
 更新进度位置

 @param curTime 当前播放时间
 @return 更新是否成功
 */
- (BOOL)updateSlider:(TIME_STRUCT *)curTime;

/**
 更新时间标签内容

 @param curTime 当前播放时间
 */
- (void)updateTimeBarTime:(TIME_STRUCT *)curTime;

@end
