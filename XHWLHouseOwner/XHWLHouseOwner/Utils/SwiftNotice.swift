//
//  SwiftNotice.swift
//  SwiftNotice
//
//  Created by JohnLui on 15/4/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation
import UIKit

let SCREEN_SIZE = UIScreen.main.bounds.size

extension UIColor {//主题色
    
    class func RGB(_ r:CGFloat, g: CGFloat, b: CGFloat)->UIColor{
        return UIColor(red: r/255 , green: g/255, blue: b/255, alpha: 1)
    }
    
    class func RGBA(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)->UIColor{
        return UIColor(red: r/255 , green: g/255, blue: b/255, alpha: a)
    }
}


extension UIViewController {

    func noticeSuccess(_ text: String, autoClear: Bool = true, autoClearTime: Int = 2) {
        SwiftNotice.showNoticeWithText(NoticeType.success, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
    }
    func noticeError(_ text: String, autoClear: Bool = true, autoClearTime: Int = 2) {
        SwiftNotice.showNoticeWithText(NoticeType.error, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
    }
    func noticeInfo(_ text: String, autoClear: Bool = true, autoClearTime: Int = 2) {
        SwiftNotice.showNoticeWithText(NoticeType.info, text: text, autoClear: autoClear, autoClearTime: autoClearTime)
    }
    func pleaseWait(_ autoClearTime: Int = 15) {
        SwiftNotice.wait(nil,autoClearTime: autoClearTime)
    }
    func pleaseWaitWithMsg(_ msg: String, autoClearTime: Int = 15) {
        SwiftNotice.wait(msg,autoClearTime: autoClearTime)
    }
    func clearAllNotice() {
        SwiftNotice.clear()
    }
    
}

enum NoticeType{
    case success
    case error
    case info
}

class SwiftNotice: NSObject {
    
    static var s_window:UIWindow? = nil
    static let mainWindow = UIApplication.shared.keyWindow?.subviews.first as UIView!
    static let rate:CGFloat = 0.5
    static let background = UIColor.RGBA(0, g: 0, b: 0, a: 0.8)
    static var isWaiting: Bool = false
    
    static let degree: Double = [0, 0, 180, 270, 90][UIApplication.shared.statusBarOrientation.hashValue] as Double
    static var center: CGPoint {
        get {
            var array = [UIScreen.main.bounds.width, UIScreen.main.bounds.height]
            array = array.sorted(by: <)
            let screenWidth = array[0]
            let screenHeight = array[1]
            let x = [0, screenWidth/2, screenWidth/2, 10, screenWidth-10][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
            let y = [0, 10, screenHeight-10, screenHeight/2, screenHeight/2][UIApplication.shared.statusBarOrientation.hashValue] as CGFloat
            return CGPoint(x: x, y: y)
        }
    }
    
    static func clear() {
        self.cancelPreviousPerformRequests(withTarget: self)
        if s_window != nil {
            var _window = s_window
            s_window = nil
            UIView.animate(withDuration: 0.2, animations: { 
                _window?.alpha = 0
            }, completion: { (flag) in
                _window = nil
            })
        }
        isWaiting = false
        s_window = nil
        mainWindow?.isUserInteractionEnabled = true
    }
    
    static func clearNow(){
        mainWindow?.isUserInteractionEnabled = true
        self.cancelPreviousPerformRequests(withTarget: self)
        s_window = nil
    }
    
    static func wait(_ msg: String?, autoClearTime: Int = 15) {
        if isWaiting {
            self.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(SwiftNotice.clear), with: s_window, afterDelay: TimeInterval(autoClearTime))
            return
        }
        clearNow()
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
        mainView.backgroundColor = background

        let actWidth: CGFloat = 36
        var width: CGFloat = 78
        var height: CGFloat = 78
        
        var margin_v: CGFloat = 21
        let margin_h: CGFloat = 21
        
        if msg != nil {
            let labMsg = UILabel()
            labMsg.text = msg
            labMsg.font = UIFont.systemFont(ofSize: 14)
            labMsg.textColor = UIColor.white
            labMsg.textAlignment = .center
            
            let _size = labMsg.sizeThatFits(CGSize(width: SCREEN_SIZE.width - 60, height: SCREEN_SIZE.height))
            if width < _size.width + margin_h * 2 {
                width = _size.width + margin_h * 2
            }
            height = actWidth + _size.height + margin_v + 12
            
            margin_v = (height - _size.height - 30)/2
            
            labMsg.frame = CGRect(x: 0, y: actWidth + margin_v + 4, width: width, height: _size.height)
            
            mainView.addSubview(labMsg)
        }
        
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        ai.frame = CGRect(x: (width - actWidth)/2, y: margin_v, width: actWidth, height: actWidth)
        ai.startAnimating()
        mainView.addSubview(ai)

        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        window.isHidden = false
        window.frame = frame
        window.center = getRealCenter()
        window.windowLevel = UIWindowLevelAlert
        window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * M_PI / 180))
        window.addSubview(mainView)
        
        mainView.frame = frame
        
        mainView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
            mainView.alpha = 1
        })
        
        s_window = window
        mainWindow?.isUserInteractionEnabled = false

        isWaiting = true
        self.perform(#selector(SwiftNotice.clear), with: window, afterDelay: TimeInterval(autoClearTime))
    }
    
    static func showText(_ text: String, autoClear: Bool = true, autoClearTime: Int = 2) {
        clearNow()
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let mainView = UIView()
        mainView.layer.cornerRadius = 8
        mainView.backgroundColor = background
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.sizeToFit()
        mainView.addSubview(label)
        
        let superFrame = CGRect(x: 0, y: 0, width: label.frame.width + 50 , height: label.frame.height + 30)
        window.frame = superFrame
        window.isHidden = false
        window.windowLevel = UIWindowLevelAlert
        window.center = getRealCenter()
        window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * M_PI / 180))
        window.addSubview(mainView)
        
        mainView.frame = superFrame
        label.center = mainView.center
        
        mainView.transform =  CGAffineTransform(scaleX: rate, y: rate)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
            mainView.transform = CGAffineTransform.identity
        })
        
        s_window = window
        
        if autoClear {
            self.perform(#selector(SwiftNotice.clear), with: window, afterDelay: TimeInterval(autoClearTime))
        }
    }
    
    static func showNoticeWithText(_ type: NoticeType, text: String, autoClear: Bool = true, autoClearTime: Int = 2) {
        clearNow()
        
        var frame = CGRect(x: 0, y: 0, width: 90, height: 72)
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        let mainView = UIView()
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = background
        
        var image = UIImage()
        switch type {
        case .success:
            image = SwiftNoticeSDK.imageOfCheckmark
        case .error:
            image = SwiftNoticeSDK.imageOfCross
        case .info:
            image = SwiftNoticeSDK.imageOfInfo
        }
        
        let checkmarkView = UIImageView(image: image)
        checkmarkView.frame = CGRect(x: 27, y: 16, width: 36, height: 36)
        mainView.addSubview(checkmarkView)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        let tempSize = CGSize(width: SCREEN_SIZE.width - 64, height: CGFloat.greatestFiniteMagnitude)
        let _size = label.sizeThatFits(tempSize)
        
        if (_size.width + 32) > frame.width {
            frame = CGRect(x: 0, y: 0, width: _size.width + 32, height: frame.height + _size.height)
        }else{
            frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height + _size.height)
        }
        label.frame = CGRect(x: 16, y: 60, width: frame.width - 32, height: _size.height)
        mainView.addSubview(label)
        
        checkmarkView.frame = CGRect(x: (frame.width - checkmarkView.frame.width)/2, y: checkmarkView.frame.minY, width: 36, height: 36)
        window.frame = frame
        window.isHidden = false
        window.windowLevel = UIWindowLevelAlert
        window.center = getRealCenter()
        window.transform = CGAffineTransform(rotationAngle: CGFloat(degree * M_PI / 180))
        window.addSubview(mainView)
        
        mainView.frame = frame
        
        mainView.transform =  CGAffineTransform(scaleX: rate, y: rate)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: {
            mainView.transform = CGAffineTransform.identity
        })
        
        s_window = window
        
        if autoClear {
            self.perform(#selector(SwiftNotice.clear), with: window, afterDelay: TimeInterval(autoClearTime))
        }
    }

    static func getRealCenter() -> CGPoint {
        if UIApplication.shared.statusBarOrientation.hashValue >= 3 {
            return CGPoint(x: mainWindow!.center.y, y: mainWindow!.center.x)
        } else {
            return mainWindow!.center
        }
    }
}

class SwiftNoticeSDK {
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var imageOfCross: UIImage?
        static var imageOfInfo: UIImage?
    }
    class func draw(_ type: NoticeType) {
        let color = UIColor.white
        
        let checkmarkShapePath = UIBezierPath()
        
        // draw circle
        checkmarkShapePath.move(to: CGPoint(x: 36, y: 18))
        checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 18), radius: 17.5, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        checkmarkShapePath.close()
        
        switch type {
        case .success: // draw checkmark
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.addLine(to: CGPoint(x: 16, y: 24))
            checkmarkShapePath.addLine(to: CGPoint(x: 27, y: 13))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 18))
            checkmarkShapePath.close()
        case .error: // draw X
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 26))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 26))
            checkmarkShapePath.addLine(to: CGPoint(x: 26, y: 10))
            checkmarkShapePath.move(to: CGPoint(x: 10, y: 10))
            checkmarkShapePath.close()
        case .info:
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.addLine(to: CGPoint(x: 18, y: 22))
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 6))
            checkmarkShapePath.close()
            
            color.setStroke()
            checkmarkShapePath.stroke()
            
            let checkmarkShapePath = UIBezierPath()
            checkmarkShapePath.move(to: CGPoint(x: 18, y: 27))
            checkmarkShapePath.addArc(withCenter: CGPoint(x: 18, y: 27), radius: 1, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
            checkmarkShapePath.close()
            
            color.setFill()
            checkmarkShapePath.fill()
        }
        
        color.setStroke()
        checkmarkShapePath.stroke()
    }
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.success)
        
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.error)
        
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 36, height: 36), false, 0)
        
        SwiftNoticeSDK.draw(NoticeType.info)
        
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
}

