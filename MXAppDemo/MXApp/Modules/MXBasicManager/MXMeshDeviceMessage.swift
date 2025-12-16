//
//  MeshSDK+DeviceMessage.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/22.
//

import Foundation

// MARK: - 对设备发送控制指令
public class MXMeshDeviceMessage: NSObject {
    
    /*
    获取设备的三元组
    @param uuid 设备的uuid/mac地址
    @callback [String: Any] 返回数据有pk,ps,dn,ds,pid
    */
    public static func fetchDeviceTriplet(uuid: String, callback:@escaping ([String: Any]) -> ()) {
        var attrStr = String(format: "%04X", UInt16(bigEndian: 0x0003).littleEndian)
        if (MXMeshTool.getFeatureFlag(uuid: uuid) >> 1) == 2 {
            attrStr = String(format: "%04X", UInt16(bigEndian: 0x0019).littleEndian)
        }
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue,
                                               uuid: uuid,
                                               message: attrStr,
                                               timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String, Data(hex: attrStr).count > 2 else {
                callback([String : Any]())
                return
            }
            guard let quintupleString = String(data: Data(hex: attrStr).subdata(in: 2 ..< Data(hex: attrStr).count), encoding: .ascii) else {
                callback([String : Any]())
                return
            }
            let array = quintupleString.split(separator: " ")
            let arrayStrings: [String] = array.compactMap { "\($0)" }
            var quintupleDic = [String: Any]()
            if arrayStrings.count == 1 {
                quintupleDic["dn"] = arrayStrings[0]
            } else if arrayStrings.count >= 5 {
                quintupleDic["pk"] = arrayStrings[0]
                quintupleDic["ps"] = arrayStrings[1]
                quintupleDic["dn"] = arrayStrings[2]
                quintupleDic["ds"] = arrayStrings[3]
                quintupleDic["pid"] = arrayStrings[4]
            }
            callback(quintupleDic)
        }
    }
    
    /*
    获取设备的三元组
    @param uuid 设备的uuid/mac地址
    @callback [String: Any] 返回数据有pk,dn,sign
    */
    public static func fogDeviceTriplet(uuid: String, callback:@escaping ([String: Any]) -> ()) {
        
        let value = UInt16(bigEndian: 0x0030)
        let attrStr = String(format: "%04X", value.littleEndian)
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue, uuid: uuid, message: attrStr, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback([String : Any]())
                return
            }
            
            let msgBytes = [UInt8](Data(hex: attrStr))
            var quintupleDic = [String: Any]()
            guard msgBytes.count >= 18 else {
                callback([String : Any]())
                return
            }
            
            var pkHex: String = ""
            for i in 2 ..< 6 {
                pkHex += String(format: "%02x", msgBytes[i])
            }
            quintupleDic["pk"] = pkHex
            
            var dnHex: String = ""
            for i in 6 ..< 10 {
                dnHex += String(format: "%02x", msgBytes[i])
            }
            quintupleDic["dn"] = dnHex
            
            if msgBytes.count == 18 {  //不带type的
                var dsHex: String = ""
                for i in 10 ..< 18 {
                    dsHex += String(format: "%02x", msgBytes[i])
                }
                quintupleDic["ds"] = dsHex
            } else {
                let typeHex: String = String(format: "%02x", msgBytes[10])
                quintupleDic["type"] = typeHex
                
                var dsHex: String = ""
                for i in 11 ..< 19 {
                    dsHex += String(format: "%02x", msgBytes[i])
                }
                quintupleDic["ds"] = dsHex
            }
            
            callback(quintupleDic)
        }
    }
    
    /*
    获取固件版本号
    @param uuid 设备的uuid/mac地址
    @callbackString 如1.0.0
    */
    public static func fetchDeviceFirmwareVersion(uuid: String, callback:@escaping (String) -> ()) {
        let attrStr =  String(format: "%04X", UInt16(bigEndian: 0x0005).littleEndian)
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue, uuid: uuid, message: attrStr, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback("")
                return
            }
            var version = ""
            let msgBytes = [UInt8](Data(hex: attrStr))
            if msgBytes.count >= 5 {
                let frist_value = Int(String(msgBytes[2]), radix: 16)
                version = version + String(format: "%d", msgBytes[2]) + "."
                version = version + String(format: "%d", msgBytes[3]) + "."
                version = version + String(format: "%d", msgBytes[4])
                if msgBytes.count > 5 { //版本号大于3个字节的，后面的直接拼在最后一位版本号上面
                    for i in 5 ..< msgBytes.count {
                        version = version + String(format: "%02d", msgBytes[i])
                    }
                }
            }
            callback(version)
        }
    }
    
    /*执行虚拟按钮
    @param vid 虚拟按钮ID
    @param networkKey
    @param repeatNum 执行次数
    */
    public static func triggerVirtualButton(vid: String, networkKey: String, repeatNum: Int) {
        let attrType = UInt16(bigEndian: (0x0007 | 0x8000)) //位运算将最高位bit15变成1
        let parameters = String(format: "%04X", attrType.littleEndian) + vid
        MeshSDK.sharedInstance.sendMessage(address: "D003", opCode: VendorMessageOpCode.VendorMessage_Attr_Status.rawValue, message: parameters, networkKey: networkKey, repeatNum: repeatNum)
    }
    
    /*
     发送wifi密码给设备
     @param  uuid 设备uuid/mac地址
     @param  ssid 连接Wi-Fi的ssid
     @param  password 连接Wi-Fi的密码
     @callback  Bool
     @mark  底层消息的callback会多次回调，会返回Wi-Fi连接中的状态
     */
    public static func sendWiFiPasswordToDevice(uuid: String, ssid: String, password: String?, isUpdate:Bool = false, callback:@escaping (Bool) -> ()) {
        // Generate an End Data
        
        let endData = Data.init([0x00])
        
        var finalData = Data()
        if let ssidData = ssid.data(using: .utf8, allowLossyConversion: true) {
            finalData.append(ssidData)
        }
        finalData.append(endData)
        var passwordData = Data()
        if let pw = password, let pw_data = pw.data(using: .ascii, allowLossyConversion: true)  {
            passwordData = pw_data
            finalData.append(passwordData)
        }
        finalData.append(endData)
        
        let attrType = UInt16(bigEndian: 0x0011)
        var valueData = Data(hex: String(format: "%04X", attrType.littleEndian))
        valueData.append(finalData)
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue,
                                               uuid: uuid,
                                               message: valueData,
                                               timeout: 30) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrType = attrStr.prefix(4)
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if attrType == "1300" {
                    let status = UInt8(attrValue, radix: 16)! & 0x03  //位运算只取bit0和bit1
                    if status > 0 {
                        if isUpdate { //如果是更换密码，会先回一次断开之前的连接
                            if status == 1 {
                                callback(true)
                                if let tid = result["tid"] as? String {
                                    MeshSDK.sharedInstance.meshMessageDict.removeValue(forKey: tid+uuid)
                                }
                            }
                        } else {
                            callback(status == 1 ? true : false)
                            if let tid = result["tid"] as? String {
                                MeshSDK.sharedInstance.meshMessageDict.removeValue(forKey: tid+uuid)
                            }
                        }
                    }
                    return
                }
            }
            callback(false)
        }
    }
    
    /*
    设备添加进组
    @param uuid 设备的uuid/mac地址
    @param groups 群组信息
    */
    public static func groupAddDevice(uuid:String, groups:[[String : Any]]? = nil, callback:@escaping (Bool) -> ()) {
        let attrType = UInt16(bigEndian: 0x000D)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = String(format: "%02X", isMaster ? (service | 0x80) : service) + address.littleEndian
                    attrStr.append(groupStr)
                }
            }
        }
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    /*
    群组删除设备
    @param uuid 设备的uuid/mac地址
    @param groups 群组信息
    */
    public static func groupDeleteDevice(uuid:String, groups:[[String : Any]]? = nil,  callback:@escaping (Bool) -> ()) {
        let attrType = UInt16(bigEndian: 0x000E)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = String(format: "%02X", isMaster ? (service | 0x80) : service) + address.littleEndian
                    attrStr.append(groupStr)
                }
            }
        }
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    /*
    清除设备群组设置
    @param uuid 设备的uuid/mac地址
    */
    public static func resetDeviceGroupSetting(uuid:String, groups:[[String : Any]]? = nil, callback:@escaping (Bool) -> ()) {
        let attrType = UInt16(bigEndian: 0x000F)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = String(format: "%02X", isMaster ? (service | 0x80) : service) + address.littleEndian
                    attrStr.append(groupStr)
                }
            }
        }
        MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
