//
//  GoodnessScrollVC.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/9/15.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import CoreLocation
import Kingfisher
import Alamofire

//NSLocationWhenInUseDescription ：允许在前台获取GPS的描述
//NSLocationAlwaysUsageDescription ：允许在后台获取GPS的描述

class GoodnessScrollVC: UIViewController,UIScrollViewDelegate ,CLLocationManagerDelegate, XHWLNetworkDelegate{
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var page2: UIView!
    var page1: UIView?
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    @IBOutlet weak var weatherImg: UIImageView!
    
    @IBOutlet weak var curTemp: UILabel!
    @IBOutlet weak var curHuminity: UILabel!
    @IBOutlet weak var todayTemp: UILabel!
    @IBOutlet weak var pm25: UILabel!
    @IBOutlet weak var airQuality: UILabel!
    @IBOutlet weak var airRank: UILabel!
    @IBOutlet weak var moodDescription: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置scrollView的内容总尺寸
        scrollView.contentSize = CGSize(
            width: CGFloat(self.view.bounds.width) * 2,
            height: 0
        )
        //关闭滚动条显示
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.scrollsToTop = false
        //协议代理，在本类中处理滚动事件
        scrollView.delegate = self
        //滚动时只能停留到某一页
        scrollView.isPagingEnabled = true
        
        page1 = UIView()
        let imageView1 = UIImageView(image: UIImage(named:"Goodness_waterQuality"))
        page1?.addSubview(imageView1)
        
        page1?.frame = CGRect(x: 0, y: 0, width: bgView.frame.width, height: bgView.frame.height)
        page2.frame = CGRect(x: bgView.frame.width, y: 0, width: bgView.frame.width, height: bgView.frame.height)
        
        scrollView.addSubview(page1!)
        scrollView.addSubview(page2)
        
        //页控件属性
        pageControl.backgroundColor = UIColor.clear
        //设置页控件点击事件
        pageControl.addTarget(self, action: #selector(pageChanged(_:)),
                              for: UIControlEvents.valueChanged)
        
        //开启定位
        loadLocation()
        
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 10;// 字体的行间距
        
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
                
                let jsonDict = response.value as! NSDictionary
                
                let ary:NSArray = jsonDict["HeWeather5"] as! NSArray
                let HeWeather5:NSDictionary = ary[0] as! NSDictionary
                let aqi:NSDictionary = HeWeather5["aqi"] as! NSDictionary
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
                let code:String = cond["code"] as! String // https://cdn.heweather.com/cond_icon/100.png
                let iconStr:String = "https://cdn.heweather.com/cond_icon/\(code).png"
                // 污染程度
                let qlty:String = city["qlty"] as! String
                
                let text = "当前气温：\(currentTmp) \n 当前空气湿度：\(hum) \n PM2.5: \(pm25) \n 空气质量实时指数:\(currentAqi) \n 当日温度：\(tmp_min)-\(tmp_max) \n 多云图案：\(txt) 空气质量：\(qlty) "
                print("\(text)")
                self.curTemp.text = currentTmp
                self.curHuminity.text = hum
                self.todayTemp.text = "\(tmp_min)-\(tmp_max)"
                self.pm25.text = pm25
                self.airQuality.text = currentAqi
                self.airRank.text = qlty
                //设置心情图片
                let url = URL(string: iconStr)
                self.weatherImg.kf.setImage(with: url)
            
                let weatherParams = ["code": code]
            
                //请求心情天气
                XHWLNetwork.sharedManager().postHeartWeather(weatherParams as NSDictionary, self)
                
            }
        
    }
    
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
    
    //推送
    func onHeartWeather(_ response:[String : AnyObject]){
        print("%%%%%%%%response",response)
        if response["state"] as! Bool == true{
            let result = response["result"] as! NSDictionary
            let rows = result["rows"] as! NSArray
            let row = rows[0] as! NSDictionary
            let description = row["description"] as! String
            self.moodDescription.text = "心情天气：\n\(description)"
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
        var frame = self.bgView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        //展现当前页面内容
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        scrollView.contentSize = CGSize(
            width: CGFloat(self.bgView.frame.width) * 2,
            height: 0
        )
        
        page1?.frame = CGRect(x: 0, y: 0, width: bgView.frame.width, height: bgView.frame.height)
        page2.frame = CGRect(x: bgView.frame.width, y: 0, width: bgView.frame.width, height: bgView.frame.height)
        
        
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
