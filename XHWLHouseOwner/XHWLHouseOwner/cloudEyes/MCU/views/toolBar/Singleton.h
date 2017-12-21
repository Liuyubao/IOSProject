//
//  Singleton.h
//  iVMS4500
//
//  Created by wuyang on 12-5-28.
//  Copyright (c) 2012年 Hangzhou Hikvision Digital Tech. Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// 线程安全、可多子类共存
@interface Singleton : NSObject

+ (id)sharedInstance;

@end
