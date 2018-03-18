//
//  AppDelegate.swift
//  XHWLHouseOwner
//
//  Created by 柳玉豹 on 2017/8/10.
//  Copyright © 2017年 xinghaiwulian. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import WilddogCore
import WilddogAuth
import WilddogSync
import WilddogVideoBase
import WilddogVideoCall
//import WilddogWebRTC

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate, WXApiDelegate, XHWLNetworkDelegate{
    
    var window: UIWindow?
//    var isFirstLogin = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        launchAnimation()
        IQKeyboardManager.sharedManager().enable = true
        
        self.configureMCU()
        setupJPush(launchOptions)
        WXApi.registerApp(WX_APPID)
        TencentOAuth(appId: "1106505226", andDelegate: nil)
        self.initWilddogAuth()
        self.requestAuthor(launchOptions)
        
        //设置小红点提示为0
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        //如果有user，即存在token，直接登录
        if UserDefaults.standard.object(forKey: "user") != nil{
            //取出user的信息
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            let params = ["token":userModel?.sysAccount.token as! String]
            XHWLNetwork.sharedManager().postInfoByToken(params as NSDictionary, self)
        }
        
        return true
    }
    
    //播放启动画面动画
    func launchAnimation() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        
        
        if let img = splashImageForOrientation(orientation: statusBarOrientation,
                                               size: UIScreen.main.bounds.size) {
            //获取启动图片
            let launchImage = UIImage(named: img)
            let launchview = UIImageView(frame: UIScreen.main.bounds)
            launchview.image = launchImage
            //将图片添加到视图上
            //self.view.addSubview(launchview)
            let delegate = UIApplication.shared.delegate
            let mainWindow = delegate?.window
            mainWindow!!.addSubview(launchview)
            
            //播放动画效果，完毕后将其移除
            UIView.animate(withDuration: 1, delay: 1.5, options: .beginFromCurrentState,
                           animations: {
                            launchview.alpha = 0.0
                            launchview.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1.0)
            }) { (finished) in
                launchview.removeFromSuperview()
            }
        }
    }
    
    //获取启动图片名（根据设备方向和尺寸）
    func splashImageForOrientation(orientation: UIInterfaceOrientation, size: CGSize) -> String?{
        //获取设备尺寸和方向
        var viewSize = size
        var viewOrientation = "Portrait"
        
        if UIInterfaceOrientationIsLandscape(orientation) {
            viewSize = CGSize(width:size.height, height:size.width)
            viewOrientation = "Landscape"
        }
        
        //遍历资源库中的所有启动图片，找出符合条件的
        if let imagesDict = Bundle.main.infoDictionary  {
            if let imagesArray = imagesDict["UILaunchImages"] as? [[String: String]] {
                for dict in imagesArray {
                    if let sizeString = dict["UILaunchImageSize"],
                        let imageOrientation = dict["UILaunchImageOrientation"] {
                        let imageSize = CGSizeFromString(sizeString)
                        if imageSize.equalTo(viewSize)
                            && viewOrientation == imageOrientation {
                            if let imageName = dict["UILaunchImageName"] {
                                return imageName
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func initWilddogAuth(){
        let appID: String = WilddogAuthAppID
        let options = WDGOptions.init(syncURL: "https://\(appID).wilddogio.com")
        WDGApp.configure(with: options)
        do{
            try WDGAuth.auth()?.signOut()
        }catch{
        }
    }
    
    // MARK: - 后台不断循环
    var taskId:UIBackgroundTaskIdentifier = 0
    
    
//    // 获取当前控制器
//    func getCurrentVC() -> UIViewController {
//        let curVC = UIApplication.shared.keyWindow?.rootViewController
//        return curVC!
//    }
    
    func setupJPush(_ launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
        let entity:JPUSHRegisterEntity = JPUSHRegisterEntity()
        entity.types = Int(UInt8(JPAuthorizationOptions.alert.rawValue) | UInt8(JPAuthorizationOptions.badge.rawValue) | UInt8(JPAuthorizationOptions.sound.rawValue))
//        if UIDevice.current.systemVersion >= "8.0" {
//            // 可以添加自定义categories
//            // NSSet<UNNotificationCategory *> *categories for iOS10 or later
//            // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
//        }
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // Required
        // init Push
        // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
        // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
        JPUSHService.setup(withOption: launchOptions,
                           appKey: jPushAppKey,
                           channel: channel,
                           apsForProduction: false) // 0 (默认值)表示采用的是开发证书，1 表示采用生产证书发布应用
    }
    
    // MARK: - 推送
    // 注册APNs成功并上报DeviceToken 启动注册token
    // 请在AppDelegate.m实现该回调方法并添加回调方法中的代码
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /// Required - 注册 DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    // 实现注册APNs失败接口可选）
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    // MARK: - JPUSHRegisterDelegate
    
    // iOS 10 Support
    
    // MARK: - JPUSHRegisterDelegate
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        // Required 应用打开时收到推送
        "应用打开时收到推送".ext_debugPrintAndHint()
        let userInfo:NSDictionary  = notification.request.content.userInfo as NSDictionary
        print("\(userInfo)")
        
        if(notification.request.trigger is UNPushNotificationTrigger) {
            JPUSHService.handleRemoteNotification(userInfo as! [AnyHashable : Any])
        }
        
        if userInfo["msg"] != nil{
            let msgStr = userInfo["msg"] as! String
            if msgStr.range(of: "下线通知") != nil{
                "您的账号在另一台手机上登录！".ext_debugPrintAndHint()
                onLogout()
            }
        }
        
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue)) // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        // Required 应用在后台时收到推送
        let userInfo:NSDictionary = response.notification.request.content.userInfo as NSDictionary
        print("\(userInfo)")
        
        if(response.notification.request.trigger is UNPushNotificationTrigger) {
            JPUSHService.handleRemoteNotification(userInfo as! [AnyHashable : Any])
        }
        
        if userInfo["msg"] != nil{
            let msgStr = userInfo["msg"] as! String
            //推送为发送云对讲
            if msgStr.range(of: "向您发起了云对讲！") != nil{
//                "云对讲:\(msgStr)".ext_debugPrintAndHint()
                let vc = self.window?.rootViewController
                vc?.dismiss(animated: true, completion: nil)
                let callVC = vc?.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingCallVC") as! CloudTalkingCallVC
                vc?.present(callVC, animated: true, completion: nil)
                
                if userInfo["key"] != nil{
                    callVC.roomName = userInfo["key"] as! String
                }
                
                let mainVC = vc?.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC") as! MainViewController
                vc?.present(mainVC, animated: true, completion: nil)
            }else if msgStr.range(of: "下线通知") != nil{
                "您的账号在另一台手机上登录！".ext_debugPrintAndHint()
                onLogout()
            }else if msgStr.range(of: "门岗访客登记") != nil{
                "门岗访客登记:\(msgStr)".ext_debugPrintAndHint()
                let vc = self.window?.rootViewController
                vc?.dismiss(animated: true, completion: nil)
                
                
                let callVC = vc?.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingCallVC") as! CloudTalkingCallVC
                vc?.present(callVC, animated: true, completion: nil)
                
                if userInfo["key"] != nil{
                    callVC.roomName = userInfo["key"] as! String
                    callVC.callType = 2
                    callVC.wyAlias = userInfo["key"] as! String
                }
                
                let mainVC = vc?.storyboard?.instantiateViewController(withIdentifier: "CloudTalkingLoginVC") as! MainViewController
                vc?.present(mainVC, animated: true, completion: nil)
            }
        }
        
        completionHandler();  // 系统要求执行这个方法
    }
    
    // ios 9 系统提示
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Required, iOS 7 Support
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        print("\(userInfo)")
        let aps:NSDictionary = userInfo["aps"] as! NSDictionary
        "\(aps["alert"]!)".ext_debugPrintAndHint()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Required,For systems with less than or equal to iOS6
        JPUSHService.handleRemoteNotification(userInfo)
        print("\(userInfo)")
    }
    
    // 对接海康威视
    func configureMCU() {
        MCUVmsNetSDK.shareInstance().configMsp(withAddress: MSP_ADDRESS, port: MSP_PORT)
        //初始化SDK
        VP_InitSDK();
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self) || TencentOAuth.handleOpen(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("#############",url)
        return WXApi.handleOpen(url, delegate: self) || TencentOAuth.handleOpen(url)
//        return true
    }
    
    func onReq(_ req: BaseReq!) {
        print(req)
    }
    
    /**  微信回调  */
    func onResp(_ resp: BaseResp!) {
        
        if resp.errCode == 0 && resp.type == 0 {//授权成功
            let response = resp as! SendAuthResp
            switch wechatClickedSource{
            case 1:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WXLoginVCNotification"), object: response.code)
                break
            case 2:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WXPersonalInfoVCNotification"), object: response.code)
                break
            default:
                break
            }
            
        }
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set(true, forKey: "isAPPBackground")
        UserDefaults.standard.synchronize()
        
        
        //开启一个后台任务
        taskId = application.beginBackgroundTask(expirationHandler: {
            
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.handlerWithNote(_:)), name: NSNotification.Name(rawValue: "XHWLTalkNotification"), object: nil)
            //结束指定的任务
            application.endBackgroundTask(self.taskId)
        })
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
    }
    
    var count:Int = 0
    var isLogout:Bool = false
    
    func timerAction(_ timer:Timer) {
        count = count + 1
        
//        JPUSHService.deleteAlias(nil, seq: 0)
        
        if (count % 500 == 0) {
            let application:UIApplication = UIApplication.shared
            //结束旧的后台任务
            application.endBackgroundTask(taskId)
            
            //开启一个新的后台
            taskId = application.beginBackgroundTask(expirationHandler: nil)
            XHWLWilddogVideoManager.shared.config()
        }
    }
    
    //创建本地通知
    func requestAuthor(_ launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        if #available(iOS 8.0, *)
        {
            // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
            let setting:UIUserNotificationSettings = UIUserNotificationSettings.init(types:  UIUserNotificationType(rawValue: UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue), categories: nil)
            
            // 授权通知
            UIApplication.shared.registerUserNotificationSettings(setting)
        }
        
        if launchOptions != nil {
            // 处理退出后通知的点击，程序启动后获取通知对象，如果是首次启动还没有发送通知，那第一次通知对象为空，没必要去处理通知（如跳转到指定页面）
            guard let localNotifi = launchOptions![UIApplicationLaunchOptionsKey.localNotification] else {
                return
            }
        }
    }
    
    // MARK: - 处理后台和前台通知点击
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        print("\(String(describing: notification.alertTitle)) = \(String(describing: notification.userInfo))")
//        "接收到本地通知，唤醒进入前台".ext_debugPrintAndHint()
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //        NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:3000/update.do"];    //实现数据请求
        //        NSURLSession *updateSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        //        [updateSession dataTaskWithHTTPGetRequest:url
        //            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //            NSDictionary *messageInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //            NSLog(@"messageInfo:%@",messageInfo);
        //            completionHandler(UIBackgroundFetchResultNewData);
        //            }];
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UserDefaults.standard.set(false, forKey: "isAPPBackground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("%%%%%%%%%%%%test terminate@@@@@@@@@@")
        JPUSHService.deleteAlias(nil, seq: 0)
        JPUSHService.resetBadge()
        self.saveContext()
    }
    
    func wilddogLogin(_ token:String) {
        WDGAuth.auth()?.signIn(withCustomToken: token, completion: { (user, error) in
            if error == nil {
                // 获取 token
                user?.getTokenWithCompletion({ (idToken, error) in
                    // 配置 Video Initializer
                    WDGVideoInitializer.sharedInstance().userLogLevel = WDGVideoLogLevel.error
                    WDGVideoInitializer.sharedInstance().configure(withVideoAppId: VIDEO_APPID, token: idToken)
                    XHWLWilddogVideoManager.shared.config()
                    XHWLWilddogVideoManager.shared.saveUser(user!)
                    
//                    print("************uID: \(user?.uid)")
                    //                    let usersReference:WDGSyncReference = WDGSync.sync().reference().child("users")
                    //                    usersReference.child((user?.uid)!).setValue(true)
                    //                    usersReference.child((user?.uid)!).onDisconnectRemoveValue()
                })
            }else{
                print("********erroe********", error)
            }
            
        })
    }
    
    // 获取野狗云token
    func getWilddogToken(_ projectID:String, _ telephone:String) {
        if !projectID.isEmpty && !telephone.isEmpty {
            
            let uid = projectID + "-user-" + telephone
//            uid.ext_debugPrintAndHint()
            //            let uid = "123-user-18307478839"
//            let uid = "123-user-13123375305"
            //            let uid = "123-user-13714939868"
            XHWLNetwork.sharedManager().postWilddogTokenClick(["uid":uid], self)
        }
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "XHWLHouseOwner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func shared() ->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func onLogout() {
        JPUSHService.deleteAlias(nil, seq: 0)
        let data:NSData = UserDefaults.standard.object(forKey: "user") as! NSData
        let userModel:XHWLUserModel = XHWLUserModel.mj_object(withKeyValues: data.mj_JSONObject())
        let params = ["token": userModel.sysAccount.token]
        
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "projectList")
        UserDefaults.standard.removeObject(forKey: "roomList")
        UserDefaults.standard.synchronize()
        
        
        let window:UIWindow = UIApplication.shared.keyWindow!
        let loginVC = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        window.rootViewController = loginVC
        loginVC?.dismiss(animated: true, completion: nil)
    }
    
    //network代理的方法
    func requestSuccess(_ requestKey:NSInteger, _ response:[String : AnyObject]) {
        switch requestKey {
        case XHWLRequestKeyID.XHWL_WILDDOGTOKEN.rawValue:
            print("********************response:*********",response)
            let result:NSDictionary = response["result"] as! NSDictionary
            let token:String = result["token"] as! String
            UserDefaults.standard.set(token, forKey: "wilddogToken")
            wilddogLogin(token)
            break
        case XHWLRequestKeyID.XHWL_GETUSERINFOBYTOKEN.rawValue:
            switch response["errorCode"] as! Int {
            case 200:
                let window:UIWindow = UIApplication.shared.keyWindow!
                let tabBarVC = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
                self.window?.rootViewController = tabBarVC
                
                //从沙盒中获得curInfomodel，并且更新curProject
                var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
                var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
                //取出user的信息
                let data = UserDefaults.standard.object(forKey: "user") as? NSData
                let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
                self.getWilddogToken(curInfoModel?.curProject.projectCode as! String, userModel?.telephone as! String)
                break
            case 400, 401, 116:
                (response["message"] as! String).ext_debugPrintAndHint()
                onLogout()
                break
            default:
                break
            }
            break
            
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
        print("**********error*********",error)
    }
    
    
}

