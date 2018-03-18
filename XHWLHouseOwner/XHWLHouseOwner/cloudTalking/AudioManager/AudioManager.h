//
//  AudioManager.h
//  XHWLHouseManager
//
//  Created by admin on 2018/1/10.
//  Copyright © 2018年 XHWL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager: NSObject
{
    AVAudioPlayer *m_audioPlayer;
}

@property (atomic, readonly) BOOL isSpeakerOn;
@property (atomic, readonly) BOOL isHeadsetOn;

+(AudioManager*)shared;

// 打开扬声器
- (void)setSpeakerOn;

// 关闭扬声器
- (void)setSpeakerOff;
@end
