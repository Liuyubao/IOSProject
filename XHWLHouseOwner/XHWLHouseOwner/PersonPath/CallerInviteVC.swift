//
//  CallerInviteVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2018/1/31.
//  Copyright © 2018年 xinghaiwulian. All rights reserved.
//

import UIKit
import WebKit

class CallerInviteVC: UIViewController , WKScriptMessageHandler, WKNavigationDelegate{
    var loadUrl:String = "http://202.105.96.131:3002/sendCard/#/callerInvite/?" //访客邀请的h5
    var recordUrl:String = "http://202.105.96.131:3002/sendCard/#/callerNodepad/?"  //访客记录的h5
    var userName:String!
    var projectCode:String!
    var phoneNum:String!
    
    lazy var webView : WKWebView = {
        //配置环境
        //初始化WKWebViewConfiguration
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        webConfiguration.userContentController = userContentController
        //JS调用Swift
        userContentController.add(self, name: "passValue")
        let web = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        web.frame = CGRect(x:0, y:0,width:Screen_width, height:Screen_height)
        self.view.addSubview(web)
        return web
    }()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "passValue":
            if let dic = message.body as? NSDictionary {
                let endTime: String = (dic["endTime"] as AnyObject).description
                let startTime: String = (dic["startTime"] as AnyObject).description
                let url: String = (dic["url"] as AnyObject).description
                self.presentShareInterface(url, startTime, endTime)
            }
            break
        default:
            
            break
        }
    }
    
    func presentShareInterface(_ qrCodeUrl: String, _ starTime: String, _ endTime: String) {
        "分享".ext_debugPrintAndHint()
//        let shareMenuV = ShareMenuView()
//        shareMenuV.menuShow { (index) in
//            if (index == 0) {       //微信分享
//                shareMenuV.shareToplatform(UMSocialPlatformType.wechatSession, self, qrCodeUrl)
//            }else if (index == 1) {     //QQ分享
//                shareMenuV.shareToplatform(UMSocialPlatformType.QQ, self, qrCodeUrl)
//            }else if (index == 2) {     //短信分享
//                let messageVC = MFMessageComposeViewController.init()
//                messageVC.body = "【中海专业维修】\(self.userName!)邀请您于 \(starTime) 至 \(endTime) 前往兴海物联本部做客。期间您可通过以下二维码出入小区。二维码链接：\(qrCodeUrl)。"
//                messageVC.messageComposeDelegate = self
//                self.present(messageVC, animated: true, completion: nil)
//            }
//
//        }
//        self.view.addSubview(shareMenuV)
    }
    
    func backToPre() {
        if self.webView.canGoBack{
            self.webView.goBack()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func toRecord() {
        let invitRecordVC = InviteRecordWebVC()
        self.navigationController?.pushViewController(invitRecordVC, animated: true)
        invitRecordVC.recordUrl = recordUrl
        invitRecordVC.userName = self.userName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[获取参数]取出user的信息
        let data = UserDefaults.standard.object(forKey: "user") as? NSData
        let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
        //从沙盒中获得curInfomodel
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
        let projectCode = curInfoModel?.curProject.projectCode as! String
        let name = userModel?.name as! String
        let encodeUrlStr:String = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let phone = userModel?.telephone as! String
        let urlString =  "\(inviteQRCodeUrl)?projectCode=\(projectCode)&userName=\(encodeUrlStr)&granterPhone=\(phone)"
        let url = URL(string: urlString)
//        recordUrl = "\(recordUrl)projectCode=\(projectCode)&userName=\(encodeUrlStr)&granterPhone=\(phone)"
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backToPre))
//            UIBarButtonItem.WSH_BarButtonItemWithImage(UIImage(named:"nav_back")!, UIImage(named:"nav_back")!, self, #selector(backToPre), .touchUpInside)
        let backBtn = UIButton()
        backBtn.frame = CGRect(x:10,y:20,width:23,height:18)
        backBtn.setBackgroundImage(UIImage(named: "nav_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backToPre), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
        let recordBtn = UIButton()
        recordBtn.frame = CGRect(x:10,y:20,width:37,height:60)
        recordBtn.setTitle("记录", for: .normal)
        recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recordBtn.setTitleColor(UIColor.blue, for: .normal)
        recordBtn.addTarget(self, action:#selector(toRecord), for:.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: recordBtn)
        self.title = "访客邀请"
//        let encodeUrlStr:String = userName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        let urlStr = "\(loadUrl)projectCode=\(projectCode!)&userName=\(encodeUrlStr)&granterPhone=\(phoneNum!)"
//        recordUrl = "\(recordUrl)projectCode=\(projectCode!)&userName=\(encodeUrlStr)&granterPhone=\(phoneNum!)"
//        /// 设置访问的URL
//        let url = NSURL(string: urlStr)
        /// 根据URL创建请求
        let requst = NSURLRequest(url: url! as URL)
        /// 设置代理
        webView.navigationDelegate = self
        /// WKWebView加载请求
        webView.load(requst as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
