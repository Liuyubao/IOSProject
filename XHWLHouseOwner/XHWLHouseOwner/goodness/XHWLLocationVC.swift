//
//  XHWLLocationVC.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/9/1.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import CoreLocation
import Kingfisher

//NSLocationWhenInUseDescription ：允许在前台获取GPS的描述
//NSLocationAlwaysUsageDescription ：允许在后台获取GPS的描述

class XHWLLocationVC: UIViewController , CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var textLabel :UILabel?
    var weathIV:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = UIColor.white
        textLabel = UILabel()
        textLabel?.frame = CGRect(x: 10, y: 100, width: self.view.bounds.size.width-20, height: 200)
        textLabel?.numberOfLines = 0;
        textLabel?.textColor = UIColor.black
        self.view.addSubview(textLabel!)
        
        weathIV = UIImageView()
        weathIV.frame = CGRect(x:20, y:350, width:50, height:50)
        self.view.addSubview(weathIV)
        
        //开启定位
        loadLocation()

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

        self.textLabel?.text = text
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
                
                self.textLabel?.text = address
                
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
        
//        XHWLHttpTool.sharedInstance.postHttpTool(url: "https://free-api.heweather.com/v5/weather", parameters: params, success: { (response) in
//            print("JSON: \(response)")
//            
//            let jsonDict = response as! NSDictionary
//            
//            let ary:NSArray = jsonDict["HeWeather5"] as! NSArray
//            let HeWeather5:NSDictionary = ary[0] as! NSDictionary
//            let aqi:NSDictionary = HeWeather5["aqi"] as! NSDictionary
//            let city:NSDictionary = aqi["city"] as! NSDictionary
//            let dailyAry:NSArray = HeWeather5["daily_forecast"] as! NSArray // 每天
//            let daily_forecast:NSDictionary = dailyAry[0] as! NSDictionary // 每天
//            let hourlyAry:NSArray = HeWeather5["hourly_forecast"] as! NSArray // 每小时
//            let hourly_forecast:NSDictionary = hourlyAry[0] as! NSDictionary // 每小时
//            let now:NSDictionary = HeWeather5["now"] as! NSDictionary // 当前
//            let tmp:NSDictionary = daily_forecast["tmp"] as! NSDictionary // 当天的温度
//            let cond:NSDictionary = now["cond"] as! NSDictionary
//            
//            // 气温
//            let currentTmp:String = now["tmp"] as! String
//            // 空气湿度 相对湿度
//            let hum:String = "\(now["hum"] as! String) %"
//            // PM2.5
//            let pm25:String = city["pm25"] as! String
//            // 空气质量实时指数
//            let currentAqi:String = city["aqi"] as! String
//            // 温度
//            let tmp_max:String = tmp["max"] as! String
//            let tmp_min:String = tmp["min"] as! String
//            // 多云
//            let txt:String = cond["txt"] as! String // code
//            let code:String = cond["code"] as! String // https://cdn.heweather.com/cond_icon/100.png
//            let iconStr:String = "https://cdn.heweather.com/cond_icon/\(code).png"
//            // 污染程度
//            let qlty:String = city["qlty"] as! String
//            
//            let text = "当前气温：\(currentTmp) \n 当前空气湿度：\(hum) \n PM2.5: \(pm25) \n 空气质量实时指数:\(currentAqi) \n 当日温度：\(tmp_min)-\(tmp_max) \n 多云图案：\(txt) 空气质量：\(qlty) "
//            print("\(text)")
//            
//            self.textLabel?.text = text
//            
//            let url = URL(string: iconStr)
//            self.weathIV.kf.setImage(with: url)
//            
//         }) { (error) in
//            
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
