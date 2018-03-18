//
//  GoodnessVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation
import JSQWebViewController

class GoodnessVC: UIViewController, UIScrollViewDelegate, ModalTransitionDelegate {
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func shopBtnClicked(_ sender: UIButton) {
        let controller = WebViewController(url: URL(string: "http://56028283.m.weimob.com/vshop/56028283/Index?PageId=640148&IsPre=1&channel=menu")!)
        controller.displaysWebViewTitle = true
        let nav = UINavigationController(rootViewController: controller)
        nav.modalTransitionStyle = .crossDissolve
        present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func toSpaceBtnClicked(_ sender: UIButton) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC")
//        self.present(vc!, animated: true)
//        self.dismiss(animated: true, completion: nil)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        vc.modalDelegate = self
        tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: nil, dismiss: vc.dismissGestureRecognizer), completion: {
            print("Present finished")
        })
    }
    
    @IBAction func showWeatherInfoBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoodnessScrollVC") as! GoodnessScrollVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.pageControl.currentPage = 1
        vc.scrollView.setContentOffset(.init(x: vc.bgView.width, y: 0), animated: true)
    }
    
    @IBAction func showWaterInfoBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoodnessScrollVC") as! GoodnessScrollVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
        vc.pageControl.currentPage = 0
        vc.pageChanged(vc.pageControl)
    }

    @IBAction func settingBtnClicked(_ sender: UIButton) {
        //跳到个人中心
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalCenterVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    @IBAction func toScanBtnClicked(_ sender: UIButton) {
        //跳到扫一扫
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
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
    }
    
    @IBAction func toSportsBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SportsIndexVC") as! SportsIndexVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*0.9)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension GoodnessVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}
