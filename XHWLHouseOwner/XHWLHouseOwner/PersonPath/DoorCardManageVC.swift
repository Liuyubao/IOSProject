//
//  DoorCardManageVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2018/1/31.
//  Copyright © 2018年 xinghaiwulian. All rights reserved.
//

import UIKit
import WebKit

class DoorCardManageVC: UIViewController,WKNavigationDelegate,WKScriptMessageHandler {
    var loadUrl:String = "http://202.105.96.131:3002/sendCard/#/management/?"
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
        let urlString =  "\(loadUrl)?projectCode=\(projectCode)&userName=\(encodeUrlStr)&granterPhone=\(phone)"
        let url = URL(string: urlString)
//        loadUrl = "\(loadUrl)projectCode=\(projectCode)&userName=\(encodeUrlStr)&granterPhone=\(phone)"
        
        self.title = "门卡管理"
        /// 根据URL创建请求
        let requst = NSURLRequest(url: url! as URL)
        /// 设置代理
        webView.navigationDelegate = self
        /// WKWebView加载请求
        webView.load(requst as URLRequest)
        
        let moreBtn = UIButton()
        moreBtn.setTitle("更多", for: .normal)
        moreBtn.tintColor = UIColor.black
        moreBtn.frame = CGRect(x:10,y:20,width:80,height:60)
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
//        moreBtn.setImage(UIImage(named:"PersonPath_more"), for: .normal)
        moreBtn.addTarget(self, action:#selector(moreClick), for:.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: moreBtn)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backToPre))
        //            UIBarButtonItem.WSH_BarButtonItemWithImage(UIImage(named:"nav_back")!, UIImage(named:"nav_back")!, self, #selector(backToPre), .touchUpInside)
    }
    
    func btnAction(_ button:UIButton) {
        if (button.tag == 0) {      //授权门卡
//            self.moreImageV.isHidden = true
//            let authorizationVC = AuthorizationEntranceVC()
//            authorizationVC.userName = self.userName;
//            authorizationVC.phoneNum = self.phoneNum
//            authorizationVC.projectCode = self.projectCode
//            self.navigationController?.pushViewController(authorizationVC, animated: true)
        }
    }
    func moreClick() {
//        self.moreImageV.isHidden = !self.moreImageV.isHidden
    }
    
    func backToPre() {
        if self.webView.canGoBack{
            self.webView.goBack()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case "passValue":
            //            self.presentShareInterface(message.body as! String)
            break
        default:
            
            break
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
