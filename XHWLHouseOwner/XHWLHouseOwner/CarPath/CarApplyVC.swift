//
//  CarApplyVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/14.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import DropDown
import Photos

class CarApplyVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var brandTF: UITextField!
    @IBOutlet weak var carTypeTF: UITextField!
    @IBOutlet weak var carPlateBtn: XNInputCarNumebrButton!
    
    @IBOutlet weak var colorBtn: UIButton!
    let colorDropDown = DropDown()  //颜色下拉框
    
    @IBOutlet weak var projectTypeTF: UITextField!
    
    @IBOutlet weak var payWayBtn: UIButton!
    let payWayDropDown = DropDown() //支付方式下拉框
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    //添加车辆信息闭包
    var addCarClosure: (NSDictionary)->()={para in}
    
    
    @IBOutlet weak var carApplyView: UIView!
    
    @IBAction func payWayBtnClicked(_ sender: UIButton) {
        keyboardViewShowOrHidden(false)
        payWayDropDown.show()
    }
    @IBAction func colorBtnClicked(_ sender: UIButton) {
        keyboardViewShowOrHidden(false)
        colorDropDown.show()
    }
    
    //配置color下拉框
    func setupColorDropDown() {
        colorDropDown.anchorView = colorBtn
        
        colorDropDown.bottomOffset = CGPoint(x: 0, y: colorBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        colorDropDown.dataSource = [
            "黑色",
            "白色",
            "黄色",
            "紫色",
            "银色",
            "绿色",
            "蓝色",
            "红色"
        ]
        
        // Action triggered on selection
        colorDropDown.selectionAction = { [unowned self] (index, item) in
            self.colorBtn.setTitle(item, for: .normal)
        }
        
    }
    
    //配置payway下拉框
    func setupPayWayDropDown() {
        payWayDropDown.anchorView = payWayBtn
        
        payWayDropDown.bottomOffset = CGPoint(x: 0, y: payWayBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        payWayDropDown.dataSource = [
            "临停缴费",
            "月卡缴费"
        ]
        
        // Action triggered on selection
        payWayDropDown.selectionAction = { [unowned self] (index, item) in
            self.payWayBtn.setTitle(item, for: .normal)
        }
        
    }
    
    // 自定义的键盘View
    fileprivate let keyboardView = XNKeyboardView()
    
    @IBAction func conformBtnClicked(_ sender: UIButton) {
        //为空判断
        if (self.brandTF.text?.isEmpty)!{
            self.noticeError("品牌不能为空！",autoClearTime: 1)
            return
        } else if !Validation.carNum(getWholePlateNumber()).isRight{
            self.noticeError("车牌输入不规范！",autoClearTime: 1)
            return
        } else if (colorBtn.currentTitle?.isEmpty)!{
            self.noticeError("颜色不能为空！",autoClearTime: 1)
            return
        }
        
        addCarClosure(["brandName": "\(self.brandTF.text!) \(self.carTypeTF.text!)", "plateNum": getWholePlateNumber(), "color": colorBtn.currentTitle, "pic": self.cameraBtn.currentBackgroundImage, "project": self.projectTypeTF.text!, "payWay": self.payWayBtn.currentTitle])
        self.noticeSuccess("添加成功！", autoClear: true, autoClearTime: 1)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: 图片选择器界面
    var imagePickerController: UIImagePickerController!
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //拍照得到照片
    @IBAction func getPhotoBtnClicked(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.present(selectorController, animated: true, completion: nil)
        } else {
            print("can't find camera")
        }
    }
    
    // MARK: 用于弹出选择的对话框界面
    var selectorController: UIAlertController {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil)) // 取消按钮
        controller.addAction(UIAlertAction(title: "拍照选择", style: .default) { action in
            self.selectorSourceType(.camera)
        }) // 拍照选择
        controller.addAction(UIAlertAction(title: "相册选择", style: .default) { action in
            self.selectorSourceType(.photoLibrary)
        }) // 相册选择
        return controller
    }
    
    func selectorSourceType(_ type: UIImagePickerControllerSourceType) {
        //选择完类型直接打开图片或者相机选择VC
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = type
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    // MARK: 当图片选择器选择了一张图片之后回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        dismiss(animated: true, completion: nil) // 选中图片, 关闭选择器...这里你也可以 picker.dismissViewControllerAnimated 这样调用...但是效果都是一样的...
        
        let img = info[UIImagePickerControllerEditedImage] as? UIImage // 显示图片
        
        
        cameraBtn.contentMode = .scaleAspectFit // 缩放显示, 便于查看全部的图片
        cameraBtn.setBackgroundImage(img, for: .normal)

    }
    
    // MARK: 当点击图片选择器中的取消按钮时回调
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // 效果一样的...
    }
    
    // MARK:
    // MARK: 创建键盘
    /// 创建键盘
    fileprivate func initKeyboardView() {
        
        // 创建键盘View
        view.addSubview(keyboardView);
        
        keyboardView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 216)
        
        // 设置代理
        keyboardView.xnKeyboardViewDelegate = self
        
        // 加载内容
        keyboardView.xnKeyboardViewLoadContent()
    }
    
    // MARK:
    // MARK: 创建 车牌号显示的View
    /// 创建 车牌号显示的View
    fileprivate func initInputCarNumebrView() {
        
        // 加载里面内容
        carPlateBtn.inputCarNumebrViewLoadContent()
        
        // 添加事件
        carPlateBtn.addTarget(self, action: #selector(CarApplyVC.clickInputCarNumebrButton(_:)), for: .touchDown)
        /*
         点击立即调用
         TouchDown
         
         */
    }
    
    // MARK:
    // MARK: 手势响应事件
    /// 手势响应事件
    @objc fileprivate func clickInputCarNumebrButton(_ sender: XNInputCarNumebrButton) {
        //print("----\(sender.view)")
        
        self.view.endEditing(true)
        // 文本框的隐藏关闭
        keyboardViewShowOrHidden(true)
        
    }
    
    // MARK:
    // MARK: 键盘的 出现和隐藏
    /// 键盘的 出现和隐藏 true 显示
    fileprivate func keyboardViewShowOrHidden(_ isShow: Bool) {
        
        // 为真 显示
        let y = isShow ? UIScreen.main.bounds.height - self.keyboardView.height : UIScreen.main.bounds.height
        
        // 如果一样不需要做动画
        if keyboardView.y == y {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.keyboardView.y = y
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegin 发生了")
        // 文本框的隐藏关闭
        keyboardViewShowOrHidden(false)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 车牌号显示的View
        initInputCarNumebrView()
        
        // 创建键盘
        initKeyboardView()
        
        // 配置dropDown
        setupPayWayDropDown()
        setupColorDropDown()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    }
    
    //键盘的出现
    func keyBoardWillShow(_ notification: Notification){
        //收起车牌键盘
        keyboardViewShowOrHidden(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        brandTF.layer.borderWidth = 0.5
        brandTF.layer.cornerRadius = 2
        brandTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        carTypeTF.layer.borderWidth = 0.5
        carTypeTF.layer.cornerRadius = 2
        carTypeTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
//        carPlateTF.layer.borderWidth = 0.5
//        carPlateTF.layer.cornerRadius = 2
//        carPlateTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        colorBtn.layer.borderWidth = 0.5
        colorBtn.layer.cornerRadius = 2
        colorBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        projectTypeTF.layer.borderWidth = 0.5
        projectTypeTF.layer.cornerRadius = 2
        projectTypeTF.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        payWayBtn.layer.borderWidth = 0.5
        payWayBtn.layer.cornerRadius = 2
        payWayBtn.layer.borderColor = UIColor(red: 91/255.0, green: 239/255.0, blue: 245/255.0, alpha: 1.0).cgColor
        
        
    }


}

// MARK:
// MARK: 自定义键盘的 代理方法
extension CarApplyVC: XNKeyboardViewDelegate {
    
    // MARK:
    // MARK: 获得输入完整的车牌号码
    func getWholePlateNumber() -> String{
        var wholePlateNumber = ""
        for label in carPlateBtn.labelArray{
            if label.text != nil{
                wholePlateNumber.append(label.text!)
            }
        }
        return wholePlateNumber
    }
    
    // MARK:
    // MARK: 代理方法 监听点击 赋值
    func XNKeyboardViewMethod(_ title: String) {
        
        var number = 1
        
        for i in carPlateBtn.labelArray {
            
            // 当输入到最后一个的时候 让其不被删除 可以赋值
            if number == carPlateBtn.labelArray.count {
                
                i.text = title
                
                return
                
            }
            
            if i.text == nil {
                
                i.text = title
                
                return
            }
            
            number += 1
        }
        
        
    }
    
    
    // MARK:
    // MARK: 代理方法 删除
    /// 代理方法 删除
    func XNKeyboardViewDeleteMethod() {
        
        // 递减操作
        for i in carPlateBtn.labelArray.reversed() {
            
            // 判断是不是中文
            if i.text?.xnIsChinese() == true {
                
                // 删除字符
                i.text = nil;
                
                //  显示出 汉字键盘
                keyboardView.keyboardViewToNumberAndGrapheme.alpha = 0
                
                return;
            }
            
            if i.text != nil {
                
                i.text = nil;
                
                return;
            }
        }
        
        
    }
    
    // MARK:
    // MARK: 点击了对勾
    func XNKeyboardViewRightMethod() {
        // 文本框的隐藏
        keyboardViewShowOrHidden(false)
    }
}
