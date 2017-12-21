//
//  XHWLHouseOwner-Bridging-Header.h
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/31.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

#ifndef XHWLHouseOwner_Bridging_Header_h
#define XHWLHouseOwner_Bridging_Header_h

#import "Mcu_sdk/MCUVmsNetSDK.h"
#import "Mcu_sdk/VideoPlaySDK.h"
#import "Mcu_sdk/MCUResourceNode.h"
#import "Mcu_sdk/VPCaptureInfo.h"
#import "Mcu_sdk/RealPlayManager.h"
//#import "OCFunction.h"

#import <CommonCrypto/CommonDigest.h>
#import "RealPlayViewController.h"
#import "PlayBackViewController.h"


#import "PlayView.h"
#import "QualityPanelView.h"
#import "PtzPanelView.h"

//Agora sdk
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraRtcCryptoLoader/AgoraRtcCryptoLoader.h>
#import "AGVideoPreProcessing.h"


//Car plate
#import "UIView_extra.h"
#import "NSString+Extra.h"
#import "UIView+SDAutoLayout.h"

//导入qqAPI
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiinterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/sdkdef.h>
//#import <TencentOpenAPI/TencentmessageObject.h>
//#import <TencentOpenAPI/TencentOAuthObject.h>

//导入WXAPI
#import "WXApi.h"

//MJExtension
#import "MJExtension.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#endif /* XHWLHouseOwner_Bridging_Header_h */
