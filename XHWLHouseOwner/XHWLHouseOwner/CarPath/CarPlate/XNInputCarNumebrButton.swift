//
//  XNInputCarNumebrButton.swift
//  SwiftCustomKeyboard
//
//  Created by codeIsMyGirl on 16/6/22.
//  Copyright © 2016年 codeIsMyGirl. All rights reserved.
//

import UIKit

class XNInputCarNumebrButton: UIButton {
    
    /// label 数组
    var labelArray = [UILabel]();
    
    // MARK:
    // MARK: 加载里面内容
    /// 加载里面内容 给外部调用
    func inputCarNumebrViewLoadContent() {
        
        // ----------  对自己进行操作  ----------
        // 里面的内容
        loadContent();
    }
    
    // MARK:
    // MARK: 里面的内容
    /// 里面的内容
    fileprivate func loadContent() {
        
        // 按钮之间的间隙
        let space = CGFloat(3);
        
        let labelWidth = (self.width - 6 * space) / 7;
        
        let labelHeight = labelWidth;
        
        // 装label的数组
        let tempArray = NSMutableArray(capacity: 7);
        
        // 车牌号长度为7
        for i in 0..<7 {
            
            let x = (labelWidth + space) * CGFloat(i);
            
            let y = CGFloat(0);
            
            let label = UILabel(frame: CGRect(x: x, y: y, width: labelWidth, height: labelHeight));
            
            addSubview(label);
            
            tempArray.add(label);
            
            // label 字体出现在中心
            label.textAlignment = .center;
            
            // label 字体大小
            label.font = UIFont.systemFont(ofSize: 15);
            
            // label背景色
            label.backgroundColor = UIColor.white;
            
            // 圆角描边
            XNTool.viewCutRadius(label, cornerRadius: 5, borderWidth: 1, borderColor: UIColor.gray);
        }
        
        
        labelArray = [
            
            tempArray[0] as! UILabel,
            tempArray[1] as! UILabel,
            tempArray[2] as! UILabel,
            tempArray[3] as! UILabel,
            tempArray[4] as! UILabel,
            tempArray[5] as! UILabel,
            tempArray[6] as! UILabel,
          
        ];
    }
    
}
