//
//  MXMeshOTAHandle.swift
//  MXApp
//
//  Created by 华峰 on 2023/2/24.
//

import Foundation
import RTKOTASDK
import CoreBluetooth

@objcMembers
open class MXMeshOTAHandle: NSObject {
    
    public typealias MXOTAResultCallback = (_ isSuccess: Bool) -> ()
    public var resultCallback : MXOTAResultCallback?
    public typealias MXOTAStepCallback = (_ step: Int) -> ()
    public var stepCallback : MXOTAStepCallback?
    
    var device_mac : String?
    var otaFilePath : String? = nil
    
    var isStart: Bool = false
    
    var OTAProfile: RTKOTAProfile!
    var OTAPeripheral : RTKOTAPeripheral?
    var DFUPeripheral : RTKMultiDFUPeripheral?
    
    var _timeUpgradeBegin : Date?
    var _upgradeNextConnectedPeripheral: Bool = false
    var _upgradeSilently: Bool = false
    var _images : Array<RTKOTAUpgradeBin> = Array<RTKOTAUpgradeBin>()
    var _imagesForLeftBud : Array<RTKOTAUpgradeBin> = Array<RTKOTAUpgradeBin>()
    var _imagesForRightBud : Array<RTKOTAUpgradeBin> = Array<RTKOTAUpgradeBin>()
    
    lazy var imagesUserSelected : Array<RTKOTAUpgradeBin> = {
        if let ota_peripheral = self.OTAPeripheral, ota_peripheral.isRWS {
            return ota_peripheral.budType == RTKOTAEarbudLeft ? _imagesForLeftBud : _imagesForRightBud
        }
        return _images
    }()
    
    lazy var toUpgradeImages : Array<RTKOTAUpgradeBin>? = {
        guard let ota_peripheral = self.OTAPeripheral else {
            return nil
        }
        switch ota_peripheral.freeBank {
        case 0x00:
            return self.imagesUserSelected.filter {$0.bank == RTKOTABinBankInfo.unknown || $0.bank == RTKOTABinBankInfo.bank0}
        case 0x01:
            return self.imagesUserSelected.filter {$0.bank == RTKOTABinBankInfo.unknown || $0.bank == RTKOTABinBankInfo.bank1}
        default:
            return self.imagesUserSelected;
        }
    }()
    
    var centralManager: CBCentralManager!
    var scanTimer : Timer!
    var scanTimerNum : Int = 0
    var scanTimeout : Int = 15
    
    var taskWorkItem : DispatchWorkItem?
    
    public convenience init(filePath: String, deviceMAC: String) {
        self.init()
       mxAppLog("[MXOTA]: OTA设备的mac地址：\(deviceMAC)")
        self.taskWorkItem = DispatchWorkItem { [weak self] in
           mxAppLog("[MXOTA]: 超时失败")
            self?.OTAUpgradeFailer()
        }
        // 添加延时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: self.taskWorkItem!)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.OTAProfile = RTKOTAProfile()
        self.OTAProfile.delegate = self
        self.otaFilePath = filePath
        self.device_mac = deviceMAC
        self.isStart = true
        self.scanDevice()
    }
    
    deinit {
        OTAUpgradeFinish()
    }
}

extension MXMeshOTAHandle: RTKLEProfileDelegate,RTKMultiDFUPeripheralDelegate {
    
    public func profileManagerDidUpdateState(_ profile: RTKLEProfile) {
        
    }
    
    public func profile(_ profile: RTKLEProfile, didConnect peripheral: RTKLEPeripheral) {
       mxAppLog("[MXOTA]: 连接成功")
        if peripheral == self.OTAPeripheral {
            if let is_rws = self.OTAPeripheral?.isRWS, is_rws, _upgradeNextConnectedPeripheral{
                _upgradeSilently = true
                _upgradeNextConnectedPeripheral = false
                if let dfu_peripheral = self.OTAProfile.dfuPeripheral(of: self.OTAPeripheral!) as? RTKMultiDFUPeripheral {
                    dfu_peripheral.delegate = self
                    self.OTAProfile.connect(to: dfu_peripheral)
                    self.DFUPeripheral = dfu_peripheral
                }
                return
            }
            self.onFileHasSelected()
        } else if peripheral == self.DFUPeripheral {
            if let upgradeImages = self.toUpgradeImages  {
                self.DFUPeripheral?.upgradeImages(upgradeImages, inOTAMode: !_upgradeSilently)
            }
        }
    }
    
    public func profile(_ profile: RTKLEProfile, didDisconnectPeripheral peripheral: RTKLEPeripheral, error: Error?) {
       mxAppLog("[MXOTA]: 断开连接 error = \(String(describing: error))")
        self.OTAPeripheral = nil
    }
    
    public func profile(_ profile: RTKLEProfile, didFailToConnect peripheral: RTKLEPeripheral, error: Error?) {
       mxAppLog("[MXOTA]: 连接失败 error = \(String(describing: error))")
        DispatchQueue.main.async {
            self.OTAUpgradeFailer()
        }
    }
    
    public func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didFinishWithError err: Error?) {
        if err != nil {
           mxAppLog("[MXOTA]: OTA失败 error = \(String(describing: err))")
            self.OTAUpgradeFailer()
            return
        }
        self.OTAProfile.cancelConnection(with: peripheral)
        self.OTAUpgradeFinish()
        self.resultCallback?(true)
    }
    
    public func dfuPeripheral(_ peripheral: RTKMultiDFUPeripheral, didActiveImages images: [RTKOTAUpgradeBin]) {
        self.stepCallback?(4)
    }
    
    public func dfuPeripheral(_ peripheral: RTKMultiDFUPeripheral, didSendImage image: RTKOTAUpgradeBin) {
        self.stepCallback?(3)
    }
    
    public func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didSend length: UInt, totalToSend totalLength: UInt) {
        self.stepCallback?(3)
    }
    
    func onFileHasSelected() {
        self.stepCallback?(2)
        if let file_path = self.otaFilePath, let ota_peripheral = self.OTAPeripheral  {
            if ota_peripheral.isRWS {
                var primaryBins: NSArray?
                var secondaryBins: NSArray?
                let error = RTKOTAUpgradeBin.extractCombinePackFile(withFilePath: file_path, toPrimaryBins: &primaryBins, secondaryBins: &secondaryBins)
                if error == nil {
                    if let newPrimaryBins = primaryBins as? Array<RTKOTAUpgradeBin> {
                        _imagesForLeftBud = newPrimaryBins
                    }
                    if let newSecondaryBins = secondaryBins as? Array<RTKOTAUpgradeBin> {
                        _imagesForRightBud = newSecondaryBins
                    }
                    
                    if _imagesForLeftBud.count == 1, let last_leftBud = _imagesForLeftBud.last, !last_leftBud.icDetermined {
                        last_leftBud.assertAvailable(for: ota_peripheral)
                    }
                    if _imagesForRightBud.count == 1, let last_rightBud = _imagesForRightBud.last, !last_rightBud.icDetermined, let last_leftBud = _imagesForLeftBud.last  {
                        last_leftBud.assertAvailable(for: ota_peripheral)
                    }
                }
                
            } else if ota_peripheral.notEngaged {
                var primaryBins: NSArray?
                var secondaryBins: NSArray?
                let error = RTKOTAUpgradeBin.extractCombinePackFile(withFilePath: file_path, toPrimaryBins: &primaryBins, secondaryBins: &secondaryBins)
                if error == nil {
                    if let newPrimaryBins = primaryBins as? Array<RTKOTAUpgradeBin> {
                        if ota_peripheral.budType == RTKOTAEarbudLeft {
                            _images = newPrimaryBins
                        }
                    }
                    if let newSecondaryBins = secondaryBins as? Array<RTKOTAUpgradeBin> {
                        if ota_peripheral.budType == RTKOTAEarbudRight {
                            _images = newSecondaryBins
                        }
                    }
                    
                    if _images.count == 1, let last_bud = _images.last, !last_bud.icDetermined {
                        last_bud.assertAvailable(for: ota_peripheral)
                    }
                } else {
                    if let images_bud = try? RTKOTAUpgradeBin.imagesExtract(fromMPPackFilePath: file_path) {
                        _images = images_bud
                    }
                    
                    if _images.count == 1, let last_bud = _images.last, !last_bud.icDetermined {
                        last_bud.assertAvailable(for: ota_peripheral)
                    }
                }
            } else {
                if let images_bud = try? RTKOTAUpgradeBin.imagesExtract(fromMPPackFilePath: file_path) {
                    _images = images_bud
                }
                
                if _images.count == 1, let last_bud = _images.last, !last_bud.icDetermined {
                    last_bud.assertAvailable(for: ota_peripheral)
                }
            }
        } else {
            self.OTAUpgradeFailer()
        }
        
        self.startOTA()
    }
    
    func startOTA() {
        if let upgrade_images = self.toUpgradeImages, let ota_peripheral = self.OTAPeripheral, upgrade_images.count > 0 {
            if ota_peripheral.isRWS {
                _upgradeSilently = true
                _upgradeNextConnectedPeripheral = true
                
                if let dfu_peripheral = self.OTAProfile.dfuPeripheral(of: ota_peripheral) as? RTKMultiDFUPeripheral {
                    dfu_peripheral.delegate = self
                    self.OTAProfile.connect(to: dfu_peripheral, withTimeout: 10)
                    self.DFUPeripheral = dfu_peripheral
                }
                
            } else if ota_peripheral.canEnterOTAMode, ota_peripheral.canUpgradeSliently {
                _upgradeSilently = true
                if let dfu_peripheral = self.OTAProfile.dfuPeripheral(of: ota_peripheral) as? RTKMultiDFUPeripheral {
                    dfu_peripheral.delegate = self
                    self.OTAProfile.connect(to: dfu_peripheral, withTimeout: 10)
                    self.DFUPeripheral = dfu_peripheral
                }
            } else if ota_peripheral.canEnterOTAMode {
                _upgradeSilently = false
                self.OTAProfile.translate(ota_peripheral) { (success: Bool, err: Error?, peripheral: RTKDFUPeripheral? ) in
                    if success, let dfu_peripheral = peripheral as? RTKMultiDFUPeripheral {
                        dfu_peripheral.delegate = self
                        self.OTAProfile.connect(to: dfu_peripheral, withTimeout: 10)
                        self.DFUPeripheral = dfu_peripheral
                    }
                }
            } else if (ota_peripheral.canUpgradeSliently) {
                _upgradeSilently = true
                if let dfu_peripheral = self.OTAProfile.dfuPeripheral(of: ota_peripheral) as? RTKMultiDFUPeripheral {
                    dfu_peripheral.delegate = self
                    self.OTAProfile.connect(to: dfu_peripheral, withTimeout: 10)
                    self.DFUPeripheral = dfu_peripheral
                }
            }
        } else {
            self.OTAUpgradeFailer()
        }
    }
    
    func OTAUpgradeFailer() {
        self.OTAUpgradeFinish()
        self.resultCallback?(false)
    }
    
    public func OTAUpgradeFinish() {
        taskWorkItem?.cancel()
        taskWorkItem = nil
        if let ota_peripheral = OTAPeripheral {
            OTAProfile.cancelConnection(with: ota_peripheral)
        }
        
        OTAPeripheral = nil
        DFUPeripheral = nil
        isStart = false
        stopScan()
       mxAppLog("[MXOTA]: OTA结束")
    }
}

extension MXMeshOTAHandle: CBCentralManagerDelegate {
    
    func scanDevice() {
        self.setupScanTimer()
        self.centralManager.scanForPeripherals(withServices: [], options: nil)
    }
    
    //停止扫描
    public func stopScan() {
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        self.centralManager.stopScan()
    }
    
    func setupScanTimer() {
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        self.scanTimerNum = 0
        self.scanTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.scanTimerNum += 1
            if self.scanTimerNum >= self.scanTimeout {
                self.stopScan()
                self.connectFailer()
            }
        })
    }
    
    func connectFailer() {
       mxAppLog("[MXOTA]: 扫描超时，未发现设备")
        self.isStart = false
        self.resultCallback?(false)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if self.isStart {
                self.scanDevice()
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var macAddress: String? = nil
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID : Data],
           let data = serviceData[CBUUID(string: "1827")], data.count == 18 {
            let dataBytes = [UInt8](data)
            macAddress = String(format: "%02x:%02x:%02x:%02x:%02x:%02x", dataBytes[12],dataBytes[11],dataBytes[10],dataBytes[9],dataBytes[8],dataBytes[7])
           mxAppLog("发现Mesh设备:\(String(describing: macAddress))")
        } else if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
           mxAppLog("发现设备：\(manufacturerData.toHexString())")
            let bytesArray = [UInt8](manufacturerData)
            guard bytesArray.count > 2 else {
                return
            }
            let type = bytesArray[2]
            if bytesArray.count > 8, type == 0x00 {
                macAddress = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", bytesArray[8],bytesArray[7],bytesArray[6],bytesArray[5],bytesArray[4],bytesArray[3])
            }
        }
        
        if let mac_address = macAddress, mac_address.lowercased() == self.device_mac?.lowercased() {  //找到符合的设备
            self.stopScan()
            if self.OTAPeripheral != nil {
                self.OTAProfile.cancelConnection(with: self.OTAPeripheral!)
            }
            self.stepCallback?(1)
            self.OTAPeripheral = self.OTAProfile.otaPeripheral(from: peripheral)
            if let ota_peripheral = self.OTAPeripheral {
               mxAppLog("[MXOTA]: 发现设备，开始连接 mac = \(mac_address)")
                self.OTAProfile.connect(to: ota_peripheral)
            }
        }
    }
    
    
}
