//
//  XHMLProgressHUD.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/9/5.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit

class XHMLProgressHUD { // : UIView
    private let restorationIdentifier = "NVActivityIndicatorViewContainer"
    private enum State {
        case waitingToShow
        case showed
        case waitingToHide
        case hidden
    }
    
//    var indicatorView:HLBarIndicatorView!
    var imageIV:UIImageView!
    
//    class var shared: XHMLProgressHUD {
//        struct Static {
//            static let instance = XHMLProgressHUD()
//        }
//        return Static.instance
//    }
    public static let shared = XHMLProgressHUD()
    
    private init() {}
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//    }
    
    func setupView() {
        
        let bgView:UIView = UIView()
        bgView.frame = UIScreen.main.bounds
        bgView.restorationIdentifier = restorationIdentifier
        bgView.backgroundColor = UIColor.clear // UIColor.black.withAlphaComponent(0.5)
        
        //        indicatorView = HLBarIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        //        indicatorView.center = CGPoint(x:self.frame.size.width/2.0, y:self.frame.size.height/2.0)
        //        indicatorView.indicatorType = .barScaleFromRight
        //        self.addSubview(indicatorView)
        
        imageIV = UIImageView(frame: CGRect(x: 0, y: 0, width: 375, height: 139))
        imageIV.center = CGPoint(x:Screen_width/2.0, y:Screen_height/2.0)
        let array:NSMutableArray = NSMutableArray()
        for i in 0..<61 {
            let str = String.init(format: "别人进行云对讲%04d", arguments:[i])
            //            let path:String = Bundle.main.path(forResource:str , ofType: "png")!
            //            print("\(path)")
            //            let image:UIImage = UIImage.init(contentsOfFile: path)!
            let image:UIImage = UIImage(named: str)!
            array.add(image)
        }
        imageIV.animationImages = array as? [UIImage]
        
        imageIV.animationDuration = 1.0
        imageIV.startAnimating()
        bgView.addSubview(imageIV)

        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(bgView)
    }
    
    //    别人进行云对讲0000
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
//        imageIV.isHidden = false
//        self.isHidden = false
//        if imageIV.isAnimating {
//            imageIV.startAnimating()
//        }
  
        setupView()
//        let window = UIApplication.shared.keyWindow!
//        window.bringSubview(toFront: self)
//        self.indicatorView.startAnimating()

    }

//    func hide() {
//        //        self.indicatorView.pauseAnimating()
//        //        imageIV.isHidden = true
//        if imageIV.isAnimating {
//            imageIV.stopAnimating()
//        }
//        self.isHidden = true
//        
//
//        
//        let window = UIApplication.shared.keyWindow!
////        window.sendSubview(toBack: self)
//        self.removeFromSuperview()
//    }
    
    func hide() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        for item in keyWindow.subviews
            where item.restorationIdentifier == restorationIdentifier {
                item.removeFromSuperview()
        }
//        state = .hidden
    }
}
