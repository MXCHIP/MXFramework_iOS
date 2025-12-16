//
//  MXBridgeDeviceApi.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/28.
//

import Foundation
import dsBridge

@objc
class MXBridgeDeviceApi: NSObject {
    
    var hanlder: JSCallback?
    
    var messageNeedDelay: Bool = true
    var msgTimestamp: TimeInterval = 0
    var lastMsgPamras : [String: Any]?
    
    public var device: MXDeviceInfo?
    
    public var remoteStatus : Bool = false
    
    // 初始化延时任务
    var sattusWorkItem : DispatchWorkItem?
    
    deinit {
        sattusWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func registThing(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.hanlder = callback
        if  let needDelay = arg["messageControl"] as? Bool {
            self.messageNeedDelay = needDelay
        }
        
        self.refreshDeviceStatus()
    }
    
    func refreshDeviceStatus() {
        var retDic = [String : Any]()
        retDic["type"] = "status"
        var status = [String : Any]()
        status["value"] = self.remoteStatus ? 1 : 0
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        retDic["data"] = status
        self.hanlder?(retDic, false)
    }
    
    @objc func getStatus(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var status = [String : Any]()
        status["status"] = self.remoteStatus ? 1 : 0
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        callback(status, true)
        
    }
    
    @objc func getPropertiesFull(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
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
    
    @objc func setFeedbackGenerator(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        MXDeviceManager.feedbackGenerator()
    }
    
    @objc func setProperties(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        
        //记录发送消息的时间
        self.msgTimestamp = Date().timeIntervalSince1970
        
        
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

@objc
extension MXBridgeDeviceApi {
    //云端消息
    func remoteDeviceProperty(result: [String: Any]) {
        
        if self.lastMsgPamras == nil {
            self.lastMsgPamras = [String : Any]()
        }
        
        for key in result.keys {
            self.lastMsgPamras?[key] = result[key]
        }
        self.meshMessageHandle()
    }
    
    func meshMessageHandle() {
        guard let params = self.lastMsgPamras, params.count > 0 else {
            return
        }
        
        if self.msgTimestamp > 0, self.messageNeedDelay {
            let msgDuration = Date().timeIntervalSince1970 - self.msgTimestamp
            if msgDuration < 3 {
                //取消延时任务
                self.sattusWorkItem?.cancel()
                self.sattusWorkItem = nil
                self.sattusWorkItem = DispatchWorkItem { [weak self] in
                    self?.meshMessageHandle()
                }
                // 添加延时任务
                DispatchQueue.main.asyncAfter(deadline: .now() + (3.0-msgDuration), execute: self.sattusWorkItem!)
                return
            }
        }
        
        let result = ["type":"property","data":params] as [String : Any]
       mxAppLog("[MXWebBridge]: 回调给H5的数据： \(result)")
        self.hanlder?(result, false)
        self.lastMsgPamras = nil
        self.msgTimestamp = 0
    }
}
