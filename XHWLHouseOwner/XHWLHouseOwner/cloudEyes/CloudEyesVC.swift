//
//  CloudEyesVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/5.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit

class CloudEyesVC: UIViewController, UIScrollViewDelegate{
    
    @IBAction func showConfigurations(_ sender: UIButton) {
        print("********\(fourMonitorsView.frame)")
        print("********\(fourMonitorsScrollView.frame)")
        print("********parentNode", parentNode)
        
        
//        if parentNode != nil {
//            //获取组织树节点的子节点资源
//            self.parentNode = self.resourceArray[1] as! MCUResourceNode //深圳分公司
//            print(self.parentNode?.nodeID)
////            self.requestResource()
////            self.parentNode = self.resourceArray[0] as! MCUResourceNode //深圳地区
////            self.requestResource()
////            self.parentNode = self.resourceArray[0] as! MCUResourceNode //深圳中海华庭节点
////            self.requestResource()                                      //所有视频的节点集
//
//            for node in self.resourceArray{
//                let mcuNode = node as! MCUResourceNode
//                let monitor = ["name":mcuNode.nodeName, "pic":"Common_play  ", "cameraSyscode":mcuNode.sysCode]
//            }
//
//        } else {
//            //首先要请求获取组织树节点的第一级节点资源
//            self.requestRootResource()
//        }
    }
    
    var parentNode:MCUResourceNode? /**< 父节点*/
    var resourceArray:NSArray = []
    
    @IBOutlet weak var fourMonitorsView: UIView!//存放4个监控画面的View,用于定位4个监控画面的整体大小
    @IBOutlet weak var fourMonitorsScrollView: UIScrollView!//存放4个监控画面的scrollView
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    //存放单个监控的相关信息的数组
    var monitorInfos = [[String:String]]()
//        ["name":"集团总部前台", "pic":"Common_play", "cameraSyscode":"426b767f78744939a5d8ea02d8e880dc"],
//        ["name":"洽谈室通道", "pic":"Common_play", "cameraSyscode":"d79441b3a81f483db19f9ab1d421a521"],
//        ["name":"八楼前台", "pic":"Common_play", "cameraSyscode":"a675f8e1c91f4fbe8fb4f594bd99c474"],
//        ["name":"打印机侧通道", "pic":"Common_play", "cameraSyscode":"8bd32800f5a444fcaaa5b96259ccdee1"],
//        ["name":"总部机房", "pic":"Common_play", "cameraSyscode":"92ac4c85a65243d58ef906c1bf75bab2"],
//        ["name":"优你家办公室", "pic":"Common_play", "cameraSyscode":"92ac4c85a65243d58ef906c1bf75bab2"],
//        ["name":"专业公司办公室", "pic":"Common_play", "cameraSyscode":"92ac4c85a65243d58ef906c1bf75bab2"],
//        ["name":"8楼机房", "pic":"Common_play", "cameraSyscode":"92ac4c85a65243d58ef906c1bf75bab2"]
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //用于存放所有的监控大画面
    var allBigViews = [UIView]()
    
    //用于存放所有的监控小画面
    var allSmallViews = [UIView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButtonClicked()
//        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func reloadData(){
        //设置scrollView的内容总尺寸
        fourMonitorsScrollView.contentSize = CGSize(
            width: CGFloat(self.fourMonitorsView.frame.width) * CGFloat(self.monitorInfos.count/4),
            height: 0
        )
        //关闭滚动条显示
        fourMonitorsScrollView.showsHorizontalScrollIndicator = false
        fourMonitorsScrollView.showsVerticalScrollIndicator = false
        
        fourMonitorsScrollView.scrollsToTop = false
        //协议代理，在本类中处理滚动事件
        fourMonitorsScrollView.delegate = self
        //滚动时只能停留到某一页
        fourMonitorsScrollView.isPagingEnabled = true
        //添加页面到滚动面板里
        let size = fourMonitorsScrollView.bounds.size
        let monitorCount = monitorInfos.count//子监控画面的个数
        
        for i in 0..<Int(monitorCount/4){
            //定义4个监控的画面，个数为总个数／4+1
            let bigView = UIView()
            
            //在所有的大view中添加4个小View
            for j in 0..<4{
                //                let imageView = UIImageView(image: UIImage(named: monitorInfos[4*i+j]["pic"]!))
                let singleView = SingleMonitorView()
                singleView.setValues(img: UIImage(named: monitorInfos[4*i+j]["pic"]!)!, name: monitorInfos[4*i+j]["name"]!,code: monitorInfos[4*i+j]["cameraSyscode"]!)
                allSmallViews.append(singleView)//保存到small数组
                singleView.frame = CGRect(x: CGFloat(Int(j%2))*size.width/2+5, y: CGFloat(Int(j/2))*size.height/2+5, width: size.width/2-10, height: size.height/2-10)
                bigView.addSubview(singleView)
                
                //添加tap监听手势
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(tap:)))
                singleView.addGestureRecognizer(singleTap)
                singleView.isUserInteractionEnabled = true
            }
            
            bigView.frame = CGRect(x: CGFloat(i) * size.width, y: 0,
                                   width: size.width, height: size.height)
            fourMonitorsScrollView.addSubview(bigView)
            
            allBigViews.append(bigView)//保存到big数组
            //            print("bigViewFrame********\(bigView.frame)")
            
        }
        
        //页控件属性
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = monitorInfos.count/4
        
        pageControl.currentPage = 0
        
        //设置页控件点击事件
        pageControl.addTarget(self, action: #selector(pageChanged(_:)),
                              for: UIControlEvents.valueChanged)
        
        print("********\(fourMonitorsView.frame)")
        print("********\(fourMonitorsScrollView.frame)")

    }
    
    func singleTapAction(tap:UITapGestureRecognizer) {
        let toShowMonitorSysCode = (tap.view as! SingleMonitorView).cameraSyscode
        var toShowSingleMonitorVC = self.storyboard?.instantiateViewController(withIdentifier: "SingleMonitorVC") as! RealPlayVC
//        toShowSingleMonitorVC.loginButtonClicked()
        toShowSingleMonitorVC.cameraSyscode = toShowMonitorSysCode
        toShowSingleMonitorVC.realPlay(cameraSyscode: toShowMonitorSysCode!)
        
        //实现回调，接收回调过来的值
        toShowSingleMonitorVC.setBackMyClosure { (tempImg) in
            (tap.view as! SingleMonitorView).monitorImg.image = tempImg
        }
        toShowSingleMonitorVC.modalTransitionStyle = .crossDissolve
        self.present(toShowSingleMonitorVC, animated: true, completion: nil)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        重排scrollView的contentView
        fourMonitorsScrollView.contentSize = CGSize(
            width: CGFloat(self.fourMonitorsView.frame.width) * CGFloat(self.monitorInfos.count/4),
            height: 0
        )
        for (index, bView) in allBigViews.enumerated(){
            bView.frame = CGRect(x: CGFloat(index) * self.fourMonitorsView.frame.width, y: 0,
                                   width: self.fourMonitorsView.frame.width, height: self.fourMonitorsView.frame.height)
            for j in 0..<4{
                allSmallViews[index*4+j].frame = CGRect(x: CGFloat(Int(j%2))*bView.frame.width/2+5, y: CGFloat(Int(j/2))*bView.frame.height/2+5, width: bView.frame.width/2-10, height: bView.frame.height/2-10)
            }
        }
        
    }
    
    //UIScrollViewDelegate方法，每次滚动结束后调用
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //通过scrollView内容的偏移计算当前显示的是第几页
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        //设置pageController的当前页
        pageControl.currentPage = page
    }
    
    //点击页控件时事件处理
    func pageChanged(_ sender:UIPageControl) {
        //根据点击的页数，计算scrollView需要显示的偏移量
        var frame = fourMonitorsScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        //展现当前页面内容
        fourMonitorsScrollView.scrollRectToVisible(frame, animated:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     *  点击登录按钮
     */
    func loginButtonClicked() {
        XHMLProgressHUD.shared.show()
        let password:String = MSP_PASSWORD.md5
        
        //调用 登录平台接口,完成登录操作
        //注意:登录密码必须是经过MD5加密的
        MCUVmsNetSDK.shareInstance().loginMsp(withUsername: MSP_USERNAME, password: password, success: { (responseDic) in
            XHMLProgressHUD.shared.hide()
            let obj:NSDictionary = responseDic as! NSDictionary
            let status:String = obj["status"] as! String
            
            if (status.compare("200").rawValue == 0) {
                ////                [SVProgressHUD dismiss];
                self.requestResource()
//                self.isLogin = true
            } else {
                print("登陆失败2")
                //                //返回码为200,代表登录成功.返回码为202,203,204时,分别代表的意思是初始密码登录,密码强度不符合要求,密码过期.这三种情况都需要修改密码.请开发者使用当前账号登录BS端平台,按要求进行密码修改后,再进行APP的开发测试工作.其他返回码,请根据平台返回提示信息进行提示或处理
                ////                [SVProgressHUD showErrorWithStatus:responseDic[@"description"]];
            }
        }) { (error) in
            
            print("登陆失败3")
            //            [SVProgressHUD showErrorWithStatus:@"服务器连接失败"];
        }
    }
    
    /**
     *  请求根资源点数据
     */
    func requestRootResource() {
        //1 代表视频资源
        
        MCUVmsNetSDK.shareInstance().requestRootNode(withSysType: 1, success: { (object) in
            
            let obj:NSDictionary = object as! NSDictionary
            let status:String = obj["status"] as! String
            if (status.compare("200").rawValue == 0) {
                self.parentNode = obj["resourceNode"] as? MCUResourceNode
                self.requestResource()
                
            } else {
//                self.showDescription(object: obj)
            }
        }) { (error) in
            
        }
    }
    
    /**
     *  请求资源点列表数据
     */
    func requestResource() {
        XHMLProgressHUD.shared.show()
        //        [SVProgressHUD showWithStatus:@"加载中..."];
        MCUVmsNetSDK.shareInstance().requestResource(withSysType: 1,
                                                     nodeType: 2,
                                                     currentID: "118" ,
                                                     numPerPage: 100, curPage: 1,
                                                     success: { (object) in
                                                        //            [self dismiss];
                                                        let obj:NSDictionary = object as! NSDictionary
                                                        let status:String = obj["status"] as! String
                                                        
                                                        
                                                        if (status.compare("200").rawValue == 0) {
                                                            self.resourceArray = obj["resourceNodes"] as! NSArray
                                                            if self.resourceArray.count > 0 {
                                                                for (index,node) in self.resourceArray.enumerated(){
                                                                    if index<12 {
                                                                        let mcuNode = node as! MCUResourceNode
                                                                        let monitor = ["name":mcuNode.nodeName, "pic":"Common_play", "cameraSyscode":mcuNode.sysCode]
                                                                        self.monitorInfos.append(monitor as! [String : String])
                                                                    }
                                                                }
                                                                self.reloadData()
                                                                "加入到array".ext_debugPrintAndHint()
                                                                XHMLProgressHUD.shared.hide()
                                                            } else {
                                                                //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                //                        [SVProgressHUD showErrorWithStatus:@"暂无资源"];
                                                                //                        [self performSelector:@selector(dismiss) withObject:nil afterDelay:delayTime];
                                                                //                        });
                                                            }
                                                        }
        }) { (error) in
            //            [self dismiss];
            //            NSLog(@"requestResource failed");
        }
    }


}
