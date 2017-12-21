//
//  NSString+Check.m
//  LiveHero
//
//  Created by captain on 16/3/12.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//

#import "NSString+Extra.h"

@implementation NSString (Extra)

/// 判断字符串 是不是 全是中文
- (BOOL)xnIsChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}


#pragma mark - 两个时间之差
+ (NSString *)intervalFromLastDate:(NSString *) dateString1 toTheDate:(NSString *)dateString2 {
    
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    
    dateString1=[timeArray1 objectAtIndex:0];
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    
    dateString2=[timeArray2 objectAtIndex:0];
    
    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    //        min = [min substringToIndex:min.length-7];
    //    秒
    sen=[NSString stringWithFormat:@"%@", sen];
    
    
    
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    //        min = [min substringToIndex:min.length-7];
    //    分
    min=[NSString stringWithFormat:@"%@", min];
    
    
    //    小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    //        house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    
    
    timeString=[NSString stringWithFormat:@"%@时%@分%@秒",house,min,sen];
    
    return timeString;
}


#pragma mark - 判断是不是邮箱
-(BOOL)NSStirngCheckIsEmail{
    NSString * EMAIL = @"[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?";
    NSPredicate *regextestemail = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL];
    return ([regextestemail evaluateWithObject:self] == YES);
}

#pragma mark - 判断手机号码
- (MHMobileNubmerType)NSStringCheckIsPhoneNumber {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     * 联通：130,131,132,145,152,155,156,176,185,186
     * 电信：133,1349,153,177,180,181,189
     */
    NSString * MOBILE = @"^1(3[0-9]|4[57]|5[0-235-9]|7[06-8]|8[0-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|47|5[0-27-9]|78|8[2-478])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|45|5[256]|176|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,181,189
     */
    NSString * CT = @"^1((33|53|77|8[019])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if ([regextestmobile evaluateWithObject:self] == YES)
    {
        if ([regextestcm evaluateWithObject:self] == YES) {
            return MHMobileNubmerType_CM;
        }else if ([regextestcu evaluateWithObject:self] == YES){
            return MHMobileNubmerType_CU;
        }else if([regextestct evaluateWithObject:self] == YES){
            return MHMobileNubmerType_CT;
        }else{
            return MHMobileNubmerType_OTHER;
        }
    }
    else
    {
        return MHMobileNubmerType_NONE;
    }
}

@end
