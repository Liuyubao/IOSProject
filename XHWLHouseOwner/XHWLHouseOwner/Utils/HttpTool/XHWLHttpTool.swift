//  XHWLHttpTool.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/8/31.
//  Copyright © 2017年 XHWL. All rights reserved.

import UIKit
import Foundation
import Alamofire

//let XHWLHttpURL:String = "http://112.74.19.135:1111/ssh/v1"
//let XHWLHttpURL:String = "http://192.168.2.101:9002"
//let XHWLHttpURL:String = "http://192.168.1.154:8080"
//let XHWLHttpURL:String = "http://120.77.83.190:8080/ssh/v1"
//let XHWLHttpURL:String = "http://10.51.37.54:8080/ssh/v1"
let XHWLHttpURL:String = "http://202.105.104.105:8006/ssh"

@objc protocol XHWLHttpToolDelegate:NSObjectProtocol {
    
    @objc func requestSuccess(_ requestKey:NSInteger, result request:Any)
    @objc func requestFail(_ requestKey:NSInteger, _ error:NSError)
    @objc optional func requestCancel(_ requestKey:NSInteger)

}

class XHWLHttpTool: NSObject {
    /**
     *  超时时间
     */
    var validTime:NSInteger? = 30 // 默认超时时间为10妙
    var delegate:XHWLHttpToolDelegate?
    var requestKey:XHWLRequestKeyID?
    var _isCancelled:Bool = false
    
    func initWithKey(_ requestKey:XHWLRequestKeyID, _ delegate:XHWLHttpToolDelegate) {
        self.requestKey = requestKey
        self.delegate = delegate
    }
    
    // 获取请求URL
    func requestWithKey() -> String {
        print("\(self.requestKey)")
        let transId = XHWLRequestKeyDefine.shared.trandIdDict.object(forKey: self.requestKey ?? 0) as! String
        
        if transId.isEmpty {
            return XHWLHttpURL
        } else {
            return "\(XHWLHttpURL)/\(transId)"
        }
    }
    
    // GET 请求方式
    func getHttpTool(_ parameters: NSArray) {
        let paramStr:String = parameters.componentsJoined(by: "/") as String
        var requestUrl:String = requestWithKey()
        if !paramStr.isEmpty {
           requestUrl = "\(requestUrl)/\(paramStr)"
        }
        print("requestUrl = \(requestUrl) \n")
        Alamofire.request(requestUrl, method: .get, parameters: [:], encoding: URLEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("success:\(value)")
                    let errorCode = (value as! NSDictionary)["errorCode"] as! Int
                    switch errorCode{
                    case 200:
                        self.delegate?.requestSuccess(self.requestKey!.rawValue, result:value as! [String : AnyObject])
                        break
                    case 201:
                        "系统异常，操作失败".ext_debugPrintAndHint()
                        break
                    default:
                        break
                    }
                case .failure(let error):
                    print("error:\(error)")
                    "请求失败！".ext_debugPrintAndHint()
                    self.delegate?.requestFail(self.requestKey!.rawValue, error as NSError)
                }
        }
    }

    // POST 请求方式
    func postHttpTool(_ parameters: Parameters) {
        
        let requestUrl:String = requestWithKey()
        print("requestUrl = \(requestUrl) \n param = \(parameters)")
        
        Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseJSON { response in
//                XHMLProgressHUD.shared.hide()
                //当请求后response是我们自定义的，这个变量用于接受服务器响应的信息
                //使用switch判断请求是否成功，也就是response的result
                switch response.result {
                case .success(let value):
                    print("success:\(value)")
                    let errorCode = (value as! NSDictionary)["errorCode"] as! Int
                    switch errorCode{
                    case 201:
                        "系统异常，操作失败".ext_debugPrintAndHint()
                        break
                    case 400,401:       //已经退出登录、或者token失效，跳转到登录界面
                        ((value as! NSDictionary)["message"] as! String).ext_debugPrintAndHint()
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let loginVC = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                        window.rootViewController = loginVC
                        loginVC?.dismiss(animated: true, completion: nil)
                        break
                    default:
                        self.delegate?.requestSuccess(self.requestKey!.rawValue, result:value as! [String : AnyObject])
                        break
                    }
                    
                case .failure(let error):
                    print("error:\(error)")
                    
                    "请求失败！".ext_debugPrintAndHint()
                    self.delegate?.requestFail(self.requestKey!.rawValue, error as NSError)
                }
        }
    }
    
    func uploadHttpTool(_ params:[String:String], _ data: [Data], _ name: [String]){
        
        let headers = ["content-type":"multipart/form-data"]
        let requestUrl:String = requestWithKey()
        print("requestUrl = \(requestUrl) \n param = \(params)")
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                for i in 0..<params.count {
                    
                    let dict = params as NSDictionary
                    let param = dict.allValues[i] as! String
                    
                    multipartFormData.append((param.data(using: String.Encoding.utf8)!), withName: dict.allKeys[i] as! String)
                }
                
                for i in 0..<data.count { // "image.png"  "appPhoto"
                    multipartFormData.append(data[i], withName:"appPhoto\(i)", fileName: name[i], mimeType: "image/png")
                }
        },
            to: requestUrl,
            method:.post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let value = response.result.value as? [String: AnyObject]{
                            
                            print("success:\(value)")
                            self.delegate?.requestSuccess(self.requestKey!.rawValue, result:value)
                        }
                    }
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                    "请求失败！".ext_debugPrintAndHint()
                    self.delegate?.requestFail(self.requestKey!.rawValue, encodingError as NSError)
                }
        }
        )
    }

    // GET 请求方式
//    func getHttpTool(url:String, parameters: NSArray,  success:@escaping (_ responseObject: [String : AnyObject])->(), failture:@escaping (_ error : NSError)->()) {
//        
//        var requestUrl:String = ""
//        if XHWLHttpURL.compare("").rawValue == 0 {
//            requestUrl = url
//        } else {
//            requestUrl = "\(XHWLHttpURL)/\(url)"
//        }
//        
//        let paramStr:String = parameters.componentsJoined(by: "/") as String
//        requestUrl = "\(requestUrl)/\(paramStr)"
//        
//        print("requestUrl = \(requestUrl) \n")
//        
//        Alamofire.request(requestUrl, method: .get, parameters: [:], encoding: URLEncoding.default)
//            .responseJSON { response in
//                
//                switch response.result {
//                case .success(let value):
//                    print("success:\(value)")
//                    success(value as! [String : AnyObject])
//                    
//                case .failure(let error):
//                    failture(error as NSError)
//                    print("error:\(error)")
//                    "请求失败！".ext_debugPrintAndHint()
//                }
//        }
//    }
//    
//    // POST 请求方式  block:@escaping ((DataResponse<Any>)->()))
//    func postHttpTool(url:String, parameters: Parameters, success:@escaping (_ responseObject: [String : AnyObject])->(), failture:@escaping (_ error : NSError)->()) {
//        
//        var requestUrl:String = ""
//        if XHWLHttpURL.compare("").rawValue == 0 {
//            
//            requestUrl = url
//        } else {
//            
//            requestUrl = "\(XHWLHttpURL)/\(url)"
//        }
//        
//        print("requestUrl = \(requestUrl) \n param = \(parameters)")
//        
//        Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: URLEncoding.default)
//            .responseJSON { response in
//
////                print(response.request)  // original URL request
////                print(response.response) // HTTP URL response
////                print(response.data)     // server data
////                print(response.result)   // result of response serialization
//                
//                //当请求后response是我们自定义的，这个变量用于接受服务器响应的信息
//                //使用switch判断请求是否成功，也就是response的result
//                switch response.result {
//                case .success(let value):
//                    print("success:\(value)")
//                    success(value as! [String : AnyObject])
//                    
//                case .failure(let error):
//                    failture(error as NSError)
//                    print("error:\(error)")
//                    
//                    "请求失败！".ext_debugPrintAndHint()
//                }
//        }
//    }
    
    //MARK: - 照片上传
    ///
    /// - Parameters:
    ///   - urlString: 服务器地址
    ///   - params: ["flag":"","userId":""] - flag,userId 为必传参数
    ///        flag - 666 信息上传多张  －999 服务单上传  －000 头像上传
    ///   - data: image转换成Data
    ///   - name: fileName
    ///   - success:
    ///   - failture:
//    func uploadHttpTool(url : String, params:[String:String], data: [Data], name: [String],success : @escaping (_ response : [String : AnyObject])->(), failture : @escaping (_ error : Error)->()){
//        
//        let headers = ["content-type":"multipart/form-data"]
//        var requestUrl:String = ""
//        if XHWLHttpURL.compare("").rawValue == 0 {
//            
//            requestUrl = url
//        } else {
//            
//            requestUrl = "\(XHWLHttpURL)/\(url)"
//        }
//        
//        print("requestUrl = \(requestUrl) \n param = \(params)")
//        
//        Alamofire.upload(
//            multipartFormData: { multipartFormData in
//                
//                for i in 0..<params.count {
//                    
//                    let dict = params as NSDictionary
//                    let param = dict.allValues[i] as! String
//                    
//                    multipartFormData.append((param.data(using: String.Encoding.utf8)!), withName: dict.allKeys[i] as! String)
//                }
// 
//                for i in 0..<data.count { // "image.png"  "appPhoto"
//                    multipartFormData.append(data[i], withName:"appPhoto\(i)", fileName: name[i], mimeType: "image/png")
//                }
//        },
//            to: requestUrl,
//            method:.post,
//            headers: headers,
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        if let value = response.result.value as? [String: AnyObject]{
//                           
//                            // let json = JSON(value)
//                            print(value)
//                            success(value)
//                        }
//                    }
//                case .failure(let encodingError):
//                    print(encodingError)
//                    failture(encodingError)
//                }
//        }
//        )
//    }
}
