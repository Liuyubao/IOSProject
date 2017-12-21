//
//  ProduceQRCodeVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/12.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit


class ProduceQRCodeVC: UIViewController {
    @IBOutlet weak var visitorInfo: UILabel!
    @IBOutlet weak var hosterInfo: UILabel!
    @IBOutlet weak var validFrom: UILabel!
    @IBOutlet weak var validTo: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var shareChoicesView: UIView!
    
    
    /**
     生成高清二维码
     
     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // 1.创建bitmap;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale);
        //        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        bitmapRef.draw(bitmapImage, in: extent)
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }
    
    
    
    @IBAction func qqShareBtnClicked(_ sender: UIButton) {
        //        1.创建一个滤镜
        let filter = CIFilter(name:"CIQRCodeGenerator")
        //        2.将滤镜恢复到默认状态
        filter?.setDefaults()
        //        3.为滤镜添加属性    （"函冰"即为二维码扫描出来的内容，可以根据需求进行添加）
        filter?.setValue("柳玉豹".data(using: String.Encoding.utf8), forKey: "InputMessage")
        //        判断是否有图片
        guard let ciimage = filter?.outputImage else {
            return
        }
        //        4。将二维码赋给imageview,此时调用网上找的代码片段，由于SWift3的变化，将其稍微改动，生成清晰的二维码
        let qrImg = createNonInterpolatedUIImageFormCIImage(image: ciimage, size: 200)
        
        //不带图片的二维码图片
        let data = UIImageJPEGRepresentation(qrImg, 0.8)
        // 预览图 最大 1M
        let thumb = UIImage(named: "PersonPath_qq")
        let thData = UIImagePNGRepresentation(thumb!)
        
        let imgObj = QQApiImageObject(data: data, previewImageData: thData, title: "分享的一张图片", description: "分享图片的描述")
        
        let req = SendMessageToQQReq(content: imgObj)
        // 分享到QQ
        QQApiInterface.send(req)
        // 分享到Qzone
        //        QQApiInterface.sendReq(toQZone: req)
    }
    
    @IBAction func wechatShareBtnClicked(_ sender: UIButton) {
        let qrMsg = WXMediaMessage()
        qrMsg.setThumbImage(UIImage(named: "AppIcon"))
        let imgObject = WXImageObject()
        imgObject.imageData = UIImagePNGRepresentation(qrImage.image!)
        qrMsg.mediaObject = imgObject
        
        let req = SendMessageToWXReq()
        req.text = "分享的内容"
        req.message = qrMsg
        req.bText = false
        req.scene = Int32(WXSceneSession.rawValue)
        WXApi.send(req)
        
    }
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationTransition(.none, for: self.shareChoicesView!, cache: true)//registerView翻转
        self.shareChoicesView.alpha = 0
        self.inviteView.alpha = 1
        
        self.view.bringSubview(toFront: self.inviteView)
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
    }
    
    @IBAction func shareBtnClicked(_ sender: UIButton) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationTransition(.none, for: self.inviteView!, cache: true)//registerView翻转
        self.inviteView.alpha = 0
        self.shareChoicesView.alpha = 1
        
        self.view.bringSubview(toFront: self.shareChoicesView)
        
        UIView.setAnimationDelegate(self)
        UIView.commitAnimations()
//        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
