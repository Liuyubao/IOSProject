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
            guard sender.translation(in: view).y < 0 else {
                break
            }
            modalDelegate?.modalViewControllerDismiss(true, callbackData: nil)
        default : break
        }
    }
    
    @IBAction func remoteOpenDoorBtnClicked(_ sender: UIButton) {
        let remoteOpenDoorVC = RemoteOpenDoorWebVC()
        remoteOpenDoorVC.remoteOpenDoor("18320480001", "123", "测试1")
        let nav:UINavigationController = UINavigationController.init(rootViewController: remoteOpenDoorVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var spaceBg: UIImageView!
    
    @IBOutlet weak var heartMessage: UILabel!
    @IBOutlet weak var todayTemperature: UILabel!
    @IBOutlet weak var weatherIV: UIImageView!
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    
    
    
    //network代理的方法
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
    
    //设置心情天气
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
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return [:]
    }
    
    func loadData(city:String) {
        //    https://free-api.heweather.com/v5/weather?city=深圳&key=3e6338eef8c947dd89f4ffebbf580778
        let params:[String: String] = ["city" : city,
                                       "key" : WeatherKey,
                                       ]
        
        //            http://192.168.1.154:8080/v1/appBusiness/scan/qrcode
        Alamofire.request("https://free-api.heweather.com/v5/weather", method: .post ,parameters: params).responseJSON{response in
//            print("#############weather",response)
            
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
                XHWLNetwork.shared.postHeartWeather(weatherParams as NSDictionary, self)
                //设置心情图片
                let url = URL(string: iconStr)
                self.weatherIV.kf.setImage(with: url)
                self.todayTemperature.text = "\(tmp_min)-\(tmp_max)℃"
            }
        }
    }
    
    //暂时远程开门
    @IBAction func fingerPrintBtnClicked(_ sender: UIButton) {
        self.view.bringSubview(toFront: self.spaceBg)
        
        YLGIFImage.setPrefetchNum(5)
        
        // Do any additional setup after loading the view, typically from a nib.
        let path = Bundle.main.url(forResource: "door4", withExtension: "gif")?.absoluteString as String!
        self.spaceBg.image = YLGIFImage(contentsOfFile: path!)
        self.spaceBg.startAnimating()
        
        Alamofire.request("http://192.168.2.101:9002/test/openDoor").responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
        //睡眠1.9s，
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(1.1)){
            self.spaceBg.stopAnimating()
            self.view.sendSubview(toBack: self.spaceBg)
            self.spaceBg.image = UIImage(named: "Space_SpaceBg")
        }
        
    }
    
    @IBAction func personBtnClicked(_ sender: UIButton) {
        
    }
    
    /// 中心者对象
    var central: CBCentralManager!
    
    @IBAction func phoneCallBtnClicked(_ sender: UIButton) {
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "bluetoothVC") as! BluetoothVC
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
            break
        }
        
    }
    
    
    //云对讲按钮
    @IBAction func cardBtnClicked(_ sender: UIButton) {
        //暂时跳到云对讲
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC")
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
    
    

    //跳到扫一扫页面
    @IBAction func scanBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "XHWLScanTestVC") as! XHWLScanTestVC
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    //跳到4个主页
    @IBAction func upBtnClicked(_ sender: UIButton) {
        var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as? NSData
        var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData?.mj_JSONObject())
        
        if (curInfoModel?.isFirstToFourFuncs)!{     //第一次进入4个功能页面
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(vc!, animated: true)
            self.view.window?.rootViewController = vc
            curInfoModel?.setValue(false, forKey: "isFirstToFourFuncs")
            //重新保存到沙盒
            curInfoData = curInfoModel?.mj_JSONData() as! NSData
            UserDefaults.standard.set(curInfoData, forKey: "curInfo")
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    var transition = ElasticTransition()
    let rgr = UIScreenEdgePanGestureRecognizer()
    
    func setTransition(){
        // customization
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0
        transition.damping = 0
        transition.transformType = .subtle
        
//        transition.overlayColor = UIColor(white: 0, alpha: 0.5)
//        transition.shadowColor = UIColor(white: 0, alpha: 0.5)
        
        rgr.addTarget(self, action: #selector(SpaceViewController.handleRightPan(_:)))
        rgr.edges = .right
        view.addGestureRecognizer(rgr)
    }
    func handleRightPan(_ pan:UIPanGestureRecognizer){
        if pan.state == .began{
            transition.edge = .right
            transition.startInteractiveTransition(self, segueIdentifier: "presentProjectList", gestureRecognizer: pan)
        }else{
            _ = transition.updateInteractiveTransition(gestureRecognizer: pan)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if vc.isKind(of: ChooseDistrictViewController){
            vc.transitioningDelegate = transition
            vc.modalPresentationStyle = .custom
        }
    }
    
    //释放回到chooseVC
    @IBAction func returnToChooseClicked(_ sender: UIButton) {
        transition.edge = .right
        transition.startingPoint = sender.center
        performSegue(withIdentifier: "presentProjectList", sender: self)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //开启定位
        loadLocation()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeUpGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        self.canSwipeUp = true
        self.setTransition()    //初始化transition
    }


}
