//
//  MXAddDeviceStepViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/25.
//

import Foundation
import UIKit
import CoreBluetooth
import MXFogProvision

public class MXAddDeviceStepViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String?
    public var deviceList = [MXProvisionDeviceInfo]()
    let provisionQueueMax: Int = 1
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    var roomId: Int?
    var roomInfo: MXRoomInfo?
    
    var successNum = 0
    var failNum = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_add_device")
        
        for item in self.deviceList {
            self.createProvisionSteps(device: item)
        }
        
        if let room_id = self.roomId, let room = MXRoomManager.shard.currentRoomList.first(where: {$0.roomId == room_id}) {
            self.roomInfo = room
        } else if let defaultRoom = MXRoomManager.shard.currentRoomList.first(where: {$0.is_default}) {
            self.roomInfo = defaultRoom
        }
        
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left(10).right(10).top().height(50)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.headerView).marginTop(0).left(10).right(10).bottom()
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.isHidden = true
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        
        MeshSDK.sharedInstance.disconnect()
        self.startProvisionDevice()
        
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        MXFogBleProvision.shared.cleanProvisionCache()
        MXMeshProvisionManager.shared.mxProvisionFinish()
        MeshSDK.sharedInstance.connect()
        
    }
    
    public override func gotoBack() {
        if self.bottomView.isHidden {  //正在配网中
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: MXAppConfig.mxLocalized(key:"mx_provision_back_des"), leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            } rightButtonCallBack: {
                
                MXFogBleProvision.shared.cleanProvisionCache()
                MXMeshProvisionManager.shared.mxProvisionFinish()
                MeshSDK.sharedInstance.disconnect()
                MeshSDK.sharedInstance.connect()
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.show()
            return
        }
        MeshSDK.sharedInstance.connect()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headerView.pin.left(10).right(10).top().height(50)
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        if self.bottomView.isHidden {
            self.tableView.pin.below(of: self.headerView).marginTop(0).left(10).right(10).bottom()
        } else {
            self.tableView.pin.left(10).right(10).below(of: self.headerView).marginTop(0).above(of: self.bottomView).marginBottom(10)
        }
    }
    
    private lazy var headerView : UILabel = {
        
        let _headerView = UILabel(frame: CGRect(x: 0, y: 0, width: MXAppConfig.mxScreenWidth - 20, height: 50))
        _headerView.backgroundColor = UIColor.clear
        _headerView.textAlignment = .left
        _headerView.font = UIFont.mxSystemFont(ofSize: 14)
        _headerView.textColor = MXAppConfig.MXColor.secondaryText
        _headerView.text = String(format: MXAppConfig.mxLocalized(key:"mx_provisioning_des"), self.deviceList.count, self.successNum)
        
        return _headerView
    }()
    
    private lazy var bottomView : MXAddDeviceBottomView = {
        let _bottomView = MXAddDeviceBottomView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 70))
        _bottomView.didActionCallback = { [weak self] (index: Int) in
            
            //离开当前页面重新连接
            MeshSDK.sharedInstance.connect()
            
            if index == 0 {
                if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAddDeviceViewController.self)}) as? MXAddDeviceViewController {
                    self?.navigationController?.popToViewController(searchVC, animated: true)
                } else if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAutoSearchViewController.self)}) as? MXAutoSearchViewController {
                    self?.navigationController?.popToViewController(searchVC, animated: true)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
//                var device_list = [MXDeviceInfo]()
//                self?.deviceList.forEach { (info:MXProvisionDeviceInfo) in
//                    if info.provisionStatus == 2 {
//                        let device = MXDeviceInfo()
//                        device.productName = info.productInfo?.name
//                        device.productKey  = info.productInfo?.product_key
//                        device.image = info.productInfo?.image
//                        device.iotId = info.iotId
//                        device.isFavorite = true
//                        device.uuid = info.uuid
//                        device.wifi_mac = info.wifi_mac
//                        device.eth_mac = info.eth_mac
//                        if let room = self?.roomInfo {
//                            device.roomId = room.roomId
//                            device.roomName = room.name
//                        }
//                        device_list.append(device)
//                    }
//                }
                if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAddDeviceViewController.self)}) as? MXAddDeviceViewController {
                    self?.navigationController?.popToViewController(searchVC, animated: true)
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        return _bottomView
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.separatorStyle = .none
        
        tableView.register(MXProvisionDeviceCell.self, forCellReuseIdentifier: String(describing: MXProvisionDeviceCell.self))
        
        return tableView
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MXAddDeviceStepViewController {
    
    func createProvisionSteps(device: MXProvisionDeviceInfo) {
        var steps = Array<String>()
        if (device.uuid?.count ?? 0) > 0 {
            if !(device.productInfo?.needConnectWifi ?? true) {
                steps = [MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble"),
                         MXAppConfig.mxLocalized(key:"mx_provisioning_step_config"),
                         MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind")]
            } else {
                if device.productInfo?.link_type_id == 11, self.wifiSSID == nil {
                    steps = [MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble"),
                             MXAppConfig.mxLocalized(key:"mx_provisioning_step_config"),
                             MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind")]
                } else {
                    steps = [MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble"),
                             MXAppConfig.mxLocalized(key:"mx_provisioning_step_config"),
                             MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_wifi"),
                             MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind")]
                }
            }
        } else {
            steps = [MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble"),
                     MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_wifi"),
                     MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind")]
        }

        var list = Array<MXProvisionStepInfo>()
        for stepName in steps {
            let stepItem = MXProvisionStepInfo()
            stepItem.name = stepName
            stepItem.status = 0
            list.append(stepItem)
        }
        device.provisionStepList = list
    }
    
    //开始配网，递归的方式一条一条配置
    func startProvisionDevice() {
        let unProvisionList = self.deviceList.filter({$0.provisionStatus == 0})
        let provisioningList = self.deviceList.filter({$0.provisionStatus == 1})
        if unProvisionList.count > 0 {
            if provisioningList.count < self.provisionQueueMax {
                for item in unProvisionList {
                    if item.device != nil {  //Mesh设备
                        if (item.uuid?.count ?? 0) > 0 {
                            item.provisionStatus = 1
                            //mesh配网
                            self.startMeshProvision(info: item)
                        } else {
                            item.provisionStatus = 3
                            self.failNum += 1
                        }
                        self.startProvisionDevice()
                        return
                    } else {
                        //Wi-Fi设备（蓝牙辅助）
                        item.provisionStatus = 1
                        self.startWifiProvision(info: item)
                        
                        self.startProvisionDevice()
                        return
                    }
                }
            }
            self.bottomView.isHidden = true
            self.viewWillLayoutSubviews()
        } else {
            if provisioningList.count == 0 {
                self.bottomView.isHidden = false
                self.viewWillLayoutSubviews()
            } else {
                self.bottomView.isHidden = true 
                self.viewWillLayoutSubviews()
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func provisionFail(uuid: String?) {
        if let item = self.deviceList.first(where: {$0.deviceIdentifier == uuid && $0.provisionStatus == 1}) {
            if let info = item.provisionStepList.first(where: { $0.status == 1 }) {
                info.status = 3
            }
            item.provisionStatus = 3
            self.failNum += 1
            
            if (item.uuid?.count ?? 0) > 0 {
                MXMeshProvisionManager.shared.nextGattSwitch()
            }
        }
        self.startProvisionDevice()
    }
    
    func provisionSuccess(uuid: String?) {
        if let item = self.deviceList.first(where: {$0.deviceIdentifier == uuid && $0.provisionStatus == 1}) {
            for i in 0..<item.provisionStepList.count {
                let info = item.provisionStepList[i]
                info.status = 2
            }
            item.provisionStatus = 2
            self.successNum += 1
            self.headerView.text = String(format: MXAppConfig.mxLocalized(key:"mx_provisioning_des"), self.deviceList.count, self.successNum)
            
            if let uuidStr = item.uuid, uuidStr.count > 0 {
                if self.deviceList.first(where: {($0.uuid?.count ?? 0) > 0 && ($0.provisionStatus == 0 || $0.provisionStatus == 1)}) == nil {
                    MeshSDK.sharedInstance.getGATTProxyStatus(uuid: uuidStr) { (result: [String: Any]) in
                        if let status = result["proxy_status"] as? Int, status != 1 {
                            MeshSDK.sharedInstance.disconnect()
                        } else { //最后一个Mesh设备配网成功
                            MXMeshManager.shard.meshConnectChange(status: 1)
                        }
                        MXMeshProvisionManager.shared.nextGattSwitch()
                        self.startProvisionDevice()
                    }
                    return
                } else {
                    MXMeshProvisionManager.shared.nextGattSwitch()
                }
            }
        }
        self.startProvisionDevice()
    }
    
    func getQuintupleData(info:MXProvisionDeviceInfo) {
        MXDeviceManager.getDeviceName(info: info) { isSuccess, device in
            if isSuccess {
                if info.productInfo?.link_type_id == 10 || (info.productInfo?.link_type_id == 11 && self.wifiSSID != nil) {
                    self.sendWifiConfigData(info: info)
                } else {
                    self.bindDevice(info: info)
                }
            } else {
                self.provisionFail(uuid: info.deviceIdentifier)
            }
        }
    }
    
    func sendWifiConfigData(info:MXProvisionDeviceInfo) {
        if let uuid = info.uuid, uuid.count > 0, let ssid = self.wifiSSID{
            info.refreshStep(step: (info.provisionStepList.firstIndex(where: {$0.name == MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_wifi")}) ?? 1))
            MXMeshDeviceMessage.sendWiFiPasswordToDevice(uuid: uuid, ssid: ssid, password: self.wifiPassword) { (isSuccess : Bool) in
                if isSuccess {
                    self.bindDevice(info: info)
                } else {
                    self.provisionFail(uuid: uuid)
                }
            }
        } else {
            self.provisionFail(uuid: info.uuid)
        }
    }
    
    func bindDevice(info: MXProvisionDeviceInfo) {
        //缓存Wi-Fi信息
        self.cacheWifiInfo()
        
        info.refreshStep(step: (info.provisionStepList.firstIndex(where: {$0.name == MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind")}) ?? 2))
        
        MXDeviceManager.bindDevice(info: info) { isSuccess, device in
            if isSuccess {
                MXDeviceManager.getDeviceVersion(device: device) { isSuccess, device in
                    MXDeviceManager.deviceProvisionFinish(device: device) { isSuccess, device in
                        self.provisionSuccess(uuid: device.deviceIdentifier)
                    }
                }
            } else {
                self.provisionFail(uuid: info.deviceIdentifier)
            }
        }
    }
    
    func cacheWifiInfo() {
        if let ssid = self.wifiSSID {
            var wifi_params = [String : String]()
            if let wifiInfos = UserDefaults.standard.object(forKey: "kProvisionWifi") as? [String : String] {
                wifi_params = wifiInfos
            }
            wifi_params[ssid] = self.wifiPassword ?? ""
            
            UserDefaults.standard.set(wifi_params, forKey: "kProvisionWifi")
            UserDefaults.standard.synchronize()
        }
    }
}


extension MXAddDeviceStepViewController:UITableViewDataSource,UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.deviceList.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXProvisionDeviceCell.self)) as? MXProvisionDeviceCell
        if cell == nil{
            cell = MXProvisionDeviceCell(style: .default, reuseIdentifier: String (describing: MXProvisionDeviceCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        if self.deviceList.count > indexPath.section {
            let item = self.deviceList[indexPath.section]
            cell?.refreshView(info: item)
            if item.provisionStatus == 3 {
                cell?.accessoryType = .disclosureIndicator
            }
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.deviceList.count > indexPath.section {
            let item = self.deviceList[indexPath.section]
            if item.provisionStatus == 3 {
                var params = [String :Any]()
                params["device"] = item
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provisionStep", params: params)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.1))
        hView.backgroundColor = .clear
        return hView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let fView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
        fView.backgroundColor = .clear
        return fView
    }
}

extension MXAddDeviceStepViewController:MXMeshProvisioningDelegate {
    
    func startMeshProvision(info: MXProvisionDeviceInfo) {
        info.refreshStep(step: (info.provisionStepList.firstIndex(where: {$0.name == MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble")}) ?? 0))
        guard let device = info.device, let peripheral = info.peripheral, let nk = self.networkKey else {
            self.provisionFail(uuid: info.uuid)
            return
        }
        MXMeshProvisionManager.shared.startUnprovisionedDeviceProvision(device: device, peripheral: peripheral, networkKey: nk, delegate: self)
    }
    
    public func meshProvisionFinish(uuid: String?, error: NSError?) {
        if let item = self.deviceList.first(where: {$0.uuid == uuid}) {
            if error == nil {
                item.refreshStep(step: (item.provisionStepList.firstIndex(where: {$0.name == MXAppConfig.mxLocalized(key:"mx_provisioning_step_config")}) ?? 1))
                self.getQuintupleData(info: item)
            } else {
                item.provisionError = error?.domain
                self.provisionFail(uuid:uuid)
            }
        }
    }
    
    public func inputUnicastAddress(uuid: String?, elementNum: Int, handler: @escaping ((String?, Int) -> Void)) {
        if let uuidStr = uuid, uuidStr.count > 0, let home_id = MXHomeManager.shard.currentHome?.homeId {
            MXMeshManager.shard.getMeshAddress(home_id: home_id, type: 0, uuid: uuidStr) { (meshAddress: Int) in
                handler(uuidStr,meshAddress)
            }
            return
        }
        handler(uuid,0)
    }
}


extension MXAddDeviceStepViewController: MXFogProvisionDelegate {
    
    func startWifiProvision(info: MXProvisionDeviceInfo) {
        info.refreshStep(step: 0)
        
        if info.productInfo?.link_type_id == 12, let pk = info.productInfo?.product_key, let dn = info.deviceName { //蓝牙辅助(fog）
            MXFogBleProvision.shared.provisionDevice(peripheral: info.peripheral, productKey: pk, deviceName: dn, delegate: self)
        }
    }
    
    public func mxFogProvisionFinish(productKey:String?, deviceName: String?, error: NSError?) {
        if error == nil {
            if let item = self.deviceList.first(where: {$0.productInfo?.product_key == productKey && $0.deviceName == deviceName}) {
                self.bindDevice(info: item)
            } else {
                self.provisionFail(uuid: nil)
            }
        } else {
            if let item = self.deviceList.first(where: {$0.productInfo?.product_key == productKey && $0.deviceName == deviceName}) {
                self.provisionFail(uuid: item.deviceIdentifier)
            } else {
                self.provisionFail(uuid: nil)
            }
        }
    }
    
    public func mxFogProvisionRequestRandom(productKey:String?,
                                           deviceName: String?,
                                           handler: @escaping ((String?) -> Void)) {
        var params = [String : Any]()
        params["device_name"] = deviceName
        params["product_key"] = productKey
        MXDeviceManager.requestFogRandom(params: params, handler: handler)
    }
    
    public func mxFogProvisionRequestBleKey(productKey: String?, deviceName: String?, random: String?, cipher: String?, handler: @escaping (String?) -> Void) {
        var params = [String : Any]()
        params["device_name"] = deviceName
        params["product_key"] = productKey
        params["cipher"] = cipher
        params["random"] = random
        MXDeviceManager.requestFogBleKey(params: params, handler: handler)
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
    
    public func mxFogProvisionInputWifiInfo(productKey:String?,
                                            deviceName: String?,
                                            handler: @escaping (String, String?, [String : Any]?) -> Void) {
        if let item = self.deviceList.first(where: {$0.productInfo?.product_key == productKey && $0.deviceName == deviceName}) {
            item.refreshStep(step: 1)
        }
        if let ssid = self.wifiSSID {
            var customParams = [String: Any]()
            customParams["mqtturl"] = MXAppConfig.MXIotMQTTHost
            customParams["httpurl"] = MXAppConfig.MXIotHTTPHost
            handler(ssid, self.wifiPassword, customParams)
        }
    }
}

extension MXAddDeviceStepViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceStepViewController()
        controller.networkKey = params["networkKey"] as? String
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
