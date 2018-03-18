//
//  XHWLScanVC.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/9/1.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import swiftScan

@objc protocol XHWLScanVCDelegate:NSObjectProtocol {
    
    @objc optional func returnResultString(strResult:String, block:((_ isSuccess:Bool)->Void));
}


class XHWLScanVC: LBXScanViewController {

//    var zoomView: LBXScanVideoZoomView!
    weak var scanDelegate:XHWLScanVCDelegate?
    
    
    var topTitle:UILabel?    // 扫码区域上方提示文字

    /**
     @brief  闪关灯开启状态
     */
    var isOpenedFlash:Bool = false
    
    var bottomItemsView:UIView? //底部显示的功能项
    var btnPhoto:UIButton = UIButton() //相册
    var btnFlash:UIButton = UIButton() //闪光灯
    var btnMyQR:UIButton = UIButton() //我的二维码
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "扫描"
        self.view.backgroundColor = UIColor.black
//        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
//            [self setEdgesForExtendedLayout:UIRectEdgeNone];
//        }
        
        // 相册
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(openPhotoAlbum))
      
        //需要识别后的图像
        setNeedCodeImage(needCodeImg: true)
        
        //框向上移动10个像素
        scanStyle?.centerUpOffset -= 40
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.drawBottomItems()
//        self.drawTitle()
//        self.view.bringSubview(toFront: topTitle!)
    }

    func drawBottomItems() {
        if (bottomItemsView != nil) {
            return
        }
        
        bottomItemsView = UIView(frame: CGRect(x:0, y:self.view.frame.maxY-164, width:self.view.frame.size.width, height:100))
        bottomItemsView?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(bottomItemsView!)
        
        // 开灯
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x:0, y:0, width:65, height:87)
        btnFlash.center = CGPoint(x:(bottomItemsView?.frame.size.width)!/2, y:(bottomItemsView?.frame.size.height)!/2)
        btnFlash.setImage(UIImage(named:"CodeScan.bundle/qrcode_scan_btn_flash_nor"), for: UIControlState.normal)
        btnFlash.addTarget(self, action: #selector(openOrCloseFlash), for: UIControlEvents.touchUpInside)
        bottomItemsView?.addSubview(btnFlash)
    }
    
    // 绘制扫描区域
    func drawTitle() {
        if topTitle == nil {
            self.topTitle = UILabel()
            topTitle?.bounds = CGRect(x:0, y:0, width:145, height:60)
            topTitle?.center = CGPoint(x:self.view.frame.size.width/2, y:50)
            
            //3.5inch iphone
            if UIScreen.main.bounds.size.height <= 568 {
                topTitle?.center = CGPoint(x:self.view.frame.size.width/2, y:38);
                topTitle?.font = font_14
            }
            
            //iphone X
            if UIScreen.main.bounds.size.height == 812.0 {
                topTitle?.center = CGPoint(x:self.view.frame.size.width/2, y:80);
                topTitle?.font = font_14
            }
            
            topTitle?.textAlignment = NSTextAlignment.center
            topTitle?.numberOfLines = 0
            topTitle?.text = "将取景框对准二维码即可自动扫描"
            topTitle?.textColor = UIColor.white
            self.view.addSubview(topTitle!)
        }
    }
    
    

    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        if arrayResult.count < 1 {
            popAlertMsgWithScanResult(strResult: "")
            return;
        }
        
        for result:LBXScanResult in arrayResult
        {
            if let str = result.strScanned {
                str.ext_debugPrintAndHint()
            }
        }
        
        
        let result:LBXScanResult = arrayResult[0]
        
        let strResult:String  = result.strScanned!
//        scanImage = result.imgScanned
        if strResult.compare("").rawValue != 0 {

//            LBXScanWrapper.
//            [LBXScanWrapper systemVibrate];//震动提醒
//            [LBXScanWrapper systemSound];//声音提醒
//            if self.scanDelegate?.responds(to: #selector(returnResultString)) {
                self.scanDelegate?.returnResultString!(strResult: strResult, block: { (isSuccess) in
                    if (!isSuccess) {
                        AlertMessage.showOneAlertMessage(vc: self, alertMessage: "请重新扫描", block: {
                            self.startScan() // 点击完，继续扫码
                        })
                    }
                })
//            }
        
        } else {
            
            popAlertMsgWithScanResult(strResult: "")
        }
    }
    
    func popAlertMsgWithScanResult(strResult:String) {
        
        AlertMessage.showOneAlertMessage(vc: self, alertMessage: "识别失败 \n 请扫描用户、群组二维码", block: {
            self.startScan() // 点击完，继续扫码
        })
    }
    
    func showError(str:String)  {
        
        AlertMessage.showOneAlertMessage(vc: self, alertMessage: "\(str)", block: {
            let url:URL = URL.init(string: UIApplicationOpenSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                let url:URL = URL.init(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.openURL(url)
            }
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    

//    #pragma mark -底部功能项
    
    // 开关闪光灯
    func openOrCloseFlash() {
        
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControlState.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControlState.normal)
        }
    }
    
//    #pragma mark -底部功能项
    func myQRCode() {
        // 显示二维码
    }
}
