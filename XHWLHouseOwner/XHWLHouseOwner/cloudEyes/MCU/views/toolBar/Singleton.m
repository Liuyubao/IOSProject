//
//  Singleton.m
//  iVMS4500
//
//  Created by wuyang on 12-5-28.
//  Copyright (c) 2012年 Hangzhou Hikvision Digital Tech. Co.,Ltd. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+ (id)sharedInstance
{
    static NSMutableDictionary *s_class2InstanceDictionary;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        s_class2InstanceDictionary = [[NSMutableDictionary alloc] initWithCapacity:1]; // 随进程释放
    });

    NSString *className = NSStringFromClass([self class]);
    Singleton *instance;
    @synchronized([self class])
    {
        @synchronized(s_class2InstanceDictionary)
        {
            instance = [s_class2InstanceDictionary valueForKey:className];
        }
        if (!instance)
        {
            instance = [[self alloc] init]; // 避免因init中调用其它单例引起死锁
            @synchronized(s_class2InstanceDictionary)
            {
                [s_class2InstanceDictionary setValue:instance forKey:className];
            }
        }
    }
    return instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
