//
//  MXDeviceManager+Provisioning.swift
//  MXApp
//
//  Created by 华峰 on 2023/7/27.
//

import Foundation

extension MXDeviceManager {
    
    //获取设备deviceName
    public static func getDeviceName(info:MXProvisionDeviceInfo, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        if let uuid = info.uuid, uuid.count > 0 {
            if info.productInfo?.cloud_platform == 2 {  //fog设备
                MXMeshDeviceMessage.fogDeviceTriplet(uuid: uuid) { (result: [String : Any]) in
                    if let dn = result["dn"] as? String {
                        
                        if let signStr = result["ds"] as? String {
                            info.sign = signStr
                        }
                        if let sign_type = result["type"] as? String {
                            info.signType = Int(sign_type, radix: 16)
                        }
                        
                        info.deviceName = dn
                        MXDeviceManager.setGatewayHost(info: info) { isSuccess, device in
                            MXDeviceManager.setGatewayCloudHost(info: device) { isSuccess, device in
                                MXDeviceManager.getGatewayIpAndMac(info: device) { result in
                                    handler(true, result)
                                }
                            }
                        }
                    } else {
                        handler(false, info)
                    }
                }
            } else {
                MXMeshDeviceMessage.fetchDeviceTriplet(uuid: uuid) { (result: [String : Any]) in
                    if let dn = result["dn"] as? String {
                        
                        info.deviceName = dn
                        handler(true, info)
                    } else {
                        handler(false, info)
                    }
                }
            }
        } else {
            handler(false, info)
        }
    }
    //发送Wi-Fi信息
    public static func sendWifiConfigData(info:MXProvisionDeviceInfo, ssid: String? = nil, password: String? = nil, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        guard let uuid = info.uuid, uuid.count > 0 else {
            handler(false, info)
            return
        }
        if info.productInfo?.link_type_id == 10 {
            if let ssid = ssid {
                MXMeshDeviceMessage.sendWiFiPasswordToDevice(uuid: uuid, ssid: ssid, password: password) { (isSuccess : Bool) in
                    handler(isSuccess, info)
                }
            } else {
                handler(false, info)
            }
        } else if info.productInfo?.link_type_id == 11 {
            if let ssid = ssid {
                MXMeshDeviceMessage.sendWiFiPasswordToDevice(uuid: uuid, ssid: ssid, password: password) { (isSuccess : Bool) in
                    handler(isSuccess, info)
                }
            } else {
                handler(true, info)
            }
        } else {
            handler(true, info)
        }
    }
    
    //网关设置host
    public static func setGatewayHost(info:MXProvisionDeviceInfo, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        guard let uuid = info.uuid,
              uuid.count > 0,
              info.productInfo?.cloud_platform == 2,
              info.productInfo?.node_type_v2 == "gateway" else {
            //如果不需要写入，默认成功
            handler(true, info)
            return
        }
        var params = [String : Any]()
        params["arg"] = "fog"
        var valParams = [String: Any]()
        valParams["mqtt"] = MXAppConfig.MXIotMQTTHost
        valParams["http"] = MXAppConfig.MXIotHTTPHost
        params["val"] = valParams
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {
            handler(false, info)
            return
        }
        let msg = "0015".littleEndian + jsonData.hex
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuid, message: msg, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                handler(false, info)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    handler(true, info)
                    return
                }
            }
            handler(false, info)
        }
    }
    
    //网关设置MXCloud
    public static func setGatewayCloudHost(info:MXProvisionDeviceInfo, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        guard let uuid = info.uuid,
              uuid.count > 0,
              info.productInfo?.cloud_platform == 2,
              info.productInfo?.node_type_v2 == "gateway" else {
            //如果不需要写入，默认成功
            handler(true, info)
            return
        }
        
        var appHost = MXAppConfig.MXHost.components(separatedBy: "//").last
        if appHost?.last == "/" {
            appHost?.removeLast()
        }
        var params = [String : Any]()
        params["arg"] = "mxcloud"
        params["val"] = appHost
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {
            handler(false, info)
            return
        }
        let msg = "0015".littleEndian + jsonData.hex
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuid, message: msg, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                handler(false, info)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    handler(true, info)
                    return
                }
            }
            handler(false, info)
        }
    }
    
    //请求网关IP
    static public func requestGatewayIp(type: Int = 2, uuid:String, handler:@escaping (_ type: Int, _ ip: String?, _ mac: String?) -> Void) {
        let attrStr = "001B".littleEndian + "02" + String(format: "%02X", type)
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuid, message: attrStr, timeout: 8) { (result:[String : Any]) in
            guard  let resultMsg = result["message"] as? String else {
                handler(type, nil, nil)
                return
            }
            let resultData = [UInt8](Data(hex: resultMsg))
            var wifi_mac: String?
            if resultData.count > 12 {
                wifi_mac = String(format: "%02x:%02x:%02x:%02x:%02x:%02x", resultData[7],resultData[8],resultData[9],resultData[10],resultData[11],resultData[12])
            }
            if resultData.count > 6, resultData[3] > 0 {
                let ipStr = String(resultData[3]) + "." + String(resultData[4]) + "." + String(resultData[5]) + "." + String(resultData[6])
                handler(type, ipStr, wifi_mac)
                return
            }
            handler(type, nil, wifi_mac)
        }
    }
    
    //请求网关IP
    static public func getGatewayIpAndMac(info:MXProvisionDeviceInfo, type: Int = 2, handler:@escaping (_ result: MXProvisionDeviceInfo) -> Void) {
        if let productInfo = info.productInfo,
           productInfo.node_type_v2 == "gateway",
           let uuidStr = info.uuid,
           uuidStr.count > 0 {
            MXDeviceManager.requestGatewayIp(type: type, uuid: uuidStr) { type, ip, mac in
                if type == 2 {
                    if mac != nil {
                        info.eth_mac = mac
                    }
                    if ip != nil {  //优先取以太网的IP
                        info.ip = ip
                    }
                    MXDeviceManager.getGatewayIpAndMac(info: info, type: 1, handler: handler)
                    return
                } else if type == 1 {
                    if mac != nil {
                        info.wifi_mac = mac
                    }
                    if ip != nil, info.ip == nil {
                        info.ip = ip
                    }
                    handler(info)
                }
            }
        } else {
            handler(info)
        }
    }
    
    //设备版本号
    public static func getDeviceVersion(device:MXProvisionDeviceInfo, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        if let uuidStr = device.uuid, uuidStr.count > 0 {
            // 获取设备版本号，同步到云端
            MXMeshDeviceMessage.fetchDeviceFirmwareVersion(uuid: uuidStr) { (version: String) in
                device.firmware_version = version
                handler(true, device)
            }
        } else {
            handler(true, device)
        }
    }
    
    //Mesh配网结束
    public static func deviceProvisionFinish(device:MXProvisionDeviceInfo, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        if let uuidStr = device.uuid, uuidStr.count > 0 {
            //通知设备配网成功
            let attrStr =  String(format: "%04X", UInt16(bigEndian: 0x0018).littleEndian) + "00000000"
            // 告诉设备配网成功
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: attrStr) { (result:[String : Any]) in
                handler(true, device)
            }
        } else {
            handler(true, device)
        }
    }
    //绑定设备
    public static func bindDevice(info: MXProvisionDeviceInfo, replaced_iotId: String? = nil, handler:@escaping (_ isSuccess: Bool, _ device: MXProvisionDeviceInfo) -> Void) {
        
        var params = [String: Any]()
        params["home_id"] = MXHomeManager.shard.currentHome?.homeId
        params["device_name"] = info.deviceName
        params["product_key"] = info.productInfo?.product_key
        params["mac"] = info.mac
        params["uuid"] = info.uuid
        params["sign_type"] = info.signType
        params["sign"] = info.sign
        params["room_id"] = info.roomId
        params["composite_product_key"] = info.composite_product_key
        
        params["wifi_mac"] = info.wifi_mac
        params["eth_mac"] = info.eth_mac
        
        if let replacedIotId = replaced_iotId {
            params["replaced_iotid"] = replacedIotId
        }
        
        if let uuidStr = info.uuid, uuidStr.count > 0, let node = MeshSDK.sharedInstance.getNodeInfo(uuid: uuidStr) {  //mesh配网
            if let meshUUID = node["UUID"] as? String {
                let mesh_uuid = meshUUID.replacingOccurrences(of: "-", with: "")
                params["mesh_uuid"] = mesh_uuid
            }
            if let meshAddress = node["unicastAddress"] as? String {
                params["mesh_address"] = Int(meshAddress, radix: 16)
            }
            params["device_key"] = node["deviceKey"]
            params["cid"] = node["cid"]
            //params["elements"] = node["elements"]
        }
        if let latitude = MXAccountModel.shared.locationLatitude,
           let longitude = MXAccountModel.shared.locationLongitude {
            let lat = String(round(latitude * 1000000) / 1000000)
            let lon = String(round(longitude * 1000000) / 1000000)
            params["lat"] = lat
            params["lon"] = lon
        }
        MXAPI.provisioning.bind(params: params) { (data: Any, message: String, code: Int) in
            if code == 0 {
                MXMeshManager.shard.updateMeshNetwork()
                if let dict = data as? [String : Any], let iod_id = dict["iotid"] as? String {
                    info.iotId = iod_id
                    handler(true, info)
                    return
                }
            }
            handler(false, info)
        }
    }
    
    public static func bindDevice(pk: String, dn: String, productInfo: MXProductInfo?, roomId: Int?) {
        
        var params = [String: Any]()
        params["home_id"] = MXHomeManager.shard.currentHome?.homeId
        params["device_name"] = dn
        params["product_key"] = pk
        params["room_id"] = roomId
        params["scan_code"] = true
        
        if let latitude = MXAccountModel.shared.locationLatitude,
           let longitude = MXAccountModel.shared.locationLongitude {
            let lat = String(round(latitude * 1000000) / 1000000)
            let lon = String(round(longitude * 1000000) / 1000000)
            params["lat"] = lat
            params["lon"] = lon
        }
        MXAPI.provisioning.bind(params: params) { (data: Any, message: String, code: Int) in
            if code == 0 {
                if let dict = data as? [String : Any], let iot_id = dict["iotid"] as? String {
                    let device = MXDeviceInfo()
                    device.productName = dn
                    device.productKey  = pk
                    device.productImage = productInfo?.image
                    device.iotId = iot_id
                    device.isFavorite = true
                    if let room_id = roomId, let room = MXRoomManager.shard.currentRoomList.first(where: {$0.roomId == room_id}) {
                        device.roomId = room.roomId
                        device.roomName = room.name
                    } else if let room = MXRoomManager.shard.currentRoomList.first(where: {$0.is_default}) {
                        device.roomId = room.roomId
                        device.roomName = room.name
                    }
                    var device_list = [MXDeviceInfo]()
                    device_list.append(device)
                    var params = [String :Any]()
                    params["devices"] = device_list
                    params["roomId"] = roomId
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/device/settingRoom", params: params)
                }
            }
        }
    }
}

extension MXDeviceManager {
    
    /*Fog配网随机数*/
    static public func requestFogRandom(params:[String: Any]?, handler: @escaping (_ random: String?) -> Void) {
        MXAPI.provisioning.random(params: params) { data, message, code in
            if let dataDict = data as? [String : Any], let random = dataDict["random"] as? String {
                handler(random)
            } else {
                handler(nil)
            }
        }
    }
    
    /*Fog配网ble key*/
    static public func requestFogBleKey(params:[String: Any]?, handler: @escaping (_ bleKey: String?) -> Void) {
        MXAPI.provisioning.fogKey(params: params) { (data:Any?, message:String, code:Int) in
            if let dataDict = data as? [String : Any], let keyStr = dataDict["ble_key"] as? String, let isSuccess = dataDict["Verify"] as? Bool, isSuccess {
                handler(keyStr)
            } else {
                handler(nil)
            }
        }
    }
    /*请求Fog配网Wi-Fi连接状态
     */
    static public func requestFogConnectStatus(params:[String: Any]?, handler: @escaping (_ connected: Bool) -> Void) {
        MXAPI.provisioning.fogStatus(params: params) { (data:Any?, message:String, code:Int) in
            if let dataDict = data as? [String : Any], let isConnected = dataDict["connected"] as? Bool {
                handler(isConnected)
            } else {
                handler(false)
            }
        }
    }
}
