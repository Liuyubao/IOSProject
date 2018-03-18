//
//  AudioManager.m
//  XHWLHouseManager
//
//  Created by admin on 2018/1/10.
//  Copyright © 2018年 XHWL. All rights reserved.
//

#import "AudioManager.h"

#define IOSVersion [[UIDevice currentDevice].systemVersion floatValue]

@implementation AudioManager

static AudioManager *_audioManager = NULL;

+(AudioManager*)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioManager = [[AudioManager alloc] init];
    });
    
    return _audioManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _isSpeakerOn = NO;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [audioSession setActive:YES error:nil];
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
        
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                         audioRouteChangeListenerCallback, (__bridge void *)(self));
    }
    
    return self;
}

- (void)setSpeakerOn
{
    NSLog(@"setSpeakerOn:%d",[NSThread isMainThread]);
    UInt32 doChangeDefaultRoute = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (doChangeDefaultRoute),
                             &doChangeDefaultRoute
                             );
    
    _isSpeakerOn = [self checkSpeakerOn];
    _isHeadsetOn = NO;
    //[self resetOutputTarget];
}

- (void)setSpeakerOff
{
    UInt32 doChangeDefaultRoute = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (doChangeDefaultRoute),
                             &doChangeDefaultRoute
                             );
    
    _isSpeakerOn = [self checkSpeakerOn];
}

- (BOOL)checkSpeakerOn
{
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0))
    {
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        NSRange speakerRange = [routeStr rangeOfString: @"Speaker"];
        if (speakerRange.location != NSNotFound)
            return YES;
    }
    return NO;
}

- (BOOL)hasHeadset
{
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0))
    {
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        if ([routeStr isEqualToString:@"ReceiverAndMicrophone"]) {
            
            // static dispatch_once_t onceToken;
            
            // dispatch_once(&onceToken, ^{
            
            // [self setSpeakerOn];
            
            // });
            
            [self setSpeakerOn];
        }
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound)
        {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

// 判断麦克风是否有用
- (BOOL)hasMicphone
{
    return [[AVAudioSession sharedInstance] isInputAvailable];
}

- (void)erjiOutPutTarget
{
    BOOL hasHeadset = [self hasHeadset];
    if (hasHeadset) {
        _isHeadsetOn = YES;
    }
    
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset?@YES:@NO);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (void)resetOutputTarget
{
    BOOL hasHeadset = [self hasHeadset];
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset?@YES:@NO);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    _isHeadsetOn = NO;
}

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueS, const void *inPropertyValue)
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange)
        return;
    
    // Determines the reason for the route change, to ensure that it is not
    // because of a category change.
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    //    NSLog(@<<
    NSLog(@"=======%@",inUserData);
    AudioManager *pMgr = (__bridge AudioManager *)inUserData;
    
    //没有耳机
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        [pMgr setSpeakerOn];
        [pMgr resetOutputTarget];
    }  else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
        [pMgr erjiOutPutTarget];
    } else if (routeChangeReason == kAudioSessionRouteChangeReason_Override){
        [pMgr setSpeakerOn];
        [pMgr resetOutputTarget];
    }
//    NSLog(@"-------->%f",IOSVersion);
    //if (IOSVersion >= 8.0) {
    
    if (routeChangeReason==8) {
        [pMgr hasHeadset];
    }
    //}
}
                            
                            
                            
//- (BOOL)isAirplayActived

//{

// CFDictionaryRef currentRouteDescriptionDictionary = nil;

// UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);

// AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, ¤tRouteDescriptionDictionary);

//

// BOOL airplayActived = NO;

// if (currentRouteDescriptionDictionary)

// {

// CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);

// if(outputs != NULL && CFArrayGetCount(outputs) > 0)

// {

// CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);

// //Get the output type (will show airplay / hdmi etc

// CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);

//

// airplayActived = (CFStringCompare(outputType, kAudioSessionOutputRoute_AirPlay, 0) == kCFCompareEqualTo);

// }

// CFRelease(currentRouteDescriptionDictionary);

// }

// return airplayActived;

//}



/*
 
 - (void)openloudspeaker{
 
 //初始化播放器的时候如下设置
 
 UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
 
 AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
 
 sizeof(sessionCategory),
 
 &sessionCategory);
 
 
 
 UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
 
 AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
 
 sizeof (audioRouteOverride),
 
 &audioRouteOverride);
 
 
 
 AVAudioSession *audioSession = [AVAudioSession sharedInstance];
 
 //默认情况下扬声器播放
 
 [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
 
 [audioSession setActive:YES error:nil];
 
 [self handleNotification:YES];
 
 
 
 }
 
 #pragma mark - 监听听筒or扬声器
 
 - (void) handleNotification:(BOOL)state
 
 {
 
 [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
 
 
 
 if(state)//添加监听
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 
 selector:@selector(sensorStateChange:) name:@UIDeviceProximityStateDidChangeNotification
 
 object:nil];
 
 else//移除监听
 
 [[NSNotificationCenter defaultCenter] removeObserver:self name:@UIDeviceProximityStateDidChangeNotification object:nil];
 
 }
 
 
 
 //处理监听触发事件
 
 -(void)sensorStateChange:(NSNotificationCenter *)notification;
 
 {
 
 //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
 
 if ([[UIDevice currentDevice] proximityState] == YES)
 
 {
 
 NSLog(@Device is close to user);
 
 [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
 
 }
 
 else
 
 {
 
 NSLog(@Device is not close to user);
 
 [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
 
 }
 
 }
 
 */

@end
