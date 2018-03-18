//
//  PersonPathViewController.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/11.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import CoreBluetooth
import TransitionTreasury
import TransitionAnimation
import JSQWebViewController

class PersonPathViewController: UIViewController, UIScrollViewDelegate, ModalTransitionDelegate {
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func toSpaceBtnClicked(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        vc.modalDelegate = self
        tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: nil, dismiss: vc.dismissGestureRecognizer), completion: {
            print("Present finished")
        })
    }
    
    @IBAction func inviteBtnClicked(_ sender: UIButton) {
        let controller = CallerInviteVC()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalTransitionStyle = .crossDissolve
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func toScanBtnClicked(_ sender: UIButton) {
        //跳到扫一扫
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    @IBAction func settingBtnClicked(_ sender: UIButton) {
        //跳到个人中心
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalCenterVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    //门口管理
    @IBAction func doorManageBtn(_ sender: UIButton) {
        let vc = DoorCardManageVC()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*0.9)
        
        //约束根据屏幕高度做适配
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        print("屏幕高度：\(screenHeight)")
        switch screenHeight {
        case 480.0://4s
            scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.6)
        case 568.0://5s
            scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*1.3)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*0.9)
        
        // Do any additional setup after loading the view.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.interactiveTransition(_:)))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.view.isUserInteractionEnabled = true
    }
    
    func interactiveTransition(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard sender.velocity(in: view).y > 0 else {
                break
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
            vc.modalDelegate = self
            tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: sender, dismiss: vc.dismissGestureRecognizer), completion: {
                print("Present finished")
            })
        default: break
        }
    }
    
    func modalViewControllerDismiss(interactive: Bool, callbackData data: Any?) {
        tr_dismissViewController(interactive, completion: nil)
    }
    
    var returnToSpaceImg:UIImageView?
    
    //tap toFourTabbars的事件
    func tapReturnToSpaceGesture(sender: UITapGestureRecognizer){
        print("单击了第三张图片")
        returnToSpaceImg?.removeFromSuperview()
        
        UserDefaults.standard.set(true, forKey:"notFirstGuideThree")
        UserDefaults.standard.synchronize()
    }
    
    //报事投诉
    @IBAction func reportBtnClicked(_ sender: UIButton) {
        let controller = WebViewController(url: URL(string: "http://202.105.96.131:3002/xa")!)
        controller.displaysWebViewTitle = true
        let nav = UINavigationController(rootViewController: controller)
        nav.modalTransitionStyle = .crossDissolve
        present(nav, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 下拉弹出space
        scrollView.sy_header = GifHeaderFooter(data: nil, orientation: .top, height: 20,contentMode:.scaleAspectFill,completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self?.scrollView.sy_header?.endRefreshing()
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "SpaceVC")
                self?.present(vc!, animated: true)
            }
        })
        
        if UserDefaults.standard.bool(forKey: "notFirstGuideThree") == false{
            
            //添加第三张图片
            returnToSpaceImg = UIImageView(image: UIImage(named: "returnToSpace"))
            self.view.addSubview(returnToSpaceImg!)
            returnToSpaceImg?.frame = CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height)
            
            //单击第一张图片的手势
            let tap3 = UITapGestureRecognizer(target: self, action: #selector(tapReturnToSpaceGesture(sender:)))
            returnToSpaceImg?.isUserInteractionEnabled = true
            returnToSpaceImg?.addGestureRecognizer(tap3)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(tapReturnToSpaceGesture(sender:)))
            pan.delegate = self
            returnToSpaceImg?.addGestureRecognizer(pan)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PersonPathViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}
