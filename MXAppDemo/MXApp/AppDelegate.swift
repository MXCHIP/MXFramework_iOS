//
//  AppDelegate.swift
//  MXApp
//
//  Created by 华峰 on 2021/5/17.
//

import UIKit
import UserNotifications

@_exported import MXAPIManager
@_exported import MeshSDK
@_exported import MXURLRouter

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MXAPIManagerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        MXRouterConfig.registerRouter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SDKInitialization), name: NSNotification.Name(rawValue: "MXNotificationInitSDK"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startSteup), name: NSNotification.Name(rawValue: "MXNotificationHostSteup"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signedIn(notification:)), name: NSNotification.Name(rawValue: "MXNotificationUserSignedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signedOut(notification:)), name: NSNotification.Name(rawValue: "MXNotificationUserSignedOut"), object: nil)
        
        //icon角标数字清0
        UIApplication.shared.applicationIconBadgeNumber = 0
        if MXCountryManage.shard.currentCountry == nil,
           let china = MXCountryManage.defaultCountry() {
            MXCountryManage.shard.currentCountry = china
        }
        self.startSteup()
        
        if let token = MXAccountModel.shared.token, token.count > 0 {
            self.signIned(with: token)
        } else {
            let nav = UINavigationController(rootViewController: MXLaunchedPage())
            nav.navigationBar.isHidden = true
            self.window?.rootViewController = nav
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        mxAppLog("收到APNS消息：\(userInfo)")
        completionHandler(.newData)
    }
    
    @objc func startSteup() {
        
        MXAPIManager.shared.config(MXAppConfig.MXHost, appId: MXAppConfig.MXAppId, appSecert: MXAppConfig.MXAppSecert)
        MXAPIManager.shared.delegate = self
        MXAPIManager.shared.showLog()
        MXAPIManager.shared.update(language: MXAccountModel.shared.language)

        self.SDKInitialization()
    }
    
    @objc func SDKInitialization() {
        // MesshSDK
        MeshSDK.sharedInstance.setup()
        //下载Mesh物模型映射数据
        MXMeshManager.shard.downloadDeviceAttrConfig()

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //切后台断开mesh，避免切后台设备一直被连的问题
        //MeshSDK.sharedInstance.disconnect()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    // 登录成功
    @objc func signedIn(notification: NSNotification) -> Void {
        guard let userInfo = notification.userInfo,
              let token = userInfo["token"] as? String else {
                  MXToastHUD.dismiss()
                  return
              }
        
        MXAccountModel.shared.account = userInfo["account"] as? String
        
        self.signIned(with: token)
    }
    
    func signIned(with token: String) {
        
        MeshSDK.sharedInstance.disconnect()
        
        MXAPIManager.shared.update(token: token)
        MXAccountModel.shared.signIn(with: token)
        
        MXMeshManager.shard.resetMeshNetwork()
        //MXHomeManager.shard.loadCacheInfo()
        
        let mainView = MXHomeRoomPage()
        let nav = MXNavigationController(rootViewController: mainView)
        nav.navigationBar.isHidden = true
        self.window?.rootViewController = nav
        
        MXWebSocketManager.shard.createWebScoketConnect()
    }
    
    // 退出登录
    @objc func signedOut(notification: NSNotification) -> Void {
        signOut()
    }
    
    func signOut() {
        MXAccountModel.shared.signOut()
        
        MeshSDK.sharedInstance.disconnect()
        MXHomeManager.shard.cleanCache()
        
        MXWebSocketManager.shard.disconnect()
        
        showSignInPage()
    }
    
    func mxRequestResult(code: Int, message: String?, data: Any?) {
        if code == 10403, MXAccountModel.shared.isSignedIn() {  //token失效
            MXToastHUD.dismiss()
            self.signOut()
        }
    }
    
    // 去登录
    func showSignInPage() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let mainWindow = appDelegate.window,
              let rootViewController = mainWindow.rootViewController else { return }
        if rootViewController is MXLaunchedPage {
            return
        }
        let nav = UINavigationController(rootViewController: MXLaunchedPage())
        nav.navigationBar.isHidden = true
        mainWindow.rootViewController = nav
    }
}
