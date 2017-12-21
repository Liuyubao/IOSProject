//
//  PtzPresetPositionMultiDialView.h
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PtzPresetPositionDialView.h"

@protocol PtzPresetPositionMultiDialViewDelegate;

@interface PtzPresetPositionMultiDialView : UIView <PtzPresetPositionDialViewDelegate>

@property (nonatomic, weak) id<PtzPresetPositionMultiDialViewDelegate> delegate;
@property (nonatomic, strong) PtzPresetPositionDialView *ptzPresetPositionDialView1;
@property (nonatomic, strong) PtzPresetPositionDialView *ptzPresetPositionDialView2;
@property (nonatomic, strong) PtzPresetPositionDialView *ptzPresetPositionDialView3;

/**
 初始化预置点
 */
- (void)initDialNum;

@end

@protocol PtzPresetPositionMultiDialViewDelegate <NSObject>

- (void)ptzPresetPositionMultiDialView:(PtzPresetPositionMultiDialView *)ptzPresetPositionMultiDialView didSelectString:(NSString *)string;

- (void)ptzPresetPositionMultiDialView:(PtzPresetPositionMultiDialView *)ptzPresetPositionMultiDialView isSpinningChanged:(BOOL)isSpinning;

@end
