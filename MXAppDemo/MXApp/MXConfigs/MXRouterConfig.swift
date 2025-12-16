//
//  MXRouterManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/11.
//

import Foundation

class MXRouterConfig: NSObject {
    
    static func registerRouter() {
        MXURLRouterService.register(key: "com.mxchip.bta/page/account/input", module: MXAccountInputPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/account/password", module: MXPasswordInputPage.self)

        MXURLRouterService.register(key: "com.mxchip.bta/page/device/search", module: MXAddDeviceViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/search/search", module: MXAddDeviceSearchViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/plan", module: MXBridgeWebViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/provision", module: MXAddDeviceStepViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/wifiPassword", module: MXInputWifiPasswordViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/autoSearch", module: MXAutoSearchViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/deviceInit", module: MXAddDeviceInitViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/detail", module: MXDeviceDetailViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/addHelp", module: MXAddDeviceHelpPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/provision/easylink", module: MXEasyLinkProvisionPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/provisionStep", module: MXDeviceProvisionFailPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/room/devices", module: MXRoomDevicesPage.self)
    }
    
}
