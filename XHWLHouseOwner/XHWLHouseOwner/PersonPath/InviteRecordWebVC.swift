//
//  InviteRecordWebVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2018/1/31.
//  Copyright © 2018年 xinghaiwulian. All rights reserved.
//

import UIKit
import WebKit

class InviteRecordWebVC: UIViewController,WKNavigationDelegate ,WKScriptMessageHandler  {
    var recordUrl:String!
    var userName:String!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "访客邀请记录"
        let url = NSURL(string: recordUrl)
        /// 根据URL创建请求
        let requst = NSURLRequest(url: url! as URL)
        /// 设置代理
        webView.navigationDelegate = self
        /// WKWebView加载请求
        webView.load(requst as URLRequest)
    }
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
