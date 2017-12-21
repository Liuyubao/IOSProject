//
//  XHWLTabBarViewController.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/11.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class XHWLTabBarViewController:  UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedViewController = self.viewControllers?[0]
//        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()

        self.tabBar.tintColor = UIColor(red: 84/255.0, green: 254/255.0, blue: 252/255.0, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}



