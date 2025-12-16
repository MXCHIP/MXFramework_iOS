//
//  MXBridgeRequestApi.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/29.
//

import Foundation
import MXAPIManager
import dsBridge

@objc
class MXBridgeRequestApi: NSObject {
    
    var networkKey: String?
    
    @objc func fetchOwnServer(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard let url = arg["url"] as? String else {
            return
        }
        var method = "POST"
        if let methodStr = arg["method"] as? String{
            method = methodStr
        }
        var params = [String : Any]()
        if let data = arg["data"] as? [String : Any]  {
            params = data
        }
        if url.contains("app/v1/device/group/ctrl/address") {
            params["network_key"] = self.networkKey
        }
        
        MXAPIManager.shared.request(path: url, method: method, parameters: params) { (data: Any, message: String, code: Int) in
            var result = [String : Any]()
            result["data"] = data
            result["code"] = code
            result["message"] = message
            callback(result, true)
        }
    }
}
