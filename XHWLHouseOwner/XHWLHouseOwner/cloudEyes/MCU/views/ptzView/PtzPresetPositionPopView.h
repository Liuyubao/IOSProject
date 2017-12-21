//
//  PtzPresetPositionPopView.h
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PtzPresetPositionMultiDialView.h"

@protocol PtzPresetPositionPopViewDelegate;

@interface PtzPresetPositionPopView : UIView

@property (nonatomic, weak) id<PtzPresetPositionPopViewDelegate> delegate;

@end

@protocol PtzPresetPositionPopViewDelegate <NSObject>

/**
 预置点命令按钮被点击
 */
- (void)ptzPresetPositionPopViewButtonTouchUpInside;

/**
 预置点操作代理

 @param command 云台控制命令
 @param index 当前的预置点
 */
- (void)ptzPresetPositionOperation:(int)command index:(int)index;

/**
 预置点选择视图滑动回调代理

 @param isSpinning 视图是否正在滑动
 */
- (void)ptzPresetPositionPopViewDialIsSpinningChanged:(BOOL)isSpinning;

@end
