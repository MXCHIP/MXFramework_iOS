//
//  MXBridgePageApi.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/28.
//

import Foundation
import dsBridge

@objc
class MXBridgePageApi: NSObject {
    public var device: MXDeviceInfo?
    public var navigationController: UINavigationController!
    public var navigationItem : UINavigationItem!
    public typealias CloseWebViewBlock = () -> ()
    public var closeWebViewBlock : CloseWebViewBlock?
    public typealias NeedRloadHomeListBlock = () -> ()
    public var needRloadHomeListBlock: NeedRloadHomeListBlock?
    
    @objc func getToken(_ callback: @escaping JSCallback) {
        let accessToken = MXAccountModel.shared.token
        callback(accessToken,true)
    }
    
    @objc func getPlatformInfo(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard let infoDic = Bundle.main.infoDictionary else {
            return
        }
        if let app_Version = infoDic["CFBundleShortVersionString"] as? String {
            let result = ["platform":"ios","version":app_Version]
            callback(result,true)
        }
    }
    
    @objc func closeWebView(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.closeWebViewBlock?()
        callback("success", true)
    }
    
    @objc func has(_ path: String, callback: @escaping JSCallback) {
        let enable = MXURLRouterService.canOpen(url: String(format: "https://com.mxchip.bta/%@", path))
        let status = enable ? "1" : ""
        callback(status, true)
    }
    
    @objc func go(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard let path = arg["path"] as? String else {
            return
        }
        var params = [String: Any]()
        if let query = arg["query"] as? [String : Any] {
            params = query
        }
        
        if path == "page/scene/settingProperty" {  //需要权限校验的
            if !MXHomeManager.shard.operationAuthorityCheck() {
                return
            }
        }
        params["uuid"] = self.device?.uuid
        params["device"] = self.device
        let pageUrl = String(format: "https://com.mxchip.bta/%@", path)
        if MXURLRouterService.canOpen(url: pageUrl) {
           mxAppLog("跳转到原生页面的参数：\(params)")
            MXURLRouter.open(url: pageUrl, params: params)
            callback("success", true)
        } else {
            if let url = URL(string: path), let link = arg["external"] as? Bool, link { //跳转外链
                UIApplication.shared.open(url)
                return
            }
        }
    }
    
    @objc func onReflushDevices(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.needRloadHomeListBlock?()
        callback("success", true)
    }
    
    @objc func getBarColor(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var alpha = 1.0 as Float
        if let newAlpha = arg["alpha"] as? Float {
            alpha = newAlpha
        }
        guard let rgb = arg["rgb"] as? String else {
            return
        }
        let bridgeVC = self.navigationController.viewControllers.first
        bridgeVC?.view.backgroundColor = UIColor(hex: rgb, alpha: alpha)
    }
    
    @objc func getBarHeight(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        let h = MXAppConfig.statusBarH
        let result = ["bottom":0,"top":h]
        callback(result, true)
    }
    
    @objc func setTitle(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        if let title = arg["title"] as? String {
            self.navigationItem?.title = title
        }
    }
}
