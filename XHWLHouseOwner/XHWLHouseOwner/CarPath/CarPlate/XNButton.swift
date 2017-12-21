//
//  XNButton.swift
//  SwiftCustomKeyboard
//
//  Created by codeIsMyGirl on 16/6/22.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//



import UIKit

class XNButton: UIButton {

    // MARK: 添加栏目的按钮
    
    /// 添加栏目的按钮
    
    convenience init(title: String,titleColor: UIColor,backGroundColor: UIColor) {
        
        // 必须先 调用本类的指定构造函数 实例化自己
        self.init();
        
        // 文本
        setTitle(title, for: UIControlState());
        
        // 文本颜色
        setTitleColor(titleColor, for: UIControlState());
        
        // 背景色
        backgroundColor = backGroundColor;
        
        // 文本长度
        let textLenth = title.characters.count;
        
        // 文本 显示大小 17
        titleLabel?.font = UIFont.systemFont(ofSize: 17);
        
        // 长度 多少 字体大小多少
        if textLenth == 4 {
            
            titleLabel?.font = UIFont.systemFont(ofSize: 14);
        }
        
        if textLenth > 4 {
            
            titleLabel?.font = UIFont.systemFont(ofSize: 12);
        }
        
        
    }
    
    
    // MARK: 需要用 convenience 声明 遍历构造函数
    
    /// 默认图 和 高亮图
    convenience init(normalImage: UIImage,highlightedImage: UIImage?) {
        
        // 必须先 调用本类的指定构造函数 实例化自己
        self.init();
        
        setImage(normalImage, for: UIControlState());
        
        if highlightedImage != nil {
            
            setImage(highlightedImage, for:.highlighted);
            
            return;
        }
        
        setImage(normalImage, for: .highlighted);
        
    }


}
