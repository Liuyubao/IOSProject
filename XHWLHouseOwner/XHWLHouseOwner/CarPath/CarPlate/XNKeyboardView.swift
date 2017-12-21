//
//  XNKeyboardView.swift
//  SwiftCustomKeyboard
//
//  Created by codeIsMyGirl on 16/6/22.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//

// 定义协议 协议名自己定
@objc protocol XNKeyboardViewDelegate: NSObjectProtocol {
    
    // 什么都不修饰默认必须实现,加上optional可选实现
    
    /// 返回按钮中的文本
    func XNKeyboardViewMethod(_ title: String);
    
    /// 点击了 删除
    func XNKeyboardViewDeleteMethod();
    
    /// 点击了对勾
    @objc optional func XNKeyboardViewRightMethod();
    
    
}

import UIKit

// 继承自UIButton 可以避免 点击控制器的根View响应关闭了键盘
class XNKeyboardView: UIButton {
    
    /**
     声明代理  代理 要使用 weak 属性关键字
     swift 属性默认都是strong  代理同样也需要使用weak
     */
    weak var xnKeyboardViewDelegate: XNKeyboardViewDelegate?
    
    /// 装有 数字和字母 的按钮View
    let keyboardViewToNumberAndGrapheme = UIView();
    
    /// 圆角弧度
    fileprivate let radian = CGFloat(8);
    
    /// 描边宽度
    fileprivate let borderWidth = CGFloat(0.5);
    
    /// 描边颜色
    fileprivate let colorToBorder = UIColor.init(white: 0.800, alpha: 1.000);
    
    //[UIColor colorWithWhite:0.800 alpha:1.000];
    
    /// 贵州省 有二个叫法
    // ------------  中国34个省级行政区  ------------
    
    // 最后一行 余下的7个
    fileprivate let xnThenArray = [
    
        "浙",
        "赣",
        "粤",
        "闽",
        "台",
        "琼",
        "港",
        ]

    // 前三行 每行9个 贵 黔
    fileprivate let xnArrayProvincialAdministrativeRegion = [
        
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
        
        
        ];
    
    // ------------  数字和字母键盘  ------------

    /// 第零一行
    fileprivate let xnOneRowArray = [
        
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "Q",
        "W",
        "E",
        "R",
        "T",
        "Y",
        "U",
        "I",
        "O",
        "P",
        
        
        ]
    
    /// 第二行
    fileprivate let xnTwoRowArray = [
    
        "A",
        "S",
        "D",
        "F",
        "G",
        "H",
        "J",
        "K",
        "L",
        
    
    ];
    
    /// 第三行
    fileprivate let xnThreeRowArray = [
        
        "Z",
        "X",
        "C",
        "V",
        "B",
        "N",
        "M",
        
        ];

    // MARK:
    // MARK: 加载内容
    /// 加载内容
     func xnKeyboardViewLoadContent() {
        
        backgroundColor = UIColor.init(red: 0.804, green: 0.812, blue: 0.831, alpha: 1.000);
        
        //[UIColor colorWithRed:0.804 green:0.812 blue:0.831 alpha:1.000];
        
        initButton();
        
        initButtonAgain();
        
        // 初始化
        initKeyboardViewToNumberAndGrapheme();
        
        // 隐藏数字和 字母键盘
        keyboardViewToNumberAndGrapheme.alpha = 0;
        
    }
    
    // MARK:
    // MARK: 创建 和 显示 数字和字母键盘内容
    /// 创建 和 显示 数字和字母键盘内容
    fileprivate func initKeyboardViewToNumberAndGrapheme() {
        
        keyboardViewToNumberAndGrapheme.frame = self.bounds;
        
        keyboardViewToNumberAndGrapheme.backgroundColor = UIColor.init(red: 0.804, green: 0.812, blue: 0.831, alpha: 1.000);
        
        addSubview(keyboardViewToNumberAndGrapheme);
        
        initButtonOne();
        
        initButtonTwo();
        
        initButtonThree();
    }
    
    /// 随机颜色 zweiExtension UIColor
    fileprivate func randomColor() -> UIColor {
        let r = CGFloat(Int(arc4random()%255)+1) / 255.0
        let g = CGFloat(Int(arc4random()%255)+1) / 255.0
        let b = CGFloat(Int(arc4random()%255)+1) / 255.0
        
        return  UIColor(red: r, green: g, blue: b, alpha: 1)
    }
  
}

// MARK:
// MARK: 按钮点击事件
extension XNKeyboardView {
    
    // MARK:
    // MARK: 点击了 按钮
    /// 点击了 按钮
    @objc fileprivate func clickButton(_ sender: UIButton) {
        
        let contentText = sender.titleLabel?.text;
 
        // 代理传值 提示控制器改修改数据了
        xnKeyboardViewDelegate?.XNKeyboardViewMethod(contentText ?? "");
        
        // 设置上了车牌之后显示出 数字和字母键盘
        keyboardViewToNumberAndGrapheme.alpha = 1;
 
    }
    
    // MARK:
    // MARK: 点击了 删除按钮
    /// 点击了 删除按钮
    @objc fileprivate func clickDeleteButton() {
        
        // 调用代理方法  让控制器删除
        xnKeyboardViewDelegate?.XNKeyboardViewDeleteMethod();
        
       
    }
    
    // MARK:
    // MARK: 点击了对勾
    /// 点击了对勾
    @objc fileprivate func clickRightButton() {
        
        // 调用代理方法
        xnKeyboardViewDelegate?.XNKeyboardViewRightMethod?();
    }
}

// MARK:
// MARK: 添加 数字 和字幕键盘 按钮
extension XNKeyboardView {
    
    // MARK:
    // MARK: 第3 行的 字母 最后一行
    /// 第3 行的 字母 最后一行
    fileprivate func initButtonThree() {
        
        /// 每行几个
        let countToLine = xnThreeRowArray.count;
        
        /// 每个 View 的宽
        let width = (self.width - 90) / CGFloat(countToLine);
        
        /// 每个View 的高 父类高除以4
        let height = CGFloat(self.height * 0.25);
        
        for i in 0..<xnThreeRowArray.count {
            
            /// 当前第几行 只有一行 所以不需要
            // let currentLine = i / countToLine;
            
            /// 当前行 第几个
            let currentLineNumber = i % countToLine;
            
            let buttonView = UIView();
            
            keyboardViewToNumberAndGrapheme.addSubview(buttonView);
            
            // 这里的 45 是上面95的 0.5
            let x = width * CGFloat(currentLineNumber) + 45;
            
            // 距离y距离 0  1 2 行一起的距离
            let y = height * 3;
            
            /*
             x 距离
             y 距离
             宽 和 高
             */
            
            buttonView.frame = CGRect(x: x, y: y, width: width, height: height);
            
            // MARK:
            // MARK: 第一个的时候 添加 对勾图片 (为了看起来对称所以加了个√  其实作用不大)
            if i == 0 {
                
                let rightButton = UIButton();
                
                keyboardViewToNumberAndGrapheme.addSubview(rightButton);
                
                let image = UIImage(named: "rightCarNumber");
                
                rightButton.setImage(image, for: UIControlState());
                
                rightButton.sd_layout()
                    .centerYIs(buttonView.centerY)?
                    .leftSpaceToView(keyboardViewToNumberAndGrapheme,5)?
                    .widthIs(40)?
                    .heightIs(buttonView.height - 10);
                
                rightButton.backgroundColor = UIColor.white;
                
                // 圆角 描边
                XNTool.viewCutRadius(rightButton, cornerRadius: radian, borderWidth: 1, borderColor: UIColor.red);
                
                //添加点击事件
                rightButton.addTarget(self, action: #selector(XNKeyboardView.clickRightButton), for: .touchUpInside);
                
            }
            // MARK:
            // MARK: 最后一个的时候 添加 删除图片
            if i == 6 {
                
                let deleteButton = UIButton();
                
                keyboardViewToNumberAndGrapheme.addSubview(deleteButton);
                
                let image = UIImage(named: "deleteCarNumber");
                
                deleteButton.setImage(image, for: UIControlState());
                
                deleteButton.sd_layout()
                .centerYIs(buttonView.centerY)?
                .rightSpaceToView(keyboardViewToNumberAndGrapheme,5)?
                .widthIs(40)?
                    .heightIs(buttonView.height - 10);
                
                deleteButton.backgroundColor = UIColor.white;
                
                //添加点击事件
                deleteButton.addTarget(self, action: #selector(XNKeyboardView.clickDeleteButton), for: .touchUpInside);
                
                // 圆角
                XNTool.viewCutRadius(deleteButton, cornerRadius: radian, borderWidth: 1, borderColor: UIColor.cyan);
                
                //[UIColor cyanColor];
            }
            
            //buttonView.backgroundColor = randomColor();
            
            /// ------------  添加 按钮  -----------
            
            // 背景色
            let backGroundColor = UIColor.white;
            
            // 文本
            let title = xnThreeRowArray[i];
            
            // 文本颜色
            let titleColor = UIColor.black;
            
            // 快速创建
            let button = XNButton(title: title, titleColor: titleColor, backGroundColor: backGroundColor);
            
            // 添加
            buttonView.addSubview(button);
            
            /*
             
             布局
             
             x 距离
             y 距离
             宽 和 高
             
             
             */
            
            button.sd_layout()
                .centerXEqualToView(buttonView)?
                .centerYEqualToView(buttonView)?
                .widthIs(buttonView.width - 5)?
                .heightIs(buttonView.height - 10);
            
            // -----------  切圆 描边 ------------
            
            // 边框 颜色
            //let buttonBorderColor  = UIColor.init(white: 0.894, alpha: 1.000)
            
            //[UIColor colorWithRed:1.000 green:0.362 blue:0.848 alpha:1.000];
            
            // 切圆 描边
            XNTool.viewCutRadius(button, cornerRadius: 8, borderWidth: borderWidth, borderColor: colorToBorder);
            
            button.addTarget(self, action: #selector(XNKeyboardView.clickButton(_:)), for: .touchUpInside);
        }
    }
    
    // MARK:
    // MARK: 第2 行的 字母
    /// 第2 行的 字母
    fileprivate func initButtonTwo() {
        
        /// 每行几个
        let countToLine = xnTwoRowArray.count;
        
        /// 每个 View 的宽
        let width = (self.width - 40 ) / CGFloat(countToLine);
        
        /// 每个View 的高 父类高除以4
        let height = CGFloat(self.height * 0.25);
        
        for i in 0..<xnTwoRowArray.count {
            
            /// 当前第几行 只有一行 所以不需要
            // let currentLine = i / countToLine;
            
            /// 当前行 第几个
            let currentLineNumber = i % countToLine;
            
            let buttonView = UIView();
            
            keyboardViewToNumberAndGrapheme.addSubview(buttonView);
            
            let x = width * CGFloat(currentLineNumber) + 20;
            
            
            
            // 距离y距离 0  1 行一起的距离
            let y = height * 2;
            
            /*
             x 距离
             y 距离
             宽 和 高
             */
            
            buttonView.frame = CGRect(x: x, y: y, width: width, height: height);
            
            //buttonView.backgroundColor = randomColor();
            
            /// ------------  添加 按钮  -----------
            
            // 背景色
            let backGroundColor = UIColor.white;
            
            // 文本
            let title = xnTwoRowArray[i];
            
            // 文本颜色
            let titleColor = UIColor.black;
            
            // 快速创建
            let button = XNButton(title: title, titleColor: titleColor, backGroundColor: backGroundColor);
            
            // 添加
            buttonView.addSubview(button);
            
            /*
             
             布局
             
             x 距离
             y 距离
             宽 和 高
             
             
             */
            
            button.sd_layout()
                .centerXEqualToView(buttonView)?
                .centerYEqualToView(buttonView)?
                .widthIs(buttonView.width - 5)?
                .heightIs(buttonView.height - 10);
            
            // -----------  切圆 描边 ------------
            
            // 边框 颜色
            //let buttonBorderColor  = UIColor.init(white: 0.894, alpha: 1.000)
            
            //[UIColor colorWithRed:1.000 green:0.362 blue:0.848 alpha:1.000];
            
            // 切圆 描边
            XNTool.viewCutRadius(button, cornerRadius: radian, borderWidth: borderWidth, borderColor: colorToBorder);
            
            button.addTarget(self, action: #selector(XNKeyboardView.clickButton(_:)), for: .touchUpInside);
        }
    }
    
    // MARK:
    // MARK: 第0行 和1 行的 数字和字母
    /// 第0行 和1 行的 数字和字母
    fileprivate func initButtonOne() {
        
        /// 每行几个
        let countToLine = NSInteger(Double(xnOneRowArray.count) * 0.5);
        
        /// 每个 View 的宽
        let width = self.width / CGFloat(countToLine);
        
        /// 每个View 的高 父类高除以4
        let height = CGFloat(self.height * 0.25);
        
        for i in 0..<xnOneRowArray.count {
            
            /// 当前第几行
            let currentLine = i / countToLine;
            
            /// 当前行 第几个
            let currentLineNumber = i % countToLine;
            
            let buttonView = UIView();
            
            keyboardViewToNumberAndGrapheme.addSubview(buttonView);
            
            let x = width * CGFloat(currentLineNumber);
            
            // 距离y距离
            let y = height * CGFloat(currentLine);
            
            /*
             x 距离
             y 距离
             宽 和 高
             */
            
            buttonView.frame = CGRect(x: x, y: y, width: width, height: height);
            
            //buttonView.backgroundColor = randomColor();
            
            /// ------------  添加 按钮  -----------
            
            // 背景色
            let backGroundColor = UIColor.white;
            
            // 文本
            let title = xnOneRowArray[i];
            
            // 文本颜色
            let titleColor = UIColor.black;
            
            // 快速创建
            let button = XNButton(title: title, titleColor: titleColor, backGroundColor: backGroundColor);
            
            // 添加
            buttonView.addSubview(button);
            
            /*
             
             布局
             
             x 距离
             y 距离
             宽 和 高
             
             
             */
            
            button.sd_layout()
                .centerXEqualToView(buttonView)?
                .centerYEqualToView(buttonView)?
                .widthIs(buttonView.width - 5)?
                .heightIs(buttonView.height - 10);
            
            // -----------  切圆 描边 ------------
            
            // 边框 颜色
            //let buttonBorderColor  = UIColor.init(white: 0.894, alpha: 1.000)
            
            //[UIColor colorWithRed:1.000 green:0.362 blue:0.848 alpha:1.000];
            
            // 切圆 描边
            XNTool.viewCutRadius(button, cornerRadius: radian, borderWidth: borderWidth, borderColor: colorToBorder);
            
            button.addTarget(self, action: #selector(XNKeyboardView.clickButton(_:)), for: .touchUpInside);
        }
    }
    
    
}

// MARK:
// MARK: 添加 省级行政区 按钮
extension XNKeyboardView {
    
    
    // MARK:
    // MARK: 剩余几个按钮处理
    /// 剩余几个按钮处理
    fileprivate func initButtonAgain() {
        
        /// 每行几个
        let countToLine = xnThenArray.count;
        
        /// 每个 View 的宽
        let width = self.width / CGFloat(countToLine);
        
        /// 每个View 的高 父类高除以4
        let height = CGFloat(self.height * 0.25);
        
        for i in 0..<xnThenArray.count {
            
            /// 当前行 第几个
            let currentLineNumber = i % countToLine;
            
            let buttonView = UIView();
            
            addSubview(buttonView);
            
            let x = width * CGFloat(currentLineNumber);
            
            // 距离y距离 3个高
            let y = height * 3 ;
            
            /*
             x 距离
             y 距离
             宽 和 高
             */
            
            buttonView.frame = CGRect(x: x, y: y, width: width, height: height);
            
            //buttonView.backgroundColor = randomColor();
            
            /// ------------  添加 按钮  -----------
            
            // 背景色
            let backGroundColor = UIColor.white;
            
            // 文本
            let title = xnThenArray[i];
            
            // 文本颜色
            let titleColor = UIColor.black;
            
            // 快速创建
            let button = XNButton(title: title, titleColor: titleColor, backGroundColor: backGroundColor);
            
            // 添加
            buttonView.addSubview(button);
            
            /*
             
             布局
             
             x 距离
             y 距离
             宽 和 高
             
             
             */
            
            button.sd_layout()
                .centerXEqualToView(buttonView)?
                .centerYEqualToView(buttonView)?
                .widthIs(width - 15)?
                .heightIs(35);
            
            // -----------  切圆 描边 ------------
            
            // 边框 颜色
            //let buttonBorderColor  = UIColor.init(white: 0.894, alpha: 1.000)
            
            //[UIColor colorWithRed:1.000 green:0.362 blue:0.848 alpha:1.000];
            
            // 切圆 描边
            XNTool.viewCutRadius(button, cornerRadius: radian, borderWidth: borderWidth, borderColor: colorToBorder);
            
            button.addTarget(self, action: #selector(XNKeyboardView.clickButton(_:)), for: .touchUpInside);
        }
    }
    
    // MARK: 创建里面的按钮
    /// 创建里面的按钮
    fileprivate func initButton() {
        
        /// 每行几个
        let countToLine = 9;
        
        /// 每个 View 的宽
        let width = self.width / CGFloat(countToLine);
        
        /// 每个View 的高 父类高除以4
        let height = CGFloat(self.height * 0.25);
        
        for i in 0..<xnArrayProvincialAdministrativeRegion.count {
            
            /// 当前第几行
            let currentLine = i / countToLine;
            
            /// 当前行 第几个
            let currentLineNumber = i % countToLine
            
            let buttonView = UIView();
            
            addSubview(buttonView);
            
            let x = width * CGFloat(currentLineNumber);
            
            // 距离y距离
            let y = height * CGFloat(currentLine) + 5;
            
            /*
             x 距离
             y 距离
             宽 和 高
             */
            
            buttonView.frame = CGRect(x: x, y: y, width: width, height: height);
            
            //buttonView.backgroundColor = randomColor();
            
            /// ------------  添加 按钮  -----------
            
            // 背景色
            let backGroundColor = UIColor.white;
            
            // 文本
            let title = xnArrayProvincialAdministrativeRegion[i];
            
            // 文本颜色
            let titleColor = UIColor.black;
            
            // 快速创建
            let button = XNButton(title: title, titleColor: titleColor, backGroundColor: backGroundColor);
            
            // 添加
            buttonView.addSubview(button);
            
            /*
             
             布局
             
             x 距离
             y 距离
             宽 和 高
             
             
             */

            button.sd_layout()
                .centerXEqualToView(buttonView)?
                .centerYEqualToView(buttonView)?
                .widthIs(buttonView.width - 5)?
                .heightIs(buttonView.height - 10);
            
            // -----------  切圆 描边 ------------
            
            // 边框 颜色
            //let buttonBorderColor  = UIColor.init(white: 0.894, alpha: 1.000)
            
            //[UIColor colorWithRed:1.000 green:0.362 blue:0.848 alpha:1.000];
            
            // 切圆 描边
            XNTool.viewCutRadius(button, cornerRadius: radian, borderWidth: borderWidth, borderColor: colorToBorder);
            
            button.addTarget(self, action: #selector(XNKeyboardView.clickButton(_:)), for: .touchUpInside);
            
        }
        
        
    }

}












