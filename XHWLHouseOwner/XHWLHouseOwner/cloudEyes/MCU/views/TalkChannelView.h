//
//  TalkChannelView.h
//  iVMS-8700-MCU
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 HikVision. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TalkChannelDelegate;

@interface TalkChannelView : UIView<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, assign)NSInteger simulateCount;/**< 模拟通道数量*/
@property(nonatomic, weak)id<TalkChannelDelegate> delegate;

@end

@protocol TalkChannelDelegate <NSObject>

/**
 *  确认选择通道
 *
 *  @param talkChannel 通道号
 */
- (void)talkChannelChoose:(NSInteger)talkChannel;

/**
 *  取消对讲通道选择
 */
- (void)cancelTalkChannel;

@end
