//
//  MXAutoSearchViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/23.
//

import Foundation
import UIKit
import CoreBluetooth

public class MXAutoSearchViewController: MXBaseViewController {
    
    var animationView : MXAutoAnimationView = MXAutoAnimationView(frame: .zero)
    public var networkKey : String?
    var list = Array<MXProvisionDeviceInfo>()
    var selectedNum:Int = 0
    var maxSelectedNum: Int = 30
    var permissionList = Array<[String : Any]>()
    var HeaderView: MXSearchDeviceHeader = MXSearchDeviceHeader(frame: .zero)
    
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    public var productInfo : MXProductInfo?
    
    public var isReplace: Bool?
    public var replacedDevice: MXDeviceInfo?
    public var scanTimeout: Int = 0  //扫描超时时间
    
    var roomId: Int?

    lazy var selectedBtn : UIButton = {
        let _selectedBtn = UIButton(type: .custom)
        _selectedBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        _selectedBtn.setTitle(String(format: "%@(%d/%d)", MXAppConfig.mxLocalized(key:"mx_provision_select_all"),self.selectedNum,self.maxSelectedNum), for: .normal)
        _selectedBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        _selectedBtn.backgroundColor = .white
        _selectedBtn.layer.borderWidth = 1
        _selectedBtn.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        _selectedBtn.layer.cornerRadius = 22
        _selectedBtn.tag = 20001
        _selectedBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return _selectedBtn
    }()
    
    lazy var addBtn : UIButton = {
        let _addBtn = UIButton(type: .custom)
        _addBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        _addBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_add_device"), for: .normal)
        _addBtn.setTitleColor(.white, for: .normal)
        _addBtn.setTitleColor(UIColor(hex: "FFFFFF", alpha: 0.5), for: .disabled)
        _addBtn.setBackgroundColor(color: MXAppConfig.MXColor.theme, forState: .normal)
        //_addBtn.setBackgroundColor(color: UIColor(hex:MXAppConfiguration.MXColor.theme.toHexString, alpha: 0.5), forState: .disabled)
        _addBtn.layer.cornerRadius = 22
        _addBtn.tag = 20002
        _addBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return _addBtn
    }()
    
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
        _notFoundBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return _notFoundBtn
    }()
    
    @objc func menuBtnAction(_ sender : UIButton) {
        switch sender.tag {
        case 20001:
            self.selectDevices()
            break
        case 20002:
            self.gotoProvisionPage()
            break
        case 20003:
            self.gotoInitPage()
            break
        default:
            break
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.title = MXAppConfig.mxLocalized(key:"mx_found_device")
        
        self.HeaderView = MXSearchDeviceHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        
        animationView = MXAutoAnimationView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 480))
        self.contentView.addSubview(animationView)
        animationView.pin.left().right().bottom().height(480)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.all()
        
        self.contentView.addSubview(self.selectedBtn)
        self.selectedBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        
        self.contentView.addSubview(self.addBtn)
        self.addBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        
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
        self.tableView.pin.all()
        self.selectedBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.addBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        self.notFoundBtn.pin.width(136).height(44).bottom(24).hCenter()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedBtn.isHidden = true
        self.addBtn.isEnabled = false
        self.addBtn.isHidden = true
        self.notFoundBtn.isHidden = true
        self.list.forEach { (device:MXProvisionDeviceInfo) in
            device.isSelected = false
        }
        self.list.removeAll()
        self.selectedNum = 0
        self.selectedBtn.setTitle(String(format: "%@(%d/%d)", MXAppConfig.mxLocalized(key:"mx_provision_select_all"),self.selectedNum,self.maxSelectedNum), for: .normal)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.loadPermissList()
        
        self.animationView.refreshAnimation()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MXDeviceScanManager.shared.stopScan()
        
    }
    
    // 程序进入前台 开始活跃
    @objc func appBecomeActive() {
        self.loadPermissList()
    }
    
    func loadPermissList()  {
        self.permissionList.removeAll()
        let group = DispatchGroup()
        group.enter()
        MXSystemAuth.authBluetooth { [weak self] (isAuth: Bool) in
            if !isAuth {
                self?.addBluetoothAuthAlert()
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.refreshCurrentView()
        }
    }
    
    func addBluetoothAuthAlert() {
        if (self.permissionList.first(where: { $0["name"] as? String == MXAppConfig.mxLocalized(key:"mx_permission_ble_switch")}) == nil) {
            var item = [String : Any]()
            item["name"] =  MXAppConfig.mxLocalized(key:"mx_permission_ble_switch")
            item["icon"] = "\u{e683}"
            self.permissionList.append(item)
        }
    }
    
    func refreshCurrentView() {
        if self.permissionList.count > 0 {
            self.animationView.isHidden = true
            self.HeaderView.nameLB.text = MXAppConfig.mxLocalized(key:"mx_provision_search_prepare")
            self.HeaderView.desLB.text = MXAppConfig.mxLocalized(key:"mx_permission_ble_switch") + "\u{e6df}"
        } else {
            self.animationView.isHidden = false
            self.HeaderView.nameLB.text = MXAppConfig.mxLocalized(key:"mx_provision_searching")
            self.HeaderView.desLB.text = MXAppConfig.mxLocalized(key:"mx_provision_ensure_device_state") + "\u{e6df}"
            
            self.list.removeAll()
            self.scanMeshDevices()
        }
        
        if self.list.count > 0 {
            self.tableView.tableHeaderView = nil
        } else {
            self.tableView.tableHeaderView = self.HeaderView
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
        tableView.separatorStyle = .none
        
        tableView.register(MXPermissionCell.self, forCellReuseIdentifier: String(describing: MXPermissionCell.self))
        tableView.register(DiscoveryDeviceCell.self, forCellReuseIdentifier: String(describing: DiscoveryDeviceCell.self))
        
        return tableView
    }()
    
    func scanMeshDevices() {
        MXDeviceScanManager.shared.stopScan()
        MXDeviceScanManager.shared.startScan(timeout: self.scanTimeout) { (devices:[[String: Any]], isStop: Bool, item: [String: Any]?) in
            if let addDevice = item {
                let deviceInfo = MXProvisionDeviceInfo.init(params: addDevice)
                if let pInfo = self.productInfo {
                    if deviceInfo.productInfo?.product_key == pInfo.product_key {
                        self.list.append(deviceInfo)
                    }
                } else if deviceInfo.productInfo != nil {
                    self.list.append(deviceInfo)
                }
            } else {
                var newList = [MXProvisionDeviceInfo]()
                for info in devices {
                    let deviceInfo = MXProvisionDeviceInfo.init(params: info)
                    if let pInfo = self.productInfo {
                        if deviceInfo.productInfo?.product_key == pInfo.product_key {
                            newList.append(deviceInfo)
                        }
                    } else if deviceInfo.productInfo != nil {
                        newList.append(deviceInfo)
                    }
                }
                self.list = newList
            }
            
            if self.list.count > 0 {
                if let _ = self.isReplace {
                    self.selectedBtn.isHidden = true
                    self.addBtn.isHidden = true
                    self.tableView.tableHeaderView = nil
                } else {
                    self.selectedBtn.isHidden = false
                    self.addBtn.isHidden = false
                    self.tableView.tableHeaderView = nil
                }
                self.notFoundBtn.isHidden = true
            } else {
                self.selectedBtn.isHidden = true
                self.addBtn.isHidden = true
                if isStop {
                    self.notFoundBtn.isHidden = false
                }
                self.tableView.tableHeaderView = self.HeaderView
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func addDeviceIntoList(device: MXProvisionDeviceInfo) {
        if self.list.firstIndex(where: {$0.mac == device.mac}) != nil {
            return
        }
        self.list.append(device)
    }
    
    func selectDevices() {
        let selectedList = self.list.filter { (device:MXProvisionDeviceInfo) in
            return device.isSelected
        }
        self.selectedNum = selectedList.count
        if selectedNum < self.maxSelectedNum {
            for info in self.list {
                if !info.isSelected {
                    info.isSelected = true
                    self.selectedNum += 1
                    if self.selectedNum >= self.maxSelectedNum {
                        break
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.selectedBtn.setTitle(String(format: "%@(%d/%d)", MXAppConfig.mxLocalized(key:"mx_provision_select_all"),self.selectedNum,self.maxSelectedNum), for: .normal)
            if self.selectedNum > 0 {
                self.addBtn.isEnabled = true
            } else {
                self.addBtn.isEnabled = false
            }
            self.tableView.reloadData()
        }
    }
    
    func gotoInitPage() {
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        params["isReplace"] = self.isReplace
        params["replacedDevice"] = self.replacedDevice
        params["roomId"] = self.roomId
        let url = "https://com.mxchip.bta/page/device/deviceInit"
        MXURLRouter.open(url: url, params: params)
    }
    
    func gotoProvisionPage() {
        var devices = Array<MXProvisionDeviceInfo>()
        var hasWifiDevice = false
        var isSkipWifi = true
        for info in self.list {
            if info.isSelected {
                devices.append(info)
                
                if (info.productInfo?.needConnectWifi ?? true) {
                    hasWifiDevice = true
                   mxAppLog("设备配网类型：\(String(describing: info.productInfo?.link_type_id))")
                    if info.productInfo?.link_type_id != 11 {
                        isSkipWifi = false
                    }
                }
            }
        }
        
        if devices.count <= 0 {
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: MXAppConfig.mxLocalized(key:"mx_select_device_hint"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            }
            alert.show()
            return
        }
        
        if hasWifiDevice && self.wifiSSID == nil {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = devices
            params["isSkip"] = isSkipWifi
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/wifiPassword", params: params)
            
        } else {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = devices
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
            
        }
    }
    
    
    func goToReplacePage(with provisionDevice: MXProvisionDeviceInfo) -> Void {
        guard let isReplace = self.isReplace,
              let replacedDevice = self.replacedDevice,
              let productInfo = provisionDevice.productInfo
        else { return }
        
        var url = ""
        var params = [String: Any]()
        
        let isWifiDevice = provisionDevice.productInfo?.needConnectWifi ?? true
        let isSkipWifi = productInfo.link_type_id == 11
        
        params["networkKey"] = self.networkKey
        params["provisionDevice"] = provisionDevice
        
        if isWifiDevice && self.wifiSSID == nil {
            url = "https://com.mxchip.bta/page/device/wifiPassword"
            params["isSkip"] = isSkipWifi
            params["isReplace"] = isReplace
            params["replacedDevice"] = replacedDevice
        } else {
            url = "https://com.mxchip.bta/page/mine/deviceDoneReplace"
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["replacedDevice"] = replacedDevice
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: url, params: params)
    }
    
}

extension MXAutoSearchViewController:UITableViewDataSource,UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if self.permissionList.count > 0 {
            return self.permissionList.count
        } else {
            return self.list.count
        }
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.permissionList.count > 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXPermissionCell.self)) as? MXPermissionCell
            if cell == nil{
                cell = MXPermissionCell(style: .default, reuseIdentifier: String (describing: MXPermissionCell.self))
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            if self.permissionList.count > indexPath.section {
                let deviceInfo = self.permissionList[indexPath.section]
                cell?.refreshView(info: deviceInfo)
            }
            return cell!
        } else  {
            var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: DiscoveryDeviceCell.self)) as? DiscoveryDeviceCell
            if cell == nil{
                cell = DiscoveryDeviceCell(style: .default, reuseIdentifier: String (describing: DiscoveryDeviceCell.self))
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            if list.count > indexPath.section {
                let deviceInfo = list[indexPath.section]
                cell?.refreshView(info: deviceInfo, isReplace: self.isReplace)
            }
            return cell!
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.permissionList.count > 0 {
            if self.permissionList.count > indexPath.section {
                //let deviceInfo = self.permissionList[indexPath.section]
                MXSystemAuth.authSystemSetting(urlString: nil) { (isSuccess: Bool) in
                    
                }
            }
        } else {
            if list.count > indexPath.section {
                let deviceInfo = list[indexPath.section]
                if let _ = self.isReplace {
                    self.goToReplacePage(with: deviceInfo)
                } else {
                    if deviceInfo.isSelected {
                        deviceInfo.isSelected = false
                        self.selectedNum -= 1
                    } else {
                        if self.selectedNum < self.maxSelectedNum {
                            deviceInfo.isSelected = true
                            self.selectedNum += 1
                        }
                    }
                    self.selectedBtn.setTitle(String(format: "%@(%d/%d)", MXAppConfig.mxLocalized(key:"mx_provision_select_all"),self.selectedNum,self.maxSelectedNum), for: .normal)
                    if self.selectedNum > 0 {
                        self.addBtn.isEnabled = true
                    } else {
                        self.addBtn.isEnabled = false
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
        hView.backgroundColor = .clear
        return hView
    }
}

extension MXAutoSearchViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAutoSearchViewController()
        controller.networkKey = params["networkKey"] as? String ?? MXHomeManager.shard.currentHome?.networkKey
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.isReplace = params["isReplace"] as? Bool
        controller.replacedDevice = params["replacedDevice"] as? MXDeviceInfo
        controller.scanTimeout = (params["scanTimeout"] as? Int) ?? 0
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
