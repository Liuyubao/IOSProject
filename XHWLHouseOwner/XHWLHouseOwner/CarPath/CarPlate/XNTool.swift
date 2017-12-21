//
//  XNTool.swift
//  MyNeteaseNews
//
//  Created by codeIsMyGirl on 16/4/27.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//

import UIKit

// MARK: 数据

class XNTool: NSObject {

    // MARK: 属性
    
    // ------------  属性  ---------------
  

    
    
    // ---------------  URL ----------------

    
    //  ---------------  其他 ----------------

}

/*

/// ----------------    数据存储     -----------------
// MARK:
// MARK: 数据存储
extension XNTool {
    // MARK:
    // MARK: 1. NSCoding/归档&解档
    
    // MARK:
    // MARK: 存数据
    /// NSCoding 存数据
    
    class func codingSaveData(modelData: XNModelData) {
        
        // 获取Documents文件夹路径 并创建文件存储
        let docPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("myModelData.data");
        
        // 保存自定义对象
        NSKeyedArchiver.archiveRootObject(modelData, toFile: docPath);
        
        //print("数据已保存");
        
        
        
        
    }
    // MARK:
    // MARK: 读取数据
    
    /// NSCoding 读取数据
    class func codingLoadData() -> XNModelData? {
        
        // 从磁盘中读取数据
        let docPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("myModelData.data")
        
        
        let modelData =  (NSKeyedUnarchiver.unarchiveObjectWithFile(docPath) as? XNModelData);
        
        //print("数据已取出");
        
        return modelData;
    }
    
    // MARK:
    // MARK: 2. plist 存取偏好设置
    
    // MARK:
    // MARK: 保存数据
    /// plist 保存数据
    class func plistSaveData(senderArray: NSArray) {
        
        //保存开关状态和用户信息
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        // 保存属性 对象 key名
        userDefaults.setObject(senderArray, forKey: "senderArray");
 
        // 判断 是否有数据 的参数
        userDefaults.setBool(true, forKey: "isHaveData");
        
        // 立即写入 Ios8之前必须调用
        userDefaults.synchronize();
        
        //print("数据已经保存到plist");
        
    }
    
    // MARK:
    // MARK: 类方法 读取
    /// plist 获取数据
    class func plistLoadData(inout senderArray: NSArray) {
        
        // 读取数据
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        let isHaveData = userDefaults.boolForKey("isHaveData");
        
        // 判断 有无数据
        if isHaveData != true {
            
            // 如果没有数据 就给初始 数据
   
            
            return;
        }
        
        senderArray = userDefaults.objectForKey("senderArray") as! NSArray;

        //print("数据已从plist取出");
 
    }

}
 


/// ----------------    字符串     -----------------

// MARK:
// MARK:String 扩展方法

extension XNTool {
    
    // MARK:
    // MARK: 添加车辆的判断
    /// 添加车辆的判断
    class func xnStringCheckForAddCar(carNumber: String, colorString: String?,carNameLength: NSInteger) -> Bool {
        
        /// 中国34个省级行政区
        let arrayProvincialAdministrativeRegion = [
            
            "京",
            "沪",
            "津",
            "渝",
            "黑",
            "吉",
            "辽",
            "蒙",
            "冀",
            "新",
            "甘",
            "青",
            "陕",
            "宁",
            "豫",
            "鲁",
            "晋",
            "皖",
            "鄂",
            "湘",
            "苏",
            "川",
            "贵", //贵州省
            "黔", //贵州省
            "滇",
            "桂",
            "藏",
            "浙",
            "赣",
            "粤",
            "闽",
            "台",
            "琼",
            "港",
            
            ];
      
//        if carNumber.characters.count <= 0 {
//            
//            return false;
//        }
//        
//        let headerString = carNumber[0..<1];
//        
//        var tempBool = false;
//        
//        for i in arrayProvincialAdministrativeRegion {
//            
//            if i == headerString {
//                
//                 tempBool = true;
//            }
//        }
//        
//        if tempBool == false {
//            
//            // 出现 屏幕中间 时间自己定
//            JRToast.showWithText("您的车牌号第一个汉字不对", duration:XNTool().messageContinueTime);
//            
//            return false;
//        }
//
        if carNumber.characters.count == 0 {
            
            return false;
        }
        
        // 判断车牌号是否合法
//        if NSString.xnStringCarNumber(carNumber) == false {
//            
//            // 出现 屏幕中间 时间自己定
//            JRToast.showWithText("您的车牌号不符合标准", duration:XNTool().messageContinueTime);
//            
//            return false;
//        }
        
        // 判断
        if colorString == nil {
            
            // 出现 屏幕中间 时间自己定
            JRToast.showWithText("请选择您爱车颜色", duration:XNTool().messageContinueTime);
            
            return false;
        }
        
        if carNameLength <= 0 {
            
            // 出现 屏幕中间 时间自己定
            JRToast.showWithText("请为您的爱车起个小名", duration:XNTool().messageContinueTime);
            
            return false;
        }
        
        return true;
    }
    
    // MARK:
    // MARK:  判断字符串是否是手机号
    
    /// 判断字符串是否是手机号
    
    class func stringIsPhoneString(phoneString :String) -> Bool {
        
        // 获取字符串内容长度
        let phoneLength = phoneString.characters.count;
        
        if phoneLength == 0 {
            
            // 出现 屏幕中间
            JRToast.showWithText("您还没输入手机号呢", duration:XNTool().messageContinueTime);
            
            return false;
        }
        
        if phoneLength != 11 {
            
            // 出现 屏幕中间
            JRToast.showWithText("您输入的手机号长度不对哦", duration:XNTool().messageContinueTime);
            
            return false;
        }
        
        // 走到这里说明输入的是11 位
        let number = phoneString.isPhoneNumberCheck();
        
        // 进入说明输入手机号格式不对
        if number == MHMobileNubmerType.NONE {
            
            // 出现 屏幕中间
            JRToast.showWithText("您输入的手机号不存在", duration:XNTool().messageContinueTime);
            
            return false;
        }
        
        return true;
    }
    
 
 
    // MARK:
    // MARK: 字符串转换成类名
    /// 字符串转换成类
    class func stringClassFromString(className: String) -> AnyClass! {
        
        /// 获取命名空间
        let namespace = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as! String;
        
        /// 根据命名空间传来的字符串先转换成anyClass
        let cls: AnyClass = NSClassFromString(namespace + "." + className)!;
        
        // 在这里已经可以return了   返回类型:AnyClass!
        return cls;
    }
}
 
  */

/// ----------------    数组     -----------------
// MARK:
// MARK: array 扩展方法

extension XNTool {
    
    
    // MARK: 删除数组中 数组个数个元素
    
    /// 删除数组中 数组个数个元素
    class func arrayRemoveObjectAtIndexArray(_ arrayM: inout NSMutableArray,indexArray: [Int]) {
        
        // 修复报错 请求请见 http://my.oschina.net/codeismygirl/blog/675086
        
        arrayM =  NSMutableArray(array: arrayM);
        
        var indexA = indexArray;
        
        // 把数组里面的 元素 从小到大排序 并 递归 --> 减
        for  i in 0..<indexA.count {
            
            for j in 0..<indexA.count - i - 1 {
                
                if indexA[j] > indexA[j + 1] {
                    
                    let temp = indexA[j + 1];
                    
                    indexA[j + 1] = indexA[j];
                    
                    indexA[j] = temp;
                }
            }
        }
        
        // 每次删一个 数组长度减一 so
        for i in 0..<indexA.count {
            
            indexA[i] = indexA[i] - i;
            
            // 删除 对应 下标元素
            arrayM.removeObject(at: indexA[i]);
            
        }
        
    }
    
}

// MARK:
// MARK: image
extension XNTool {
    
    // MARK: 把view转化成image
    
    /// 把view转化成image
    class func imageFromView(_ theView: UIView) -> (UIImage) {
        
        UIGraphicsBeginImageContext(theView.frame.size);
        
        let context = UIGraphicsGetCurrentContext();
        
        theView.layer.render(in: context!);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
}

/// ----------------    美化     -----------------
// MARK:
// MARK: 美化

extension XNTool {
    // MARK:
    // MARK: 切圆 描边
    /// 切圆 描边
    class func viewCutRadius(_ sender: UIView ,cornerRadius :CGFloat? ,borderWidth: CGFloat ,borderColor: UIColor?) {
        
        
        sender.layer.cornerRadius =
            cornerRadius == nil ?
                sender.layer.bounds.size.width * 0.5
            :cornerRadius!;
        
        // 确定切去的半径CGFloat
        
        // 多余切除
        sender.layer.masksToBounds = true;
        
        if borderWidth == 0 {
            
            return;
        }
        
        // 边框 宽度
        sender.layer.borderWidth = borderWidth;
        
        if borderColor == nil {
            
            // 边框 颜色
            sender.layer.borderColor  = UIColor.black.cgColor;
            
            return;
        }
        
        // 边框 颜色
        sender.layer.borderColor  = borderColor!.cgColor ;
        
    }
    
    // MARK:
    // MARK: 随机颜色
    /// 随机颜色
    class func colorRandomColor() -> UIColor {
        
        let r = CGFloat(Int(arc4random()%255)+1) / 255.0
        let g = CGFloat(Int(arc4random()%255)+1) / 255.0
        let b = CGFloat(Int(arc4random()%255)+1) / 255.0
        
        return  UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    // MARK:
    // MARK: 主题的 颜色
    /// 主题的 颜色
    class func colorThemeColor() -> UIColor {
        
        let r = CGFloat(0.408);
        
        let g = CGFloat(0.554);
        
        let b = CGFloat(1.000);
        
        //[UIColor colorWithRed:0.408 green:0.554 blue:1.000 alpha:1.000];
        
        return  UIColor.init(red: r, green: g, blue: b, alpha: 1);
    }
    
}

/// ----------------    动画     -----------------
// MARK:
// MARK: 动画

extension XNTool {
    // MARK:
    // AMRK: 开始旋转
    
     // 旋转动画 45°
     class func animationStartRotation(_ sender : UIButton,back: Bool) {
        
        // 动画时间内 关闭用户交互
        sender.isUserInteractionEnabled = false;
        
        // 创建 并 设置 修改的 参数
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z");
        
        if back {
            
            // 旋转角度
            rotationAnimation.toValue = M_PI * -0.005;
            
        }else {
            
            // 旋转角度
            rotationAnimation.toValue = M_PI * 0.25;
            
        }
        
        // 旋转持续时间
        rotationAnimation.duration = 0.25;
        
        // 执行 次数
        //rotationAnimation.repeatCount = 100;
        
        // 结束动画不回原处
        rotationAnimation.fillMode = kCAFillModeForwards;
        
        // 动画完成后 移除
        rotationAnimation.isRemovedOnCompletion = false;
        
        //对谁做动画 就添加动画
        sender.layer.add(rotationAnimation, forKey: nil);
        
        // 动画结束 打开用户交互
        let delay = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delay) {
            
            sender.isUserInteractionEnabled = true;
        }
    }
}






