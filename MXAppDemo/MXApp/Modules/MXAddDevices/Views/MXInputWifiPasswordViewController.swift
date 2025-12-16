//
//  MXInputWifiPasswordViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/26.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import UIKit

public class MXInputWifiPasswordViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String?
    public var deviceList = Array<MXProvisionDeviceInfo>()
    public var isSkip = false
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    public var productInfo : MXProductInfo?
    
    var wifiParams = [String : String]()
    
    var roomId: Int?

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MXAppConfig.MXWhite.level1
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.title = MXAppConfig.mxLocalized(key:"mx_set_network")
        
        if let wifiInfo = UserDefaults.standard.object(forKey: "kProvisionWifi") as? [String : String] {
            self.wifiParams = wifiInfo
        }
        
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left().top().right().height(84)
        
        self.contentView.addSubview(self.ssidView)
        self.ssidView.pin.below(of: self.headerView).marginTop(24).left(24).right(24).height(50)
        self.ssidView.nameLB.delegate = self
        self.ssidView.nameLB.returnKeyType = .done
        self.ssidView.nameLB.placeholder = MXAppConfig.mxLocalized(key: "mx_wifi_ssid_hint")
        
        self.contentView.addSubview(self.ssidTipsLB)
        self.ssidTipsLB.pin.below(of: self.ssidView).marginTop(10).left(48).right(24).height(16)
        self.ssidTipsLB.isHidden = true
        
        self.contentView.addSubview(self.paswordView)
        self.paswordView.pin.below(of: self.ssidTipsLB).marginTop(16).left(24).right(24).height(50)
        self.paswordView.nameLB.delegate = self
        self.paswordView.nameLB.returnKeyType = .done
        self.paswordView.nameLB.placeholder = MXAppConfig.mxLocalized(key: "mx_wifi_password_hint")
        
        self.contentView.addSubview(self.nextBtn)
        self.nextBtn.pin.below(of: self.paswordView).marginTop(32).left(24).right(24).height(50)
        self.nextBtn.isEnabled = false
        
        self.contentView.addSubview(self.skipLB)
        self.skipLB.pin.below(of: self.nextBtn).marginTop(16).width(60).height(16).hCenter()
        self.skipLB.isHidden = !self.isSkip
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXWhite.level1
        
        if self.isSkip {
            self.mxNavigationBar.rightItem.setTitle(MXAppConfig.mxLocalized(key: "mx_skip"), for: .normal)
            self.mxNavigationBar.rightItem.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
            self.mxNavigationBar.rightView.addSubview(self.mxNavigationBar.rightItem)
            self.mxNavigationBar.layoutSubviews()
        } else {
            for v in self.mxNavigationBar.rightView.subviews {
                v.removeFromSuperview()
            }
        }
        
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headerView.pin.left().top().right().height(84)
        self.ssidView.pin.below(of: self.headerView).marginTop(24).left(24).right(24).height(50)
        self.ssidTipsLB.pin.below(of: self.ssidView).marginTop(10).left(48).right(24).height(16)
        if self.ssidTipsLB.isHidden {
            self.paswordView.pin.below(of: self.ssidView).marginTop(24).left(24).right(24).height(50)
        } else {
            self.paswordView.pin.below(of: self.ssidTipsLB).marginTop(16).left(24).right(24).height(50)
        }
        self.nextBtn.pin.below(of: self.paswordView).marginTop(32).left(24).right(24).height(50)
        self.skipLB.pin.below(of: self.nextBtn).marginTop(16).left(24).right(24).minHeight(16).maxHeight(40)
    }
    
    private lazy var selectView : MXSelectWifiView = {
        let _wifiSelectView = MXSelectWifiView(frame: CGRect(x: 60, y: 248, width: MXAppConfig.mxScreenWidth - 135, height: 216))
        _wifiSelectView.didSelectedItemCallback = { [weak self] (selectValue: String) in
            self?.ssidView.nameLB.text = selectValue
            self?.wifiSSID = selectValue
            
            if let passwordStr = self?.wifiParams[selectValue] {
                self?.wifiPassword = passwordStr
                self?.paswordView.nameLB.text = passwordStr
            }
            self?.view.endEditing(true)
            
            if self?.wifiSSID != nil {
                self?.nextBtn.isUserInteractionEnabled = true
                self?.nextBtn.backgroundColor = MXAppConfig.MXColor.theme
            } else {
                self?.nextBtn.isUserInteractionEnabled = false
                self?.nextBtn.backgroundColor = UIColor(hex:MXAppConfig.MXColor.theme.toHexString, alpha: 0.5)
            }
        }
        return _wifiSelectView
    }()
    
    private lazy var headerView : MXWifiPasswordHeaderView = {
        let _headerView = MXWifiPasswordHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: 84))
        return _headerView
    }()
    
    private lazy var ssidView : MXWifiInputView = {
        let _ssidView = MXWifiInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _ssidView.iconView.text = "\u{e681}"
        _ssidView.actionBtn.setTitle("\u{e682}", for: .normal)
        _ssidView.didActionCallback = {
            if let url = URL(string: "App-Prefs:root=WIFI"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return _ssidView
    }()
    
    private lazy var ssidTipsLB: UILabel = {
        let _lab = UILabel(frame: .zero)
        _lab.backgroundColor = .clear
        _lab.font = UIFont.mxSystemFont(ofSize: 12);
        _lab.textColor = MXAppConfig.MXColor.yellow
        _lab.textAlignment = .left
        _lab.text = MXAppConfig.mxLocalized(key:"mx_wifi_ssid_error")
        return _lab
    }()
    
    private lazy var paswordView : MXWifiInputView = {
        let _paswordView = MXWifiInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _paswordView.iconView.text = "\u{e694}"
        _paswordView.iconView.textColor = MXAppConfig.MXColor.primaryText
        _paswordView.actionBtn.setTitle("\u{e695}", for: .normal)
        _paswordView.actionBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        _paswordView.nameLB.isSecureTextEntry = true
        _paswordView.didActionCallback = { [weak _paswordView] in
            if let isSecure = _paswordView?.nameLB.isSecureTextEntry, isSecure {
                _paswordView?.nameLB.isSecureTextEntry = false
                _paswordView?.actionBtn.setTitle("\u{e693}", for: .normal)
            } else {
                _paswordView?.nameLB.isSecureTextEntry = true
                _paswordView?.actionBtn.setTitle("\u{e695}", for: .normal)
            }
        }
        return _paswordView
    }()
    
    private lazy var nextBtn : MXColorButton = {
        let _nextBtn = MXColorButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_next"), for: .normal)
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
    
    private lazy var skipLB : UILabel = {
        let _skipLB = UILabel(frame: .zero)
        _skipLB.font = UIFont.mxSystemFont(ofSize: 14);
        _skipLB.textColor = MXAppConfig.MXColor.title
        _skipLB.textAlignment = .center
        _skipLB.text = MXAppConfig.mxLocalized(key:"mx_skip_set")
        _skipLB.numberOfLines = 0
        return _skipLB
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkLocationPermiss()
    }
    
    func checkLocationPermiss() {
        MXSystemAuth.authLocation { isSuccess in
            if !isSuccess {
                let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_permission_location_denied"), message: String(format: MXAppConfig.mxLocalized(key:"mx_location_auth_des"), MXAppConfig.mxLocalized(key:"mx_app_name")), leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_go_setting")) {
                    self.getWifiSSID()
                } rightButtonCallBack: {
                    MXSystemAuth.authSystemSetting( urlString: nil) { (isSuccess: Bool) in
                        
                    }
                }
                alert.show()
                return
            }
            if #available(iOS 14.0, *) {
                if isSuccess, MXSystemAuth.shard.locationAuthManager.accuracyAuthorization != .fullAccuracy {
                    // 向用户申请临时开启一次精确位置权限
                    MXSystemAuth.shard.locationAuthManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "WantsToGetWiFiSSID") { (error:Error?) in
                        self.getWifiSSID()
                    }
                    return
                }
            }
            self.getWifiSSID()
        }
    }
    
    // 程序进入前台 开始活跃
    @objc func appBecomeActive() {
        self.checkLocationPermiss()
        self.getWifiSSID()
    }
}

extension MXInputWifiPasswordViewController {
    
    func getWifiSSID() {
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent(completionHandler: { currentNetwork in
                if let ssid = currentNetwork?.ssid {
                    self.ssidView.nameLB.text = ssid
                    self.wifiSSID = ssid
                    self.paswordView.nameLB.text = self.wifiParams[ssid]
                    self.wifiPassword = self.wifiParams[ssid]
                    
                    if ssid.contains("_5G") || ssid.contains("-5G") {
                        self.ssidTipsLB.isHidden = false
                    } else {
                        self.ssidTipsLB.isHidden = true
                    }
                    self.viewWillLayoutSubviews()
                    
                    if (self.wifiSSID?.count ?? 0) > 0 {
                        self.nextBtn.isEnabled = true
                        self.nextBtn.backgroundColor = MXAppConfig.MXColor.theme
                    } else {
                        self.nextBtn.isEnabled = false
                        self.nextBtn.backgroundColor = UIColor(hex:MXAppConfig.MXColor.theme.toHexString, alpha: 0.5)
                    }
                }
            })
        } else {
            if let interfaces = CNCopySupportedInterfaces(),
               let interfacesArray = CFBridgingRetain(interfaces) as? Array<AnyObject> {
                if interfacesArray.count > 0 {
                    let interfaceName = interfacesArray[0] as! CFString
                    if let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName) {
                        if let interfaceData = ussafeInterfaceData as? Dictionary<String, Any>,
                           let ssid = interfaceData["SSID"] as? String {
                            self.ssidView.nameLB.text = ssid
                            self.wifiSSID = ssid
                            self.paswordView.nameLB.text = self.wifiParams[ssid]
                            self.wifiPassword = self.wifiParams[ssid]
                            
                            if ssid.contains("_5G") || ssid.contains("-5G") {
                                self.ssidTipsLB.isHidden = false
                            } else {
                                self.ssidTipsLB.isHidden = true
                            }
                            self.viewWillLayoutSubviews()
                            
                            if (self.wifiSSID?.count ?? 0) > 0 {
                                self.nextBtn.isEnabled = true
                            } else {
                                self.nextBtn.isEnabled = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func nextPage() {
        self.view.endEditing(true)
        
        guard let ssid = self.wifiSSID, ssid.count > 0 else {
            return
        }
        
        if let pairType = self.productInfo?.link_type_id, pairType == 2 {  //Wi-Fi一键配网
            self.gotoEasyLinkProvisionPage()
            return
        }
        
        if self.deviceList.count > 0 {  //自动发现进入的，不需要进入设备状态确认页面
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = self.deviceList
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
        } else {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["productInfo"] = self.productInfo
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["devices"] = self.deviceList
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
        }
    }
    
    @objc func skipAction() {
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: MXAppConfig.mxLocalized(key:"mx_skip_set_wifi_des"), leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
            
        } rightButtonCallBack: { [self] in
            if self.deviceList.count > 0 {  //自动发现进入的，不需要进入设备状态确认页面
                var params = [String :Any]()
                params["networkKey"] = self.networkKey
                params["devices"] = self.deviceList
                params["roomId"] = self.roomId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
            } else {
                var params = [String :Any]()
                params["networkKey"] = self.networkKey
                params["productInfo"] = self.productInfo
                params["roomId"] = self.roomId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
            }
        }
        alert.show()

    }
    
    func searchWifi(name: String) {
        
        let list : [String] = self.wifiParams.map { (key: String, value: String) -> String in
            return key
        }
        if list.count > 0 {
            self.selectView.dataList = list
            self.selectView.show()
        } else {
            self.selectView.hide()
        }
    }
    
    func gotoEasyLinkProvisionPage() {
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        params["roomId"] = self.roomId
        params["ssid"] = self.wifiSSID
        params["password"] = self.wifiPassword
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision/easylink", params: params)
    }
}

extension MXInputWifiPasswordViewController : UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let mStr = text.replacingCharacters(in: textRange, with: string)
            if textField == self.paswordView.nameLB {
                self.wifiPassword = mStr.trimmingCharacters(in: .whitespaces)
            } else if textField == self.ssidView.nameLB {
                let searchStr = mStr.trimmingCharacters(in: .whitespaces)
                self.wifiSSID = searchStr
                self.searchWifi(name: searchStr)
                
                if searchStr.contains("_5G") || searchStr.contains("-5G") {
                    self.ssidTipsLB.isHidden = false
                } else {
                    self.ssidTipsLB.isHidden = true
                }
                self.viewWillLayoutSubviews()
            }
        }
        
        if (self.wifiSSID?.count ?? 0) > 0 {
            self.nextBtn.isEnabled = true
            self.nextBtn.backgroundColor = MXAppConfig.MXColor.theme
        } else {
            self.nextBtn.isEnabled = false
            self.nextBtn.backgroundColor = UIColor(hex:MXAppConfig.MXColor.theme.toHexString, alpha: 0.5)
        }
        
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.ssidView.nameLB {
            let searchStr = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
            self.searchWifi(name: searchStr)
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.paswordView.nameLB {
            self.wifiPassword = textField.text?.trimmingCharacters(in: .whitespaces)
        } else if textField == self.ssidView.nameLB {
            self.wifiSSID = textField.text?.trimmingCharacters(in: .whitespaces)
            if let wifiName = textField.text?.trimmingCharacters(in: .whitespaces) {
                self.paswordView.nameLB.text = self.wifiParams[wifiName]
                self.wifiPassword = self.wifiParams[wifiName]
                
                if wifiName.contains("_5G") || wifiName.contains("-5G") {
                    self.ssidTipsLB.isHidden = false
                } else {
                    self.ssidTipsLB.isHidden = true
                }
                self.viewWillLayoutSubviews()
            }
        }
        
        self.selectView.hide()
        
        if let ssid = self.wifiSSID, ssid.count > 0 {
            self.nextBtn.isEnabled = true
            self.nextBtn.backgroundColor = MXAppConfig.MXColor.theme
        } else {
            self.nextBtn.isEnabled = false
            self.nextBtn.backgroundColor = UIColor(hex:MXAppConfig.MXColor.theme.toHexString, alpha: 0.5)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MXInputWifiPasswordViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXInputWifiPasswordViewController()
        controller.networkKey = params["networkKey"] as? String
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.isSkip = (params["isSkip"] as? Bool) ?? false
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
