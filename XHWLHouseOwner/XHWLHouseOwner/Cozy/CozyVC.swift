//
//  CozyVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class CozyVC: UIViewController, UIScrollViewDelegate, ModalTransitionDelegate {
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    @IBAction func settingBtnClicked(_ sender: UIButton) {
        //跳到个人中心
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalCenterVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)

    }
    @IBAction func toScanBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    @IBAction func cloudTalkBtnClicked(_ sender: UIButton) {
        //暂时跳到云对讲
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    @IBAction func cloudEyesBtnClicked(_ sender: UIButton) {
        //暂时跳到监控
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FourMonitorsVC")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 下拉弹出space
        scrollView.sy_header = GifHeaderFooter(data: nil, orientation: .top, height: 20,contentMode:.scaleAspectFill,completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self?.scrollView.sy_header?.endRefreshing()
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "SpaceVC")
                self?.present(vc!, animated: true)
//                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:self.scrollView.width, height: self.scrollView.height*0.9)
        
    }
    
}


extension CozyVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ges = gestureRecognizer as? UIPanGestureRecognizer {
            return ges.translation(in: ges.view).y != 0
        }
        return false
    }
}
