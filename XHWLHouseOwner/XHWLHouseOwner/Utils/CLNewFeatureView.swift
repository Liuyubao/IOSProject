//
//  WBNewFeatureView.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/5.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

class CLNewFeatureView: UIView {
    //pageControl与底部的距离（需要更改高度改此处就好）
    fileprivate let margin: CGFloat = 60
    fileprivate let marginBtn: CGFloat = 30
    fileprivate var imageNameArr: [Any]?
    fileprivate var subscriptIndex: Int = 0

    /// scrollView懒加载
    lazy fileprivate var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        
        return scrollView
    }()
    
    /// 圆圈视图UIPageControl
    lazy fileprivate var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.pageIndicatorTintColor = color_01f0ff
        pageControl.currentPageIndicatorTintColor = color_328bfe
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.subscriptIndex
        
        return pageControl
    }()
    
     lazy fileprivate var jumpBtn: UIButton = {
        let jumpBtn = UIButton()
        jumpBtn.backgroundColor = color_328bfe
        jumpBtn.layer.cornerRadius = 4
        jumpBtn.layer.masksToBounds = true
        jumpBtn.setTitle("直接跳转", for: .normal)
        jumpBtn.setTitleColor(UIColor.white, for: .normal)
        jumpBtn.titleLabel?.font = font_15
        jumpBtn.addTarget(self, action: #selector(onJumpClick), for: .touchUpInside)
//            jumpBtn.frame = CGRect(x:0, y:0 width:100, height:30)
//            self.view.addSubview(jumpBtn)
        return jumpBtn
    }()
    
    func onJumpClick() {
        self.removeFromSuperview()
    }
    
    convenience init(imageNameArr: [Any]) {
        self.init()
        self.imageNameArr = imageNameArr
        subscriptIndex = imageNameArr.count
        setupUI()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CLNewFeatureView {
    
    /// 页面搭建
    fileprivate func setupUI() {
        
        //添加视图
        addSubview(scrollView)
//        addSubview(pageControl)
        addSubview(jumpBtn)
        
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        //自动布局
//        addConstraint(NSLayoutConstraint(item: pageControl,
//                                         attribute: .centerX,
//                                         relatedBy: .equal,
//                                         toItem: self,
//                                         attribute: .centerX,
//                                         multiplier: 1.0,
//                                         constant: 0))
//        addConstraint(NSLayoutConstraint(item: pageControl,
//                                         attribute: .bottom,
//                                         relatedBy: .equal,
//                                         toItem: self,
//                                         attribute: .bottom,
//                                         multiplier: 1.0,
//                                         constant: -margin))
        
        jumpBtn.translatesAutoresizingMaskIntoConstraints = false
        //自动布局
        
        addConstraint(NSLayoutConstraint(item: jumpBtn,
                                         attribute: .width,
                                         relatedBy:.equal,
                                         toItem:nil,
                                         attribute: .notAnAttribute,
                                         multiplier:0.0,
                                         constant:120))
        addConstraint(NSLayoutConstraint(item: jumpBtn,
                                         attribute: .height,
                                         relatedBy:.equal,
                                         toItem:nil,
                                         attribute: .notAnAttribute,
                                         multiplier:0.0,
                                         constant:30))
        addConstraint(NSLayoutConstraint(item: jumpBtn,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: jumpBtn,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: -marginBtn))
        
        //添加新特性图片
        for i in 0...(subscriptIndex - 1) {
            
            let imageView = UIImageView(image: UIImage(named: (imageNameArr![i] as! String)))

            imageView.frame = self.bounds.offsetBy(dx: CGFloat(i) * self.bounds.width, dy: 0)
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(subscriptIndex + 1), height: self.bounds.height)
    }
    
}


// MARK: - UIScrollViewDelegate
extension CLNewFeatureView: UIScrollViewDelegate {
    
    /// 每次滚动都会调用
    ///
    /// - Parameter scrollView: scrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x
        //计算当前页数(四舍五入算法)
        let page = Int(offSetX / self.bounds.width + 0.5)
        pageControl.currentPage = page
        
        //隐藏pageControl
        pageControl.isHidden = offSetX > (self.bounds.width * CGFloat(Double(subscriptIndex) - 0.7))
        jumpBtn.isHidden = offSetX > (self.bounds.width * CGFloat(Double(subscriptIndex) - 0.7))
        
        //将newFeature从页面移除
        if offSetX >= self.bounds.width * CGFloat(subscriptIndex) {
            self.removeFromSuperview()
        }
 
    }
    
}

