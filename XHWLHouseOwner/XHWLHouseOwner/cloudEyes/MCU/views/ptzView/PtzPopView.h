//
//  PtzPopView.h
//  iVMS-4500
//
//  Created by gumingjun on 14-10-8.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PtzPopViewDelegate;

@interface PtzPopView : UIView

typedef enum
{
    PtzPopUndefineInterface = 0,
    PtzPopZoomInterface,        //焦距
    PtzPopFocusInterface,       //聚焦
    PtzPopIrisInterface         //光圈
}PtzPopInterface; //类型

@property (nonatomic, assign) PtzPopInterface ptzPopInterface;
@property (nonatomic, weak) id<PtzPopViewDelegate> delegate;

@end

@protocol PtzPopViewDelegate <NSObject>

/**
 云台控制命令代理方法

 @param command 云台操作命令编号
 @param stop 是否停止控制
 @param end 是否结束操作
 */
- (void)ptzPopViewOperation:(int)command stop:(BOOL)stop end:(BOOL)end;

@end
