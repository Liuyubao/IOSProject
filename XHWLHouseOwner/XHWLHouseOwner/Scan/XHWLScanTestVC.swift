//
//  XHWLScanTestVC.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/9/1.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import swiftScan

@objc protocol XHWLScanTestVCDelegate:NSObjectProtocol {
    @objc optional func returnResultString(strResult:String, block:((_ isSuccess:Bool)->Void));
}

class XHWLScanTestVC: UIViewController , XHWLScanVCDelegate, XHWLNetworkDelegate{

    weak var delegate:XHWLScanTestVCDelegate?
    var bgImg:UIImageView!
    var vc: XHWLScanVC!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanAlbumBtnClicked(_ sender: UIButton) {
        vc.openPhotoAlbum()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.navigationBar.isHidden = false
//        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
//        bgImg = UIImageView()
//        bgImg.frame = self.view.bounds
//        bgImg.image = UIImage(named:"Space_SpaceBg")
//        self.view.addSubview(bgImg)
        
//        let img:UIImage = UIImage(named:"scan_title")!
//        let titleImg: UIImageView = UIImageView.init(image: img)
//        titleImg.image = img
//        self.navigationItem.titleView = titleImg
        
//        self.title = "扫一扫"
        
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"scan_back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onBack))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"scan_photo"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onSelectPicture))
//    
        setupView()
    }
    
//    func onBack(){
////        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func onSelectPicture() {
        vc.openPhotoAlbum()
    }
    
    func setupView() {
        
        //设置扫码区域参数设置
        var style : LBXScanViewStyle = LBXScanViewStyle()
        style.centerUpOffset = 44 // 矩形区域中心上移，默认中心点为屏幕中心点
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner //扫码框周围4个角的类型,设置为外挂式
        style.photoframeLineW = 3      // 扫码框周围4个角绘制的线条宽度
        style.photoframeAngleW = 19   // 扫码框周围4个角的宽度
        style.photoframeAngleH = 19   //扫码框周围4个角的高度
        style.colorAngle = UIColor.white
        style.colorRetangleLine = UIColor.clear
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove //扫码框内 动画类型 --线条上下移动
        style.animationImage = UIImage(named:"Scan_light")  //线条上下移动图片
        
        //SubLBXScanViewController继承自LBXScanViewController
        //添加一些扫码或相册结果处理
        vc = XHWLScanVC()
        vc.scanStyle = style
        vc.scanDelegate = self
        vc.view.frame = CGRect(x:0, y:80, width:Screen_width, height:Screen_height-80)
        self.view.addSubview(vc.view)
        self.addChildViewController(vc)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var isDevice: Bool = true
    
    /**
     *  扫描代理的回调函数
     *
     *  @param strResult 返回的字符串
     */
    
    func returnResultString(strResult:String, block:((_ isSuccess:Bool)->Void))
    {
        print("@@@@@@@@@@@@@\(strResult)")
//        self.delegate?.returnResultString!(strResult: strResult, block: block)
        
        
        let dict:NSDictionary = strResult.dictionaryWithJSON()
        if dict.count <= 0{
            block(false)
            return
        }
        let utid:String = dict["utid"] as! String
        
        if utid.compare("XHWL").rawValue == 0 {
            block(true)
            
            //从沙盒中取出user的信息,从而得到token
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            
            let params = ["token":userModel?.sysAccount.token, "code":strResult.dictionaryWithJSON()["code"], "type":strResult.dictionaryWithJSON()["type"]]
            //判断设备还是绿植
            if strResult.dictionaryWithJSON()["type"] as! String == "equipment"{
                self.isDevice = true
            }else{
                self.isDevice = false
            }
            XHWLNetwork.shared.postScanResult(params as NSDictionary, self)
            
            
        } else {
            block(false)
        }
        
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_SCAN.rawValue:
            onScanResult(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    func onScanResult(_ response:[String : AnyObject]){
        if response["state"] as! Bool == true{
            print("扫描成功")
            let scanResultVC = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanResultVC") as! XHWLScanResultVC
            scanResultVC.modalTransitionStyle = .crossDissolve
            self.present(scanResultVC, animated: true, completion: nil)
            //对scanResultVc的各个label进行赋值
            if self.isDevice{
                scanResultVC.resultImg.image = UIImage(named: "scan_showDevice")
            }else{
                scanResultVC.resultImg.image = UIImage(named: "scan_showTree")
            }
            let result = response["result"] as! NSDictionary
            scanResultVC.name.text = result["name"] as! String
            scanResultVC.codeInfo.text = result["code"] as! String
            let sysProject = result["sysProject"] as! NSDictionary
            scanResultVC.deviceAddress.text = sysProject["name"] as! String
        }
        
        
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
