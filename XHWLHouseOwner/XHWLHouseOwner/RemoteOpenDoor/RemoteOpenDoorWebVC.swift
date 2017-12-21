//
//  RemoteOpenDoorWebVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/12/18.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class RemoteOpenDoorWebVC: UIViewController {
    
    fileprivate let loadURL = "http://10.51.39.117:3001/openDoor/"
    // webView
    fileprivate lazy var webView:UIWebView = {
        let webView = UIWebView()
        webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        webView.isOpaque = false
        webView.scalesPageToFit = true
        webView.backgroundColor = UIColor.clear
        self.view.addSubview(webView)
        
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let image = UIImage(named:"Scan_back")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(self.onBack))
        self.title = "远程开门"

    }
    
    /*
     返回上一个页面
     */
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     * 远程开门
     *
     * @param telePhone 用户手机号
     * @param projectCode 项目编号
     * @param userName 用户名
     */
    func remoteOpenDoor(_ telePhone:String, _ projectCode:String, _ userName:String) {
        
        if telePhone.isEmpty {
            "手机号为空".ext_debugPrintAndHint()
            return
        }
        
        if projectCode.isEmpty {
            "项目编号为空".ext_debugPrintAndHint()
            return
        }
        
        if userName.isEmpty {
            "用户名为空".ext_debugPrintAndHint()
            return
        }
        
        // 加密参数
        let webToken = Date.currentDate("yyyy-MM-dd-HH") + "adminXH"
        let md5 = webToken.md5
        
        // 请求的URL
        let url:String = loadURL + telePhone + "/" + projectCode + "/" + md5 + "/" + userName //
        let utf8URL:String = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! // .addingPercentEscapes(using: String.Encoding.utf8)!
        print("webToken = \(webToken) \n utf8URL = \(utf8URL)")
        
        // 发起请求
        let requestURL = URL.init(string: utf8URL)!
        let request = URLRequest.init(url: requestURL)
        self.webView.loadRequest(request)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
