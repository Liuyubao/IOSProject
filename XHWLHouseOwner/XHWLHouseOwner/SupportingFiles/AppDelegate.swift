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
        IQKeyboardManager.sharedManager().enable = true
        self.configureMCU()
        setupJPush(launchOptions)
        WXApi.registerApp(WX_APPID)
        TencentOAuth(appId: "1106505226", andDelegate: nil)
        self.initWilddogAuth()
        
        //如果有user，即存在token，直接登录
        if UserDefaults.standard.object(forKey: "user") != nil{
            let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC")
            self.window?.rootViewController = tabBarVC
            
            //从沙盒中获得curInfomodel，并且更新curProject
            var curInfoData = UserDefaults.standard.object(forKey: "curInfo") as! NSData
            var curInfoModel = XHWLCurrentInfoModel.mj_object(withKeyValues: curInfoData.mj_JSONObject())
            //取出user的信息
            let data = UserDefaults.standard.object(forKey: "user") as? NSData
            let userModel = XHWLUserModel.mj_object(withKeyValues: data?.mj_JSONObject())
            if #available(iOS 10.0, *) {
                AppDelegate.shared().getWilddogToken(curInfoModel?.curProject.projectCode as! String, userModel?.telephone as! String)
            } else {
                // Fallback on earlier versions
            }
        }
        return true
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
    
    // 获取当前控制器
    func getCurrentVC() -> UIViewController {
//        if self.window?.rootViewController is LoginViewController {
//            return self.window?.rootViewController as! LoginViewController
//        }
//        else if self.window?.rootViewController is XHWLTabBarViewController {
//            let tabbar:XHWLTabBarViewController = self.window?.rootViewController as! XHWLTabBarViewController
//
//            let selectNav = tabbar.viewControllers![tabbar.selectedIndex]
//            return selectNav
//////
//////            print("\(selectNav)")
//////
//////            if selectNav is XHWLNavigationController {
//////                let nav:XHWLNavigationController = selectNav as! XHWLNavigationController
//////                let vc:UIViewController = nav.topViewController as! UIViewController
//////
//////                print("\(vc)")
//////
//////                return vc
//////            }
////            return UIViewController()
//        }
        
        return (self.window?.rootViewController)!
        
        
//        let rootVC = self.window?.rootViewController
//        let vc = rootVC?.storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
//        return vc!
    }
    
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
                           apsForProduction: true) // 0 (默认值)表示采用的是开发证书，1 表示采用生产证书发布应用
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
        "应用在后台时收到推送".ext_debugPrintAndHint()
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
        return true
    }
    
    func onReq(_ req: BaseReq!) {
        print(req)
    }
    
    /**  微信回调  */
    func onResp(_ resp: BaseResp!) {
        print("*****resp*********",resp)
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
                    
                    print("************uID: \(user?.uid)")
                    //                    let usersReference:WDGSyncReference = WDGSync.sync().reference().child("users")
                    //                    usersReference.child((user?.uid)!).setValue(true)
                    //                    usersReference.child((user?.uid)!).onDisconnectRemoveValue()
                })
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
            XHWLNetwork.shared.postWilddogTokenClick(["uid":uid], self)
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
        default:
            break
        }
    }
    
    //network代理的方法
    func requestFail(_ requestKey:NSInteger, _ error:NSError) {
    }
    
    
}

