//
//  Date+Extension.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/9/20.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit

extension Date {
    
    /**
     * 获取当前时间
     *
     * @param dateFormat 格式，例如：“yyyy-MM-dd HH:mm:ss”
     * @return 返回格式化后的时间字符串
     */
    static func currentDate(_ dateFormat:String)->String {
        let date = Date()
        let dformatter = DateFormatter()
        dformatter.dateFormat = dateFormat
        dformatter.timeZone = TimeZone.init(abbreviation: "UTC")
        let currentDateString = dformatter.string(from: date)
        
        return currentDateString
    }

    static func getCurrentStamp() -> Int {
        //获取当前时间
        let now = Date()
        
        // 创建一个日期格式器
//        let dformatter = DateFormatter()
//        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
//        print("当前日期时间：\(dformatter.string(from: now))")
        
        //当前时间的时间戳
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        print("当前时间的时间戳：\(timeStamp)")
        
        return timeStamp
    }
    
    static func getCurrentDate()->String {
        let date = Date()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dformatter.string(from: date)
        
        return dateStr
    }
    
    // 时间戳转时间
    static func getDateWith(_ timeStamp:Int, _ formatString:String) -> String {
        //转换为时间
        let timeInterval:TimeInterval = TimeInterval(timeStamp/1000)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        //格式话输出
        let dformatter = DateFormatter()
        dformatter.dateFormat = formatString
        print("对应的日期时间：\(dformatter.string(from: date))")
        
        return dformatter.string(from: date)
    }
    
    // 时间戳转时间
    static func getDateWith(_ timeStamp:Int) -> String {
//        //时间戳
//        let timeStamp = 1463637809
        print("时间戳：\(timeStamp)")
        
        //转换为时间
        let timeInterval:TimeInterval = TimeInterval(timeStamp/1000)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        //格式话输出
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy/MM/dd"
        print("对应的日期时间：\(dformatter.string(from: date))")
        
        return dformatter.string(from: date)
    }
    
    // 时间戳转时间
    static func getStringDate(_ timeStamp:Int) -> String {
        //        //时间戳
        //        let timeStamp = 1463637809
        print("时间戳：\(timeStamp)")
        
        //转换为时间
        let timeInterval:TimeInterval = TimeInterval(timeStamp/1000)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        //格式话输出
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("对应的日期时间：\(dformatter.string(from: date))")
        
        return dformatter.string(from: date)
    }
}
