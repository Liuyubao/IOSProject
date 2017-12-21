//
//  CarPathVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class CarPathVC: UIViewController, UIScrollViewDelegate, ModalTransitionDelegate {
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBAction func reportBtnClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "客服", message: "请联系13123375305", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
        })
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func toSpaceBtnClicked(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        vc.modalDelegate = self
        tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: nil, dismiss: vc.dismissGestureRecognizer), completion: {
            print("Present finished")
        })
    }

    @IBAction func toScanBtnClicked(_ sender: UIButton) {
        //跳到扫一扫
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC")
        self.present(vc!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
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
//                self?.dismiss(animated: false, completion: nil)
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "SpaceVC")
                self?.present(vc!, animated: true)
            }
        })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

