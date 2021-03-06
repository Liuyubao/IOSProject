//
//  SpaceViewController.swift
//  XHWLHouseOwner
//                                            
//  Created by 柳玉豹 on 2017/8/17.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import Kingfisher
import CoreBluetooth
import ElasticTransition
import TransitionTreasury
import CoreBluetooth
import CardReaderSDK
import AVFoundation

class SpaceViewController:UIViewController, XHWLScanTestVCDelegate ,CBCentralManagerDelegate, CLLocationManagerDelegate, XHWLNetworkDelegate{
    weak var modalDelegate: ModalViewControllerDelegate?
    
    lazy var dismissGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(SpaceViewController.panDismiss(_:)))
        self.view.addGestureRecognizer(pan)
        return pan
    }()
    
    func panDismiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began :
            modalDelegate?.modalViewControllerDismiss(true, callbackData: nil)
        default : break
        }
    }
    
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var spaceBg: UIImageView!
    
    @IBOutlet weak var heartMessage: UILabel!
    @IBOutlet weak var todayTemperature: UILabel!
    @IBOutlet weak var weatherIV: UIImageView!
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    //单例模式
    static let shared = SpaceViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //开启定位
        loadLocation()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeUpGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        self.canSwipeUp = true
        /**
         开启摇动感应
         */
        UIApplication.shared.applicationSupportsShakeToEdit = true
    }
    
    
    //MARK: - 摇一摇开门
    /**
     开始摇动
     */
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
         print("开始摇动")
        XHWLSoundPlayer.playShakeSound()
    }
    
    /**
     取消摇动
     */
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("取消摇动")
    }
    
    /**
     摇动结束
     
     */
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("摇动结束")
        openDoorOneStep()
    }
    
    /// 中心者对象
    var central: CBCentralManager!
    
    //跳转到云瞳界面
    @IBAction func phoneCallBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FourMonitorsVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    //MARK: -2.检查设备自身（中心设备）支持的蓝牙状态
    // CBCentralManagerDelegate的代理方法
    
    /// 本地设备状态
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
            "请先开启您的蓝牙！".ext_debugPrintAndHint()
        case .poweredOn:
            openDoorOneStep()
            break
        }
    }
    
    //跳到4个主页
    @IBAction func upBtnClicked(_ sender: UIButton) {
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as? NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData?.mj_JSONObject())
        
        if (curInfoModel?.isFirstToFourFuncs)!{     //第一次进入4个功能页面
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
//            self.present(vc!, animated: true)
            self.view.window?.rootViewController = vc
            vc?.dismiss(animated: true, completion: nil)
            curInfoModel?.setValue(false, forKey: "isFirstToFourFuncs")
            //重新保存到沙盒
            curInfoData = curInfoModel?.mj_JSONData() as! NSData
            UserDefaults.standard.set(curInfoData, forKey: "curInfo")
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //释放回到chooseVC
    @IBAction func returnToChooseClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChooseDistrictVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true, completion: nil)
    }
    
    func respondToSwipeUpGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                if self.canSwipeUp!{
                    upBtnClicked(self.upBtn)
                }
                break
            default:
                break
            }
        }
    }
    
    //MARK: - 云对讲按钮
    @IBAction func cardBtnClicked(_ sender: UIButton) {
        //暂时跳到云对讲
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    //MARK: - 跳到扫一扫页面
    @IBAction func scanBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC") as! XHWLScanTestVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    // MARK: - 远程开门
    @IBAction func remoteOpenDoorBtnClicked(_ sender: UIButton) {
        let remoteOpenDoorVC = self.storyboard?.instantiateViewController(withIdentifier: "RemoteOpenDoorVC")
        //        let nav:UINavigationController = UINavigationController.init(rootViewController: remoteOpenDoorVC)
        remoteOpenDoorVC?.modalTransitionStyle = .crossDissolve
        self.present(remoteOpenDoorVC!, animated: true, completion: nil)
    }
    
    // MARK: 蓝牙一键开门模块
    class DeviceRecord {
        init(_ name: String, key: String, randomKey: Data, rssi: Int) {
            self.name = name
            self.key = key
            self.randomKey = randomKey
            self.rssi = rssi
        }
        
        var name: String
        var key: String
        var randomKey: Data
        var cardNo: Data?
        var rssi: Int
    }
    var curDevice:DeviceRecord? = nil          //当前要开的门
    
    //将扫描到的设备添加到scanedDevices中
    func scan(){
        CardReaderAPI.StartScan({ (adv) in
            print("*************adv",adv)
            //如果curDevice为空，将第一个蓝牙设备设置为curDevice
            if self.curDevice == nil{
                let device = DeviceRecord(adv.name, key: adv.key, randomKey: adv.randomKey, rssi: Int(adv.rssi))
                self.curDevice = device
            }else if Int(adv.rssi) > (self.curDevice?.rssi)!{
                //如果扫描到信号更强的设备，替换当前的设备
                let device = DeviceRecord(adv.name, key: adv.key, randomKey: adv.randomKey, rssi: Int(adv.rssi))
                self.curDevice = device
            }
        }, callback: {(err)->Void in
            if err != nil {
                err!.description!.ext_debugPrintAndHint()
                if err!.description! == "CanNotConnect"{
                    "无法连接".ext_debugPrintAndHint()
                    self.curDevice = nil
                }
                if err!.description! == "DisConnected"{
                    "断开连接".ext_debugPrintAndHint()
                    self.curDevice = nil
                }else{
                    "正在连接设备".ext_debugPrintAndHint()
                }
            }else{
                print("扫描结束")
            }
        })
    }
    
    //一键开门
    func openDoorOneStep(){
        //1、从蓝牙扫描得到的所有门中取信号强度rssi最强的一个
        scan()
        
        if self.curDevice == nil{
            "正在扫描设备".ext_debugPrintAndHint()
            return
        }
        
        let key = self.curDevice?.key
        let randomKey = self.curDevice?.randomKey
        
        
        //2、通过keyID到门的权限列表中进行匹配，得到该门的privateKey(也是connectionKey)，cardNo（也是openData）。
        //从沙盒中加载数据
        let projectListData = UserDefaults.standard.object(forKey: "allDoorList") as? NSData
        let projectListArray = XHWLDoorInfoModel.mj_objectArray(withKeyValuesArray: projectListData?.mj_JSONObject()) as? NSArray
        if projectListArray == nil || projectListArray?.count == 0{
            "您无授权门禁".ext_debugPrintAndHint()
            return
        }
        let openData = UserDefaults.standard.object(forKey: "openData") as! String
        
        for proj in projectListArray!{
            let curProj = proj as! XHWLDoorInfoModel
            print("选中的门id：",self.curDevice?.key)
            print("现在的门id：",curProj.keyID)
            if self.curDevice?.key as! String == curProj.keyID.lowercased(){
                //  从沙盒中获得curInfomodel
                var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
                var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
                let cardNO = self.hexStringToData(openData)
                let privateKey = self.hexStringToData(curProj.connectionKey as! String)
                // autoDisconnect: false，不自动断开连接，可以手动屌用Stop方法断开连接
                CardReaderAPI.OpenDoor(key!, randomKey: randomKey!, priviateKey: privateKey!, cardNO: cardNO!, timeOut: 4, autoDisconnect: true, callback: {(err) -> Void in
                    if err == nil {
                        //  开门成功动画
                        self.openDoorAnimation()
                        //  开门成功音效
                        XHWLSoundPlayer.playShakeSuccessfulSound()
                        //  self.noticeSuccess("开门成功")
                    }else{
                        if err!.description! == "CanNotConnect"{
                            "无法连接".ext_debugPrintAndHint()
                            self.curDevice = nil
                        }
                        if err!.description! == "DisConnected"{
                            "断开连接".ext_debugPrintAndHint()
                            self.curDevice = nil
                        }else{
                            "正在连接设备".ext_debugPrintAndHint()
                        }
                    }
                })
            }
        }
    }
    
    func hexStringToData(_ hex:String?) -> Data?{
        if hex != nil {
            let hexUp = hex!.uppercased()
            let len = hex!.lengthOfBytes(using: String.Encoding.utf8)
            if (len % 2) != 0{
                return Data()
            }
            
            let buff = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
            var tmp:UInt32 = 0
            var offset = 0
            var idx = 0
            for _ in 0..<(len/2){
                let sub = (hexUp as NSString).substring(with: NSMakeRange(offset, 2))
                Scanner(string: sub).scanHexInt32(&tmp)
                buff[idx] = UInt8(tmp)
                idx += 1
                offset += 2
            }
            return Data(bytes: UnsafePointer<UInt8>(buff),count:len/2)
        }else{
            return nil
        }
    }
    
    func openDoorAnimation(){
        let curVC = UIViewController.currentViewController()
        if !(curVC?.isKind(of: SpaceViewController))!{
            "开门成功".ext_debugPrintAndHint()
            return
        }
        
        self.view.bringSubview(toFront: self.spaceBg)
        YLGIFImage.setPrefetchNum(5)
        
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.url(forResource: "door4", withExtension: "gif")?.absoluteString as String!
        self.spaceBg.image = YLGIFImage(contentsOfFile: path!)
        self.spaceBg.startAnimating()
        
        //睡眠1.9s，
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(1.1)){
            self.spaceBg.frame = CGRect(x:0, y:0, width:Screen_width, height:Screen_height)
            self.spaceBg.stopAnimating()
            self.view.sendSubview(toBack: self.spaceBg)
            self.spaceBg.image = UIImage(named: "Space_SpaceBg")
            //self.noticeSuccess("开门成功")
        }
    }
    
    
    //蓝牙一键开门
    @IBAction func fingerPrintBtnClicked(_ sender: UIButton) {
        //初始化本地中心设备对象
        central = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    
    // MARK: - 扫一扫
    /**
     *  扫描代理的回调函数
     *
     设备二维码模板：
     {
     "utid":"XHWL",
     "type":"equipment",
     "code":"eq01"
     }
     园林绿植二维码模板：
     {
     "utid":"XHWL",
     "type":"plant",
     "code":"xxxxx"
     }
     *  @param strResult 返回的字符串
     */
    func returnResultString(strResult:String, block:((_ isSuccess:Bool)->Void))
    {
        print("\(strResult)")
        
        let dict:NSDictionary = strResult.dictionaryWithJSON()
        let utid:String = dict["utid"] as! String
        
        if utid.compare("XHWL").rawValue == 0 {
            block(true)
            
        } else {
            block(false)
        }
    }
    
    // MARK: - 引导页面
    
    var openOneStepImg:UIImageView?
    var toFourTabbarsImg:UIImageView?
    var canSwipeUp:Bool?
    
    //tap toFourTabbars的事件
    func tapToFourTabbarsGesture(sender: UITapGestureRecognizer){
        print("单击了第二张图片")
        toFourTabbarsImg?.removeFromSuperview()
        
        UserDefaults.standard.set(true, forKey:"notFirstGuideTwo")
        UserDefaults.standard.synchronize()
        self.canSwipeUp = true
    }
    
    //tap openOneStep的事件
    func tapOpenOneStepGesture(sender: UITapGestureRecognizer){
        print("单击了第一张图片")
        //删除openOneStepImg，
        openOneStepImg?.removeFromSuperview()
        
        //跳出toFourTabbarsImg
        toFourTabbarsImg = UIImageView(image: UIImage(named: "toFourTabbars"))
        self.view.addSubview(toFourTabbarsImg!)
        toFourTabbarsImg?.frame = CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height)
        
        //单击第二张图片的手势
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapToFourTabbarsGesture(sender:)))
        toFourTabbarsImg?.isUserInteractionEnabled = true
        toFourTabbarsImg?.addGestureRecognizer(tap2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "notFirstGuideTwo") == false{
            self.canSwipeUp = false
            //添加第一张图片
            openOneStepImg = UIImageView(image: UIImage(named: "openOneStep"))
            self.view.addSubview(openOneStepImg!)
            openOneStepImg?.frame = CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height)
            
            //单击第一张图片的手势
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapOpenOneStepGesture(sender:)))
            openOneStepImg?.isUserInteractionEnabled = true
            openOneStepImg?.addGestureRecognizer(tap1)
            
        }
    }
    
    
    //MARK: - 设置心情天气
    func onHeartWeather(_ response:[String : AnyObject]){
        //        print("%%%%%%%%response",response)
        if response["state"] as! Bool == true{
            let result = response["result"] as! NSDictionary
            let rows = result["rows"] as! NSArray
            let row = rows[0] as! NSDictionary
            let term = row["term"] as! String
            self.heartMessage.text = term
        }
    }
    
    //打开定位
    func loadLocation()
    {
        locationManager.delegate = self
        //定位方式
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距离
        locationManager.distanceFilter = 100
        
        
        //iOS8.0以上才可以使用
        //        if UIDevice.current.systemVersion >= "8.0" {
        //始终允许访问位置信息
        locationManager.requestAlwaysAuthorization()
        //使用应用程序期间允许访问位置数据
        locationManager.requestWhenInUseAuthorization()
        //        }
        //开启定位
        if (CLLocationManager.locationServicesEnabled())
        {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            print("定位开始")
        }
    }
    
    //获取定位信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //取得locations数组的最后一个
        let location:CLLocation = locations[locations.count-1]
        currentLocation = locations.last
        
        //判断是否为空
        if(location.horizontalAccuracy > 0){
            let lat = Double(String(format: "%.1f", location.coordinate.latitude))
            let long = Double(String(format: "%.1f", location.coordinate.longitude))
            print("纬度:\(long!)")
            print("经度:\(lat!)")
            LonLatToCity()
            //停止定位
            locationManager.stopUpdatingLocation()
        }
        
        //获取最新的坐标
        let currLocation:CLLocation = locations.last!
        
        let text:String = "经度：\(currLocation.coordinate.longitude)" +
            "纬度：\(currLocation.coordinate.latitude)" +
            "海拔：\(currLocation.altitude)" +
            "水平精度：\(currLocation.horizontalAccuracy)" +
            "垂直精度：\(currLocation.verticalAccuracy)" +
            "方向：\(currLocation.course)" +
        "速度：\(currLocation.speed)"
        
    }
    
    //出现错误
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print(error ?? "")
    }
    
    ///将经纬度转换为城市名
    func LonLatToCity() {
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation!, completionHandler: { (placemark, error) -> Void  in
            
            
            if(error == nil)
            {
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                //城市
                let city: String = (mark.addressDictionary! as NSDictionary).value(forKey: "City") as! String
                //国家
                let country: String = (mark.addressDictionary! as NSDictionary).value(forKey: "Country") as! String
                //国家编码
                let CountryCode: String = (mark.addressDictionary! as NSDictionary).value(forKey: "CountryCode") as! String
                //街道位置
                let FormattedAddressLines: String = ((mark.addressDictionary! as NSDictionary).value(forKey: "FormattedAddressLines") as AnyObject).firstObject as! String
                //具体位置
                let Name: String = (mark.addressDictionary! as NSDictionary).value(forKey: "Name") as! String
                //省
                var State: String = (mark.addressDictionary! as NSDictionary).value(forKey: "State") as! String
                //区
                let SubLocality: String = (mark.addressDictionary! as NSDictionary).value(forKey: "SubLocality") as! String
                
                
                //如果需要去掉“市”和“省”字眼
                
                //                State = State.replacingOccurrences(of: "省", with: "")
                //
                //                let citynameStr = city.replacingOccurrences(of: "市", with: "")
                
                let address:String = "\(city)"
                //                let address:String = "\(State)\(city)\(SubLocality)  \(Name)"
                
                
                self.loadData(city: city)
            }
            else
            {
                print(error ?? "")
            }
        })
    }
    
    func loadData(city:String) {
        //    https://free-api.heweather.com/v5/weather?city=深圳&key=3e6338eef8c947dd89f4ffebbf580778
        let params:[String: String] = ["city" : city,
                                       "key" : WeatherKey,
                                       ]
        
        //            http://192.168.1.154:8080/v1/appBusiness/scan/qrcode
        Alamofire.request("https://free-api.heweather.com/v5/weather", method: .post ,parameters: params).responseJSON{response in
            if response.value == nil{
                "无法访问天气服务器".ext_debugPrintAndHint()
                return
            }
            let jsonDict = response.value as! NSDictionary
            
            
            let ary:NSArray = jsonDict["HeWeather5"] as! NSArray
            let HeWeather5:NSDictionary = ary[0] as! NSDictionary
            
            if let aqi:NSDictionary = HeWeather5["aqi"] as! NSDictionary{
                let city:NSDictionary = aqi["city"] as! NSDictionary
                let dailyAry:NSArray = HeWeather5["daily_forecast"] as! NSArray // 每天
                let daily_forecast:NSDictionary = dailyAry[0] as! NSDictionary // 每天
                let hourlyAry:NSArray = HeWeather5["hourly_forecast"] as! NSArray // 每小时
                //                let hourly_forecast:NSDictionary = hourlyAry[0] as! NSDictionary // 每小时
                let now:NSDictionary = HeWeather5["now"] as! NSDictionary // 当前
                let tmp:NSDictionary = daily_forecast["tmp"] as! NSDictionary // 当天的温度
                let cond:NSDictionary = now["cond"] as! NSDictionary
                
                // 气温
                let currentTmp:String = now["tmp"] as! String
                // 空气湿度 相对湿度
                let hum:String = "\(now["hum"] as! String) %"
                // PM2.5
                let pm25:String = city["pm25"] as! String
                // 空气质量实时指数
                let currentAqi:String = city["aqi"] as! String
                // 温度
                let tmp_max:String = tmp["max"] as! String
                let tmp_min:String = tmp["min"] as! String
                // 多云
                let txt:String = cond["txt"] as! String // code
                let code:String = cond["code"] as! String // https://cdn.heweather.com/cond_icon/100.png http://localhost:8080/ssh/resource/images/weather/100.png
                
                let iconStr:String = "http://202.105.104.105:8006/ssh/resource/images/weather/\(code).png"
                // 污染程度
                let qlty:String = city["qlty"] as! String
                
                let text = "当前气温：\(currentTmp) \n 当前空气湿度：\(hum) \n PM2.5: \(pm25) \n 空气质量实时指数:\(currentAqi) \n 当日温度：\(tmp_min)-\(tmp_max) \n 多云图案：\(txt) 空气质量：\(qlty) "
                print("\(text)")
                
                let weatherParams = ["code": code]
                
                //请求心情天气
                XHWLNetwork.sharedManager().postHeartWeather(weatherParams as NSDictionary, self)
                //设置心情图片
                let url = URL(string: iconStr)
                self.weatherIV.kf.setImage(with: url)
                self.todayTemperature.text = "\(tmp_min)-\(tmp_max)℃"
            }
        }
    }
    
    
    
    
    //MARK: - network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_HEARTWEATHER.rawValue:
            onHeartWeather(response)
            break
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        "请求失败".ext_debugPrintAndHint()
    }


}
