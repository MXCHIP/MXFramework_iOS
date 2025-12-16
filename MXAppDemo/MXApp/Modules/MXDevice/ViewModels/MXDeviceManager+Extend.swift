//
//  MXDeviceManager+Extend.swift
//  MXApp
//
//  Created by 华峰 on 2023/7/13.
//

import Foundation
import UIKit

extension MXDeviceManager {
    // 简洁控制板
    public func showLaconic(with device: MXDeviceInfo) -> Void {
        
        guard let pList = device.propertys else {
            return
        }
        
        let nameStr = device.showName ?? ""
        
        let cv = MXHomeDeviceControlView(title: nameStr, dataList: pList)
        cv.deviceInfo = device
        cv.didOptionCallback = { [weak self] in
            self?.showPanel(with: device)
        }
        cv.didSelectedCallback = { [weak self] (info: MXDeviceInfo, pInfo: MXDevicePropertyItem) in
            self?.setProperty(with: info, pInfo: pInfo)
        }
        cv.show()
    }
    
    // 打开h5面板
    public func showPanel(with device: MXDeviceInfo) -> Void {
        self.gotoControlPanel(with: device)
    }
    
    // 跳转到面板
    public func gotoControlPanel(with device: MXDeviceInfo, testUrl:String? = nil) -> Void {
        if let url = testUrl, url.count > 0 {
            var params = [String : Any]()
            params["device"] = device
            params["homeId"] = MXHomeManager.shard.currentHome?.homeId
            params["networkKey"] = MXHomeManager.shard.currentHome?.networkKey
            params["testUrl"] = url
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/plan", params: params)
            return
        }
        if device.category_id == 130308 {
            var params = [String : Any]()
            params["device"] = device
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/cameraPlan", params: params)
            return
        }
        if let pk = device.productKey {
            MXToastHUD.show()
            MXAPI.product.h5PlanVersion(productKey: pk) { (data: Any, message: String, code: Int) in
                MXToastHUD.dismiss()
                if code == 0, let dataDic = data as? [String : Any], let _ = dataDic["url"] as? String {
                    var params = [String : Any]()
                    params["device"] = device
                    params["homeId"] = MXHomeManager.shard.currentHome?.homeId
                    params["networkKey"] = MXHomeManager.shard.currentHome?.networkKey
                    params["testUrl"] = testUrl
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/device/plan", params: params)
                    return
                } else if let _ = UserDefaults.standard.value(forKey: "MX_H5Version_" + (device.productKey ?? "")) as? String  {
                    var params = [String : Any]()
                    params["device"] = device
                    params["homeId"] = MXHomeManager.shard.currentHome?.homeId
                    params["networkKey"] = MXHomeManager.shard.currentHome?.networkKey
                    params["testUrl"] = testUrl
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/device/plan", params: params)
                    return
                }
                var params = [String : Any]()
                params["iotId"] = device.iotId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
            }
        }
    }
}
