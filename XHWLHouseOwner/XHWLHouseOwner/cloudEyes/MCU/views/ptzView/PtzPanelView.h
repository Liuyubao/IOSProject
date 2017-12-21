//
//  PtzPanelView.h
//  iVMS-8700-MCU
//
//  Created by apple on 15-3-19.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PtzPanelViewDelegate;

@interface PtzPanelView : UIView
@property (nonatomic, weak) id<PtzPanelViewDelegate> delegate;

//按钮是否被选中
@property (nonatomic, assign) BOOL isPanAutoState;
@property (nonatomic, assign) BOOL isZoomState;
@property (nonatomic, assign) BOOL isFocusState;
@property (nonatomic, assign) BOOL isIrisState;
@property (nonatomic, assign) BOOL isPresetPositionState;

@end

@protocol PtzPanelViewDelegate <NSObject>
/**
 自动巡航按钮点击代理
 */
- (void)ptzPanelViewPanAutoButtonTouchUpInside;

/**
 焦距按钮点击代理
 */
- (void)ptzPanelViewZoomButtonTouchUpInside;

/**
 聚焦按钮点击代理
 */
- (void)ptzPanelViewFocusButtonTouchUpInside;

/**
 光圈按钮点击代理
 */
- (void)ptzPanelViewIrisButtonTouchUpInside;

/**
 预置点按钮点击代理
 */
- (void)ptzPanelViewPresetPositionButtonTouchUpInside;

@end
