//
//  QualityPanelView.h
//  iVMS-8700-MCU
//
//  Created by apple on 15-3-19.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mcu_sdk/VideoPlaySDK.h"
@protocol QualityPanelViewDelegate;

@interface QualityPanelView : UIView

@property(nonatomic,assign)id<QualityPanelViewDelegate> delegate;

/**
 选中质量按钮

 @param index 选中button下标
 */
- (void)selectButton:(NSInteger)index;

@end

@protocol QualityPanelViewDelegate <NSObject>

/**
 切换视频码流

 @param qualityType 当前选择的视频码流
 */
-(void)qualityChange:(VP_STREAM_TYPE)qualityType;

@end
