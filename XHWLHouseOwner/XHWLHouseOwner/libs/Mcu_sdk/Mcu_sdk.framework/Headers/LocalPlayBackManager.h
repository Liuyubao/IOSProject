//
//  LocalPlayBackManager.h
//  Mcu_sdk
//
//  Created by chenmengyi on 2017/11/1.
//  Copyright © 2017年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlaySDK.h"
#import <Foundation/Foundation.h>

@protocol LocalPlayBackManagerDelegate;

@interface LocalPlayBackManager : NSObject

@property (nonatomic, weak) id<LocalPlayBackManagerDelegate>delegate;

/**
 播放本地录像
 
 @param localVideoName 录像名称
 @param playView 播放视图
 @param complete YES成功 NO失败
 */
- (void)startPlaybackLocalVideo:(NSString *)localVideoName playView:(UIView *)playView complete:(void(^)(BOOL finish, NSString *message))complete;

/**
 停止播放本地录像
 */
- (BOOL)stopPlayLocalVideo;

/**
 暂停播放本地录像
 */
- (BOOL)pausePlayLocalVideo;

/**
 暂停后重新播放本地录像
 */
- (BOOL)resumePlayLocalVideo;

/**
 对播放画面进行抓图
 
 @param captureInfo 设置的抓图信息对象.抓图信息通过调用VideoPlayUtility类的 + getCaptureInfo: toCaptureInfo: 方法设置
 @return YES抓图成功,NO抓图失败
 */
- (BOOL)localCapture:(VPCaptureInfo *)captureInfo;

/**
 开启声音

 @return YES 成功  NO 失败
 */
- (BOOL)openAudio;

/**
 关闭声音

 @return YES 成功  NO 失败
 */
- (BOOL)closeAudio;

/**
 获取当前已经播放的时间

 @return 播放时间
 */
- (NSTimeInterval)getPlayedTime;

/**
 获取录像文件总时间

 @return 录像文件总时间
 */
- (NSTimeInterval)getTotalTime;

/**
 设置文件播放位置

 @param sliderValue 位置（0-1）
 */
- (void)getFilePlayedPercentage:(CGFloat)sliderValue;

@end

@protocol LocalPlayBackManagerDelegate <NSObject>
/**
 播放库回放回调函数
 
 用户可通过播放库返回的不同播放状态进行自己的业务处理
 
 @param playState 当前播放状态
 @param localPlayBackManager 本地回放管理类
 */
- (void)localPlayBackCallBack:(PLAY_STATE)playState playBackManager:(LocalPlayBackManager *)localPlayBackManager;

@end
