//
//  NSString+Check.h
//  LiveHero
//
//  Created by captain on 16/3/12.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extra)

typedef NS_ENUM(NSUInteger, MHMobileNubmerType) {
    //不是手机号
    MHMobileNubmerType_NONE = 0,
    
    //中国移动
    MHMobileNubmerType_CM,
    
    //中国联通
    MHMobileNubmerType_CU,
    
    //中国电信
    MHMobileNubmerType_CT,
    
    //其他未知
    MHMobileNubmerType_OTHER
};

/// 判断字符串 是不是 全是中文
- (BOOL)xnIsChinese;

/// 两个时间之差
+ (NSString *)intervalFromLastDate:(NSString *) dateString1 toTheDate:(NSString *)dateString2;

/// 判断电话号码
- (MHMobileNubmerType)NSStringCheckIsPhoneNumber;

/// 判断是不是邮箱
-(BOOL)NSStirngCheckIsEmail;


@end
