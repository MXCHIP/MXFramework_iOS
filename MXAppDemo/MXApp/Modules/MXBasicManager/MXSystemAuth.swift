//
//  MXPermissionsManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/19.
//

import Photos
import Alamofire
import Photos
import UserNotifications
import Contacts
//蓝牙
import CoreBluetooth

/// 防止获取无效 计步器
//private let cmPedometer = CMPedometer()

public typealias AuthClouser = ((Bool)->())

/**
 escaping 逃逸闭包的生命周期：
 
 1，闭包作为参数传递给函数；
 
 2，退出函数；
 
 3，闭包被调用，闭包生命周期结束
 即逃逸闭包的生命周期长于函数，函数退出的时候，逃逸闭包的引用仍被其他对象持有，不会在函数结束时释放
 经常使用逃逸闭包的2个场景：
 异步调用: 如果需要调度队列中异步调用闭包，比如网络请求成功的回调和失败的回调，这个队列会持有闭包的引用，至于什么时候调用闭包，或闭包什么时候运行结束都是不确定，上边的例子。
 存储: 需要存储闭包作为属性，全局变量或其他类型做稍后使用，例子待补充
 */
public class MXSystemAuth: NSObject {
    
    public static let shard = MXSystemAuth()
    var cbPermissCallback : AuthClouser?
    var locationPermissCallback : AuthClouser?
    
    public var locationAuthManager = CLLocationManager()
    public var cbManager = CBCentralManager()
    var cbStatus : Int  = 0 //0未获取到，1打开，2失败
    
    public override init() {
        super.init()
        self.cbManager.delegate = self
        self.locationAuthManager.delegate = self
    }
    
    /**
     联网权限
     
     - parameters: action 权限结果闭包
     */
    public class func authNetwork(clouser: @escaping AuthClouser) {
        
        let reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")
        switch reachabilityManager?.status {
        case .reachable(.cellular):
            clouser(true)
        case .reachable(.ethernetOrWiFi):
            clouser(true)
        case .none:
            clouser(false)
        case .notReachable:
            clouser(false)
        case .unknown:
            clouser(false)
        default:
            clouser(false)
        }
    }
    
    /**
     相机权限
     
     - parameters: action 权限结果闭包
     */
    public class func authCamera(clouser: @escaping AuthClouser) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .restricted:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    /**
     相册权限
     
     - parameters: action 权限结果闭包
     */
    public class func authPhotoLib(clouser: @escaping AuthClouser) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .restricted:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    /**
     麦克风权限
     
     - parameters: action 权限结果闭包
     */
    public class func authMicrophone(clouser: @escaping AuthClouser) {
        let authStatus = AVAudioSession.sharedInstance().recordPermission
        switch authStatus {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (result) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .granted:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    /**
     定位权限
     
     - parameters: action 权限结果闭包(有无权限,是否第一次请求权限)
     */
    public class func authLocation(clouser: @escaping AuthClouser) {
        MXSystemAuth.shard.locationPermissCallback = nil
        var authStatus = CLLocationManager.authorizationStatus()
        if #available(iOS 14.0, *) {
            authStatus = MXSystemAuth.shard.locationAuthManager.authorizationStatus
        }
        switch authStatus {
        case .notDetermined:
            //由于IOS8中定位的授权机制改变 需要进行手动授权
            MXSystemAuth.shard.locationAuthManager.requestWhenInUseAuthorization()
            MXSystemAuth.shard.locationPermissCallback = clouser
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorizedAlways:
            clouser(true)
        case .authorizedWhenInUse:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    /**
     蓝牙权限
     
     - parameters: action 权限结果闭包(有无权限,是否第一次请求权限)
     */
     public class func authBluetooth(clouser: @escaping AuthClouser) {
        MXSystemAuth.shard.cbPermissCallback = nil
        var authStatus = MXSystemAuth.shard.cbManager.authorization
        if #available(iOS 13.1, *) {
            authStatus = CBCentralManager.authorization
        }
        switch authStatus {
        case .notDetermined:
            MXSystemAuth.shard.cbManager.scanForPeripherals(withServices: nil, options: nil)
            MXSystemAuth.shard.cbManager.stopScan()
            MXSystemAuth.shard.cbPermissCallback = clouser
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .allowedAlways:
            if MXSystemAuth.shard.cbStatus == 0 {
                MXSystemAuth.shard.cbPermissCallback = clouser
            } else {
                clouser(true && MXSystemAuth.shard.cbStatus == 1)
            }
        default:
            clouser(false)
        }
    }
    
    /**
     推送权限
     
     - parameters: action 权限结果闭包
     */
    public class func authNotification(clouser: @escaping AuthClouser){
        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
            switch setttings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (result, error) in
                    if result{
                        DispatchQueue.main.async {
                            clouser(true)
                        }
                    }else{
                        DispatchQueue.main.async {
                            clouser(false)
                        }
                    }
                }
            case .denied:
                clouser(false)
            case .authorized:
                clouser(true)
            case .provisional:
                clouser(true)
            default:
                clouser(false)
            }
        }
    }
    
    /**
     通讯录权限
     
     - parameters: action 权限结果闭包
     */
    public class func authContacts(clouser: @escaping AuthClouser){
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authStatus {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { (result, error) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    /**
     系统设置
     
     - parameters: urlString 可以为系统,也可以为微信:weixin://、QQ:mqq://
     - parameters: action 结果闭包
     */
    public class func authSystemSetting(urlString :String?, clouser: @escaping AuthClouser) {
        var url: URL
        if (urlString != nil) && urlString?.count ?? 0 > 0 {
            url = URL(string: urlString!)!
        }else{
            url = URL(string: UIApplication.openSettingsURLString)!
        }
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (result) in
                if result{
                    clouser(true)
                }else{
                    clouser(false)
                }
            }
        }else{
            clouser(false)
        }
    }
}

extension MXSystemAuth: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.cbStatus = 1
        } else {
            self.cbStatus = 2
        }
        
        var authStatus = MXSystemAuth.shard.cbManager.authorization
        if #available(iOS 13.1, *) {
            authStatus = CBCentralManager.authorization
        }
        self.cbPermissCallback?(authStatus == .allowedAlways && self.cbStatus == 1)
        self.cbPermissCallback = nil
    }
}

extension MXSystemAuth: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationPermissCallback?(true)
        } else {
            self.locationPermissCallback?(false)
        }
        self.locationPermissCallback = nil
    }
}
