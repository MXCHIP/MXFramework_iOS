//
//  MXBridgeMeshDeviceApi.swift
//  MXApp
//
//  Created by huafeng on 2025/7/22.
//

import Foundation
import dsBridge

@objc
class MXBridgeMeshDeviceApi: MXBridgeDeviceApi {
    
    var isSupportHex: Bool = false
    var networkKey: String?
    
    public override var device: MXDeviceInfo? {
        didSet {
            self.attrMap = MXProductManager.getProductInfo(uuid: self.device?.uuid)?.attrMap
        }
    }
    
    public var isFirstFullProperties: Bool = true
    
    public var attrMap:[String: Any]? = nil
    
    deinit {
        sattusWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc override func registThing(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.hanlder = callback
        if  let needDelay = arg["messageControl"] as? Bool {
            self.messageNeedDelay = needDelay
        }
        if let isHex = arg["hex"] as? Bool {
            self.isSupportHex = isHex
        }
        
        self.refreshDeviceStatus()
    }
    
    override func refreshDeviceStatus() {
        var retDic = [String : Any]()
        retDic["type"] = "status"
        var status = [String : Any]()
        if !(self.device?.isShare ?? false) && (self.device?.uuid?.count ?? 0) > 0 {
            status["value"] = (self.remoteStatus || MeshSDK.sharedInstance.isConnected()) ? 1 : 0
        } else {
            status["value"] = self.remoteStatus ? 1 : 0
        }
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        status["localStatus"] = MeshSDK.sharedInstance.isConnected() ? 1 : 0
        retDic["data"] = status
        self.hanlder?(retDic, false)
    }
    
    @objc override func getStatus(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var status = [String : Any]()
        if !(self.device?.isShare ?? false) && (self.device?.uuid?.count ?? 0) > 0 {
            status["status"] = (self.remoteStatus || MeshSDK.sharedInstance.isConnected()) ? 1 : 0
        } else {
            status["status"] = self.remoteStatus ? 1 : 0
        }
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        status["localStatus"] = MeshSDK.sharedInstance.isConnected() ? 1 : 0
        callback(status, true)
        
    }
    
    @objc func getLocalProperties(_ arg: Dictionary<String,Any>) {
        if let uuidStr = self.device?.uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected() {
            var attrStr = ""
            if let hexStr = arg["hex"] as? String, hexStr.count > 0 {
               attrStr = hexStr
            } else {
                let curSet = (arg["data"] as? [String]) ?? [String]()
                for name in curSet {
                    if let type = MXMeshMessageHandle.identifierConvertToAttrType(identifier: name, attrMap: self.attrMap) {
                        attrStr.append(type)
                    }
                }
            }
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: attrStr, timeout: 5.0) { (result :[String : Any]) in
                var resultParams = [String : Any]()
                if let attrHex = result["message"] as? String {
                    if self.isSupportHex {
                        let retDict = ["type":"hex","data":attrHex]
                        self.hanlder?(retDict, false)
                        return
                    }
                    resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex, attrMap: self.attrMap)
                    //更新Mesh SDK设备影子
                    MXMeshDeviceManager.shard.updateDeviceStatusCache(uuid: uuidStr, properties: resultParams)
                    var newResult = [String : Any]()
                    for key in resultParams.keys {
                        newResult[key] = ["value": resultParams[key]]
                    }
                    let result = ["type":"property","data":newResult] as [String : Any]
                    self.hanlder?(result, false)
                }
            }
        }
    }
    
    @objc override func getPropertiesFull(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        if self.isFirstFullProperties {
            self.isFirstFullProperties = false
            if self.remoteStatus {  //只有云端在线才需要先同步云端数据
                guard let iotId = self.device?.iotId else {
                    return
                }
                MXAPI.device.getProperties(iotId: iotId) { (data: Any, message: String, code: Int ) in
                    if code == 0 {
                        if let dict = data as? [String: Any]{
                            callback(dict, true)
                            self.getLocalProperties(arg)
                            return
                        }
                    }
                    self.getPropertiesFull(arg, callback: callback)
                }
                return
            }
        }
        var isFromNetwork = false
        if let fromNetwork = arg["isFromNetwork"] as? Bool {
            isFromNetwork = fromNetwork
        }
        if let uuidStr = self.device?.uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected(), !isFromNetwork {
            var attrStr = ""
            if let hexStr = arg["hex"] as? String, hexStr.count > 0 {
               attrStr = hexStr
            } else {
                let curSet = (arg["data"] as? [String]) ?? [String]()
                for name in curSet {
                    if let type = MXMeshMessageHandle.identifierConvertToAttrType(identifier: name, attrMap: self.attrMap) {
                        attrStr.append(type)
                    }
                }
            }
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: attrStr, timeout: 5.0) { (result :[String : Any]) in
                var resultParams = [String : Any]()
                if let attrHex = result["message"] as? String {
                    if self.isSupportHex {
                        callback(attrHex, true)
                        return
                    }
                    resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex, attrMap: self.attrMap)
                    //更新Mesh SDK设备影子
                    MXMeshDeviceManager.shard.updateDeviceStatusCache(uuid: uuidStr, properties: resultParams)
                }
                var newResult = [String :Any]()
                for key in resultParams.keys {
                    newResult[key] = ["value": resultParams[key]]
                }
                callback(newResult, true)
            }
        } else {
            guard let iotId = self.device?.iotId else {
                return
            }
            MXAPI.device.getProperties(iotId: iotId) { (data: Any, message: String, code: Int ) in
                if code == 0 {
                    if let dict = data as? [String: Any]{
                        callback(dict, true)
                    }
                } else {
                   mxAppLog("[MXWebBridge]: 请求失败 \(message)")
                    callback([String: Any](), true)
                }
            }
        }
    }
    
    @objc override func setProperties(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        
        var isFromNetwork = false
        if let fromNetwork = arg["isFromNetwork"] as? Bool {
            isFromNetwork = fromNetwork
        }
        //记录发送消息的时间
        self.msgTimestamp = Date().timeIntervalSince1970
        
        //单控
        if let uuidStr = self.device?.uuid, uuidStr.count > 0 {
            //mesh设备
            let repeatNum = 1
            var messageOpCode : String! = "11"
            if (arg["messageType"] as? String) == "unack" {
                messageOpCode = "12"
            }
            
            var msgStr = ""
            if let hexStr = arg["hex"] as? String, hexStr.count > 0 {
                msgStr = hexStr
            } else if let curSet = arg["data"] as? [String : Any] {
                for name in curSet.keys {
                    let value = curSet[name] as Any
                    if let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: name, value: value, attrMap: self.attrMap) {
                        msgStr.append(msgHex)
                    }
                }
            }
            guard msgStr.count > 0 else {
                var result = [String : Any]()
                result["code"] = 1
                result["success"] = false
                callback(result, true)
                return
            }
            
            if MeshSDK.sharedInstance.isConnected(), !isFromNetwork {
                if let low = self.device?.productInfo?.not_receive_message, low, let nk = self.networkKey {
                    //低功耗设备控制
                    let address = MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr)
                    let parameters = "0010".littleEndian + address.littleEndian + msgStr
                    MeshSDK.sharedInstance.sendMessage(address: "D003", opCode: "12", message: parameters, networkKey: nk, repeatNum: 2)
                    return
                }
                if messageOpCode == "12" {
                    MeshSDK.sharedInstance.sendMeshMessage(opCode: messageOpCode, uuid: uuidStr, message: msgStr)
                    var result = [String : Any]()
                    result["code"] = 0
                    result["success"] = true
                    callback(result, true)
                } else {
                    MeshSDK.sharedInstance.sendMeshMessage(opCode: messageOpCode, uuid: uuidStr, message: msgStr, repeatNum: repeatNum) { (result :[String : Any]) in
                        guard  let attrHex = result["message"] as? String else {
                            var result = [String : Any]()
                            result["code"] = 1
                            result["success"] = false
                            callback(result, true)
                            return
                        }
                        var resultParams = [String : Any]()
                        resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex, attrMap: self.attrMap)
                        //更新Mesh SDK设备影子
                        MXMeshDeviceManager.shard.updateDeviceStatusCache(uuid: uuidStr, properties: resultParams)
                        var result = [String : Any]()
                        result["code"] = 0
                        result["success"] = true
                        result["data"] = resultParams
                        callback(result, true)
                    }
                }
            } else {
                //低功耗设备透传
                if let low = self.device?.productInfo?.not_receive_message, low {
                    let tid = MeshSDK.sharedInstance.getNextTid()
                    let version = "00"
                    let repeatNum = "02"
                    let repeatTime = "00C8".littleEndian  //16进制，单位毫秒
                    let opCode = "D22209"
                    
                    let address = MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr)
                    
                    guard let home_id = MXHomeManager.shard.currentHome?.homeId, address.count > 0 else {
                        var result = [String : Any]()
                        result["code"] = 1
                        result["success"] = false
                        callback(result, true)
                        return
                    }
                    let newMsg = "0010".littleEndian + address.littleEndian + msgStr
                    let message = version + repeatNum + repeatTime + "D003".littleEndian + opCode + tid + newMsg
                    MXAPI.device.sendMeshMessage(homeId: home_id, message: message) { (data: Any, message: String, code: Int ) in
                        var result = [String : Any]()
                        result["code"] = code
                        result["success"] = (code == 0) ? true : false
                        result["message"] = message
                        callback(result, true)
                    }
                    return
                }
                if let hexStr = arg["hex"] as? String,
                   hexStr.count > 0,
                   MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr).count > 0 {
                    //如果是发送的Hex,走网关透传
                    let tid = MeshSDK.sharedInstance.getNextTid()
                    let message = "00" + String(format: "%02x", repeatNum) + "C800" + MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr).littleEndian + String(format: "%02X", (0xC0 | (UInt8(messageOpCode, radix:16) ?? 0x12))) + "2209" + tid + hexStr
                    guard let home_id = MXHomeManager.shard.currentHome?.homeId else {
                        var result = [String : Any]()
                        result["code"] = 1
                        result["success"] = false
                        callback(result, true)
                        return
                    }
                    MXAPI.device.sendMeshMessage(homeId: home_id, message: message) { (data: Any, message: String, code: Int ) in
                        var result = [String : Any]()
                        result["code"] = code
                        result["success"] = (code == 0) ? true : false
                        result["message"] = message
                        callback(result, true)
                    }
                } else if let curSet = arg["data"] as? [String : Any] {
                    //否则走物模云端控制
                    guard let iotId = self.device?.iotId else {
                        return
                    }
                    MXAPI.device.setProperties(iotId: iotId, items: curSet) { (data: Any, message: String, code: Int ) in
                        var result = [String : Any]()
                        result["code"] = code
                        result["success"] = (code == 0) ? true : false
                        result["message"] = message
                        callback(result, true)
                    }
                }
            }
        } else { //云端物模控制
            guard let curSet = arg["data"] as? [String : Any] else {
                return
            }
            guard let iotId = self.device?.iotId else {
                return
            }
            MXAPI.device.setProperties(iotId: iotId, items: curSet) { (data: Any, message: String, code: Int ) in
                var result = [String : Any]()
                result["code"] = code
                result["success"] = (code == 0) ? true : false
                result["message"] = message
                callback(result, true)
            }
        }
    }
    
    //hex转物模型
    @objc func hexToProperties(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var resultParams = [String : Any]()
        if let hexStr = arg["hex"] as? String, hexStr.count > 0 {
            resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: hexStr, attrMap: self.attrMap)
        }
        callback(resultParams, true)
    }
    
    
    @objc func sendMeshMessage(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        /*
         @params opCode String  10获取属性 11设置属性 12设置属性（无回调） 13状态上报消息, 默认"12"unack消息
         @params dstUUID String  目标设备的UUID，如果没有就取当前设备
         @params groupAddress String 非必传，默认设备地址或者群组地址（联动触发需要给"D003"发）
         @params repeatNum  Int 非必传 发送次数,单播默认1次，组播默认2次
         @params msgBody  String  消息内容，Hex字符串
         @params timeout  Int  超时时间 单位是ms
         @params isFromNetwork Bool 是否直接从云端请求 默认false
         */
        
        var uuidStr : String? = self.device?.uuid
        if let dst_uuid = arg["dstUUID"] as? String {
            uuidStr = dst_uuid
        }
        
        var isFromNetwork = false
        if let fromNetwork = arg["isFromNetwork"] as? Bool {
            isFromNetwork = fromNetwork
        }
        
        var opCode = "12"
        var msgBody = ""
        if let mesh_opCode = arg["opCode"] as? String {
            opCode = mesh_opCode
        }
        if let mesh_message = arg["msgBody"] as? String {
            msgBody = mesh_message
        }
        var mesh_address : String?
        var repeatNum: Int = 1
        if let meshAddress = arg["groupAddress"] as? String {  //发送的是组播消息
            mesh_address = meshAddress
            repeatNum = 2
        }
        if let num = arg["repeatNum"] as? Int {
            repeatNum = num
        }
        var timeout : Double = 2
        if let t = arg["timeout"] as? Int {  //超时时间
            timeout = Double(t)/1000
        }
        
        if MeshSDK.sharedInstance.isConnected(), !isFromNetwork {
            if let group_address = mesh_address {
                if let nk = self.networkKey {
                    MeshSDK.sharedInstance.sendMessage(address: group_address, opCode: opCode, message: msgBody, networkKey: nk, repeatNum: repeatNum)
                }
            } else if let uuid = uuidStr {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: opCode, uuid: uuid, message: msgBody, timeout: timeout) { (result:[String : Any]) in
                    guard  let attrStr = result["message"] as? String else {
                        var result = [String : Any]()
                        result["code"] = 1
                        result["success"] = false
                        callback(result, true)
                        return
                    }
                    var result = [String : Any]()
                    result["code"] = 0
                    result["success"] = true
                    result["message"] = attrStr
                    callback(result, true)
                }
            }
        } else {
            if mesh_address == nil, let uuid = uuidStr {
                mesh_address = MeshSDK.sharedInstance.getNodeAddress(uuid: uuid)
            }
            guard let meshAddress = mesh_address,
                  meshAddress.count > 0 else {
                var result = [String : Any]()
                result["code"] = 1
                result["success"] = false
                callback(result, true)
                return
            }
            let tid = MeshSDK.sharedInstance.getNextTid()
            let message = "00" + String(format: "%02x", repeatNum) + "C800" + meshAddress.littleEndian + String(format: "%02X", (0xC0 | (UInt8(opCode, radix:16) ?? 0x12))) + "2209" + tid + msgBody
            guard let home_id = MXHomeManager.shard.currentHome?.homeId else {
                var result = [String : Any]()
                result["code"] = 1
                result["success"] = false
                callback(result, true)
                return
            }
            MXAPI.device.sendMeshMessage(homeId: home_id, message: message) { (data: Any, message: String, code: Int ) in
                var result = [String : Any]()
                result["code"] = code
                result["success"] = (code == 0 ? true : false)
                result["message"] = message
                callback(result, true)
            }
        }
    }
    
}

extension MXBridgeMeshDeviceApi {
    //云端消息
    override func remoteDeviceProperty(result: [String: Any]) {
        
        if self.lastMsgPamras == nil {
            self.lastMsgPamras = [String : Any]()
        }
        
        for key in result.keys {
            if let uuidStr = self.device?.uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected(), let deviceParams = MXMeshDeviceManager.shard.getDeviceCacheProperties(uuid: uuidStr), deviceParams[key] != nil {  //本地在线，直接丢弃云端的状态
                continue
            }
            self.lastMsgPamras?[key] = result[key]
        }
        
        self.meshMessageHandle()
    }
    
    //本地消息
    func localDeviceProperty(result: [String: Any]) {
        guard let uuidStr = self.device?.uuid, uuidStr.count > 0 else {
            return
        }
        guard let attrStr = result["message"] as? String  else {
            return
        }
        if self.isSupportHex {
            let retDict = ["type":"hex","data":attrStr]
           mxAppLog("[MXWebBridge]: 收到Hex消息：\(attrStr)")
            self.hanlder?(retDict, false)
        } else {
            let result = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrStr, attrMap: self.attrMap)
            //更新Mesh SDK设备影子
            MXMeshDeviceManager.shard.updateDeviceStatusCache(uuid: uuidStr, properties: result)
            var newResult = [String : Any]()
            for key in result.keys {
                newResult[key] = ["value": result[key]]
            }
//            let retDict = ["type":"property","data":newResult] as [String : Any]
//            self.hanlder?(retDict, false)
            if self.lastMsgPamras == nil {
                self.lastMsgPamras = [String : Any]()
            }
            for key in newResult.keys {
                self.lastMsgPamras?[key] = newResult[key]
            }
            self.meshMessageHandle()
        }
    }
}
