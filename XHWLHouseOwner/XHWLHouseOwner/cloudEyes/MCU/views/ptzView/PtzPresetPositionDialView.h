//
//  PtzPresetPositionDialView.h
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PtzPresetPositionDialViewDelegate;

@interface PtzPresetPositionDialView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *selectedString;
@property (nonatomic, assign) BOOL isSpinning;
@property (nonatomic, weak) id<PtzPresetPositionDialViewDelegate> delegate;

// 初始化滚轮数字范围，设置初始化位置
- (id)initWithNumArray:(NSArray *)numArray;
// 转到相应的位置
- (void)spinToString:(NSString *)string;

@end

@protocol PtzPresetPositionDialViewDelegate <NSObject>

// 旋转到相应位置的回调,获取字符串的位置
- (void)ptzPresetPositionDialView:(PtzPresetPositionDialView *)ptzPresetPositionDialView didSnapToString:(NSString *)string;

/**
  预置点选择视图滑动回调代理

 @param ptzPresetPositionDialView 当前在滑动的视图
 @param isSpinning 是否在滑动
 */
- (void)ptzPresetPositionDialView:(PtzPresetPositionDialView *)ptzPresetPositionDialView isSpinningChanged:(BOOL)isSpinning;

@end
