//
//  MXEasyLinkProvisionPage.swift
//  MXApp
//
//  Created by huafeng on 2025/11/13.
//

import MXFogProvision
import UIKit

public class MXEasyLinkProvisionPage: MXBaseViewController {
    
    var animationView : MXAutoAnimationView = MXAutoAnimationView(frame: .zero)
    public var networkKey : String?
    public var wifiSSID : String?
    public var wifiPassword : String?
    public var productInfo : MXProductInfo?
    var roomId: Int?
    
    lazy var notFoundBtn : UIButton = {
        let _notFoundBtn = UIButton(type: .custom)
        _notFoundBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        _notFoundBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_not_found_device"), for: .normal)
        _notFoundBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        _notFoundBtn.backgroundColor = .white
        _notFoundBtn.layer.borderWidth = 1
        _notFoundBtn.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        _notFoundBtn.layer.cornerRadius = 22
        _notFoundBtn.tag = 20003
        _notFoundBtn.addTarget(self, action: #selector(startProvision), for: .touchUpInside)
        return _notFoundBtn
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_found_device")
        
        animationView = MXAutoAnimationView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 480))
        self.contentView.addSubview(animationView)
        animationView.pin.left().right().bottom().height(480)
        
        self.contentView.addSubview(self.notFoundBtn)
        self.notFoundBtn.pin.width(136).height(44).bottom(24).hCenter()
        self.notFoundBtn.isHidden = true
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.animationView.pin.left().right().bottom().height(480)
        self.notFoundBtn.pin.width(136).height(44).bottom(24).hCenter()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notFoundBtn.isHidden = true
        self.animationView.refreshAnimation()
        self.startProvision()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MXEasyLinkProvision.shared.cleanProvisionCache()
        
    }
    
    @objc func startProvision() {
        guard let ssid = self.wifiSSID else {
            return
        }
        self.notFoundBtn.isHidden = true
        var customParams = [String: Any]()
        customParams["mqtturl"] = MXAppConfig.MXIotMQTTHost
        customParams["httpurl"] = MXAppConfig.MXIotHTTPHost
        MXEasyLinkProvision.shared.startProvision(pk:nil,
                                                 ssid: ssid,
                                                 password: self.wifiPassword,
                                                 custom: customParams,
                                                 delegate: self)
    }
    
    func bindDevice(info: MXProvisionDeviceInfo) {
        MXDeviceManager.bindDevice(info: info) { isSuccess, device in
            if isSuccess {
                var device_list = [MXDeviceInfo]()
                let device = MXDeviceInfo()
                device.productName = info.productInfo?.name
                device.productKey  = info.productInfo?.product_key
                device.image = info.productInfo?.image
                device.iotId = info.iotId
                device.isFavorite = true
                device_list.append(device)
                
                var params = [String :Any]()
                params["devices"] = device_list
                params["roomId"] = self.roomId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/settingRoom", params: params)
            } else {
                self.notFoundBtn.isHidden = false
            }
        }
    }
    
}

extension MXEasyLinkProvisionPage: MXFogProvisionDelegate {
    public func mxFogProvisionFinish(productKey:String?, deviceName: String?, error: NSError?) {
        if error == nil {
            let device = MXProvisionDeviceInfo()
            device.deviceName = deviceName
            device.productInfo = MXProductManager.shard.getProductInfo(pk: productKey)
            self.bindDevice(info: device)
        } else {
            self.notFoundBtn.isHidden = false
        }
    }
    
    public func mxFogProvisionRequestRandom(productKey:String?,
                                           deviceName: String?,
                                           handler: @escaping ((String?) -> Void)) {
        var params = [String : Any]()
        params["device_name"] = productKey
        params["product_key"] = deviceName
        MXDeviceManager.requestFogRandom(params: params, handler: handler)
    }
    
    public func mxFogProvisionRequestConnectStatus(productKey:String?,
                                                   deviceName: String?,
                                                   random: String?,
                                                   handler: @escaping ((Bool) -> Void)) {
        var params = [String : Any]()
        params["device_name"] = deviceName
        params["product_key"] = productKey
        params["random"] = random
        MXDeviceManager.requestFogConnectStatus(params: params, handler: handler)
    }
}

extension MXEasyLinkProvisionPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXEasyLinkProvisionPage()
        controller.networkKey = params["networkKey"] as? String ?? MXHomeManager.shard.currentHome?.networkKey
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
