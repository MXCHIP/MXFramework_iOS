//
//  MXHomeManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/25.
//

import Foundation
import UIKit

public class MXHomeManager: NSObject {
    public static var shard = MXHomeManager()
    
    //private let mutex = DispatchQueue(label: "MXHomeCacheMutex")
    
    public var currentHome : MXHomeInfo? {
        didSet {
            if self.currentHome != nil {
                MXMeshManager.shard.resetMeshNetwork()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
                if let home_id = self.currentHome?.homeId {
                    MXRoomManager.requestRoomList(homeId: home_id) { list in
                        
                    }
                }
            }
        }
    }
    public var homeList = Array<MXHomeInfo>()
    
    override init() {
        super.init()
        self.currentHome = loadCacheInfo()
    }
    
    public func loadCacheInfo() -> MXHomeInfo? {
        let fileName = "MXCache_Home.json"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName)
        if let json_data = try? Data(contentsOf: url) {
            if let cacheInfo = try? JSONSerialization.jsonObject(with: json_data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any],
               let home = MXHomeInfo.mx_Decode(cacheInfo) {
                return home
            }
        }
        return nil
    }
    
    public func cleanCache() {
        self.currentHome = nil
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first!
        let cachePath = "\(documentsDirectory)/MXCache_Home.json"
        try? FileManager.default.removeItem(atPath: cachePath)
        self.homeList.removeAll()
    }
    
    public func updateCache() {
        DispatchQueue.main.async {
            if let home = self.currentHome, let homeDict = MXHomeInfo.mx_keyValue(home) {
               mxAppLog("当前家庭数据：\(homeDict)")
                let fileName = "MXCache_Home.json"
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                let documentsDirectory = paths[0] as! String
                let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName)
                if let json_data = try? JSONSerialization.data(withJSONObject: homeDict, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
                    try? json_data.write(to: url)
                }
            }
        }
    }
}

extension MXHomeManager  {
    
    public func receiveMessageHander(text: String) {
        let jsonData:Data = text.data(using: .utf8)!
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String:Any] else {
            return
        }
        if let msgType = dict["mxMessageType"] as? String, let msgData = dict["data"] as? [String : Any] { //自定义消息
            switch msgType {
            case "DEVICE_BIND":
                if let homeId = msgData["homeId"] as? Int, homeId == self.currentHome?.homeId {
                    let roomId: Int = (msgData["roomId"] as? Int) ?? 0
                    var roomList = [Int]()
                    if roomId == 0 {
                        if let defaultRoomId = MXRoomManager.shard.getCurrentDefaultRoomId() {
                            roomList.append(defaultRoomId)
                        }
                    } else {
                        roomList.append(roomId)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDeviceDataSourceChange"), object: roomList)
                }
                break
            case "DEVICE_UNBIND":
                if let homeId = msgData["homeId"] as? Int, homeId == self.currentHome?.homeId {
                    let roomId: Int = (msgData["roomId"] as? Int) ?? 0
                    var roomList = [Int]()
                    if roomId == 0 {
                        if let defaultRoomId = MXRoomManager.shard.getCurrentDefaultRoomId() {
                            roomList.append(defaultRoomId)
                        }
                    } else {
                        roomList.append(roomId)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDeviceDataSourceChange"), object: roomList)
                    
                    if let iotId = msgData["iotId"] as? String {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDeviceUnbind"), object: iotId)
                    }
                }
                break
            default:
                break
                
            }
        } else if let iot_id = dict["iotId"] as? String {  //设备消息
            if let propertys = dict["items"] as? [String : Any] {
                var newParams = [String : Any]()
                newParams[iot_id] = propertys
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromRemote"), object: newParams)
            } else if let status = dict["status"] as? String {
                var newParams = [String : Any]()
                newParams[iot_id] = (status == "online") ? true : false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDeviceRemoteStatusChange"), object: newParams)
            } else if let _ = dict["identifier"] as? String,
                      let _ = dict["value"] as? [String : Any] {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kDeviceEventFromRemote"), object: dict)
            }
        }
    }
    
    
}

extension MXHomeManager {
    //权限检查
   public  func operationAuthorityCheck(_ isShowAlert: Bool = false) -> Bool {
        if let homeRole = self.currentHome?.role, homeRole < 2 {
            return true
        }
        if isShowAlert {
            MXHomeManager.showNoAuthorityAlert()
        }
        return false
    }
    //权限提示
    static public func showNoAuthorityAlert(_ msg :String? = nil) {
        var alertMsg = MXAppConfig.mxLocalized(key:"mx_role_user_fun_des")
        if let m = msg {
            alertMsg = m
        }
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: alertMsg, confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
            
        }
        alert.show()
    }
    //权限检查
    public func ownerAuthorityCheck(_ isShowAlert: Bool = false) -> Bool {
        if let homeRole = self.currentHome?.role, homeRole == 0 {
            return true
        }
        if isShowAlert {
            MXHomeManager.showOwnerAuthorityAlert()
        }
        return false
    }
    //只有所有者可以操作
    static public func showOwnerAuthorityAlert() {
        let alertMsg = MXAppConfig.mxLocalized(key:"mx_role_owner_fun_des")
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: alertMsg, confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
            
        }
        alert.show()
    }
}

extension MXHomeManager {
    
    static public func requestHomeInfo(homeId: Int, handler:@escaping (_ info: MXHomeInfo?) -> Void) {
        MXAPI.home.homeInfo(home_id: homeId) { data, message, code in
            if code == 0, let dict = data as? [String: Any], let home_info = MXHomeInfo.mx_Decode(dict) {
                handler(home_info)
                return
            }
            handler(nil);
        }
    }
    
    public func requestHomeList(pageNo:Int, pageSize: Int, handler:@escaping (_ list: Array<MXHomeInfo>) -> Void) {
        MXAPI.home.list(page: pageNo, size: pageSize) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                var newList = [MXHomeInfo]()
                if pageNo > 1 {
                    newList.append(contentsOf: self.homeList)
                }
                
                if let dict = data as? [String: Any], let result = dict["list"] as? Array<[String : Any]> {
                    if let list = MXHomeInfo.mx_Decode(result) {
                        newList.append(contentsOf: list)
                    }
                    
                    var current_home: MXHomeInfo? = self.currentHome
                    if let defalut_index = newList.firstIndex(where: {$0.isCurrentHome == true}) {
                        let defalut_home = newList[defalut_index]
                        current_home = newList[defalut_index]
                        if defalut_index > 0 {
                            newList.remove(at: defalut_index)
                            newList.insert(defalut_home, at: 0)
                        }
                    } else if let first = newList.first, newList.first(where: {$0.homeId == self.currentHome?.homeId}) == nil {
                        current_home = first
                        //把第一个设置成默认房间
                        self.requestSetCurrentHome(homeId: first.homeId) { isSuccess in
                            
                        }
                    }
                    
                    if let defaultHome = current_home {
                        if defaultHome.homeId != self.currentHome?.homeId {
                            self.currentHome = defaultHome
                        } else {
                            //if self.currentHome?.name != current_home.name {
                                self.currentHome?.name = defaultHome.name
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kHomeNameChangeNotification"), object: nil)
                            //}
                            self.currentHome?.province_name = defaultHome.province_name
                            self.currentHome?.city_name = defaultHome.city_name
                            self.currentHome?.address = defaultHome.address
                            self.currentHome?.location_key = defaultHome.location_key
                            self.currentHome?.roomCount = defaultHome.roomCount
                            self.currentHome?.deviceCount = defaultHome.deviceCount
                            self.currentHome?.userCount = defaultHome.userCount
                            self.currentHome?.role = defaultHome.role
                        }
                    }
                    self.homeList = newList
                }
            }
            
            handler(self.homeList)
        }
    }
    
    public func requestSetCurrentHome(homeId:Int, handler:@escaping (_ isSuccess: Bool) -> Void) {
        MXAPI.home.currentHome(homeId: homeId) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}
