//
//  NetworkTools.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/25.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import Alamofire

class NetworkTools{
    
    static let baseUrl = XHWLHttpURL
//    static let baseUrl = "http://192.168.1.150:8080/ssh/v1"
    
    //返回 获取验证码 是否成功
    static func getVerificatCode(telephone: String) ->Bool{
        var ifSucceed = false
        var params = Dictionary<String, String>()
        params["telephone"] = telephone
        
        Alamofire.request("\(baseUrl)/appBase/register/getVerificatCode", method: .post ,parameters: params).responseJSON{response in
            print("\(response.request)")
            print("\(response.response)")
            print("\(response.data)")
            print("\(response.result)")
            
            
            if let result = response.result.value as? NSDictionary{
                print("Result:\(result)")
                
                print(result.count)
                print(result.allKeys)
                
                print(result["state"] as! Bool)
                ifSucceed = result["state"] as! Bool
            }
        }
        
        return ifSucceed
    }
    
    //验证码验证
    static func testVerificatCode(telephone: String, verificatCode: String) -> Bool{
        var params = Dictionary<String, String>()
        var ifSucceed = false
        params["telephone"] = telephone
        params["verificatCode"] = verificatCode
        
        Alamofire.request("\(baseUrl)/appBase/register/testVerificatCode", method: .post ,parameters: params).responseJSON{response in
            print("\(response.request)")
            print("\(response.response)")
            print("\(response.data)")
            print("\(response.result)")
            
            if let result = response.result.value as? NSDictionary{
                print("Resulr:\(result)")
                
                print(result.count)
                print(result.allKeys)
                print(result["state"] as! Bool)
                ifSucceed = result["state"] as! Bool
                
                
            }
        }
        return ifSucceed
    }
    
    //完成注册
    static func register(telephone: String, password: String, verificatCode: String) -> Bool{
        var params = Dictionary<String, String>()
        var ifSucceed = false
        params["telephone"] = telephone
        params["verificatCode"] = verificatCode
        params["password"] = password
        Alamofire.request("\(baseUrl)/appBase/register", method: .post ,parameters: params).responseJSON{response in
            print("\(response.request)")
            print("\(response.response)")
            print("\(response.data)")
            print("\(response.result)")
            
            if let result = response.result.value as? NSDictionary{
                print("Resulr:\(result)")
                
                print(result.count)
                print(result.allKeys)
                print(result["state"] as! Bool)
                ifSucceed = result["state"] as! Bool
                
            }
        }
        return ifSucceed
    }
    
//    //完成登陆
//    static func login(telephone: String, password: String) -> Bool{
//        Alamofire.request("\(baseUrl)/appBase/login", method: .post ,parameters: params).responseJSON{response in
//            
//            if let result = response.result.value as? NSDictionary{
//                print("Resulr:\(result)")
//            }
//        }
//    }
    
    
    
    
    
}
