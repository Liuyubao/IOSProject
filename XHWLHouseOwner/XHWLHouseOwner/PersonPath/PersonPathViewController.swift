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

class PersonPathViewController: UIViewController, CBCentralManagerDelegate, UIScrollViewDelegate, ModalTransitionDelegate {
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
//    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func toSpaceBtnClicked(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpaceVC")
//        self.present(vc!, animated: true)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpaceVC") as! SpaceViewController
        vc.modalDelegate = self
        tr_presentViewController(vc, method: TRPresentTransitionMethod.scanbot(present: nil, dismiss: vc.dismissGestureRecognizer), completion: {
            print("Present finished")
        })
        
    }
    
    var central:CBCentralManager!
    //跳到蓝牙绑卡
    @IBAction func toBluetoothBtnClicked(_ sender: UIButton) {
        //初始化本地中心设备对象
        central = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    //MARK: -2.检查设备自身（中心设备）支持的蓝牙状态
    // CBCentralManagerDelegate的代理方法
    
    /// 本地设备状态
    ///
    /// - Parameter central: 中心者对象
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown")
            break
        case .resetting:
            print("CBCentralManager state:", "resetting")
            break
        case .unsupported:
            print("CBCentralManager state:", "unsupported")
            break
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized")
            break
        case .poweredOff:
            print("CBCentralManager state:", "power off")
            //            AlertMessage.showAlertMessage(vc: self, alertMessage: "请打开蓝牙！", duration: 1)
            break
        case .poweredOn:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "bluetoothVC")
            vc?.modalTransitionStyle = .crossDissolve
            self.present(vc!, animated: true)
            break
        }
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
