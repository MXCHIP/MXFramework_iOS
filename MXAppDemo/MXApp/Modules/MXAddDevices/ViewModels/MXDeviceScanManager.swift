//
//  MXDeviceScanManager.swift
//  MXApp
//
//  Created by mxchip on 2023/10/26.
//

import Foundation
import CoreBluetooth

@_exported import MeshSDK

public class MXDeviceScanManager: NSObject {
    public static let shared = MXDeviceScanManager()
    
    //发现设备的回调
    public typealias MXScanResultCallback = (_ devices:[[String: Any]], _ isStop: Bool, _ newItem: [String: Any]? ) -> ()
    var scanResultCallback: MXScanResultCallback!
    
    var centralManager: CBCentralManager!
    
    public var scanDevices = [[String: Any]]()
    var scanTimer : Timer!
    var scanTimerNum : Int = 0
    var scanTimeout : Int = 0
    
    var isStart: Bool = false
    
    public override init() {
        super.init()
        
        // 初始化 CentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /*
     搜索设备
     @param timeout 超时时间
     @callback  [MXProvisionDeviceInfo] 未配网设备列表
     */
    public func startScan(timeout:Int = 0, callback: @escaping MXScanResultCallback) {
        self.isStart = true
        scanResultCallback = callback
        self.scanTimeout = timeout
        self.setupScanTimer()
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    //停止扫描
    public func stopScan() {
        self.isStart = false
        self.scanTimerNum = 0
        self.scanTimeout = 0
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        centralManager.stopScan()
        self.scanDevices.removeAll()
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
            if self.scanTimeout > 0, self.scanTimerNum >= self.scanTimeout {
                self.scanResultCallback?(self.scanDevices, true, nil)
                self.stopScan()
                self.scanResultCallback = nil
            }
        })
    }
}

extension MXDeviceScanManager: CBCentralManagerDelegate {

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let unprovisionedDevice = UnprovisionedDevice(advertisementData: advertisementData) {  //Mesh设备
            
            let uuidString = unprovisionedDevice.uuid.uuidString
            let macStr = MXMeshTool.getDeviceMacAddress(uuid: uuidString).lowercased()
            let productId = MXMeshTool.getDeviceProductId(uuid: uuidString)
            
            if var item = self.scanDevices.first(where: { $0["uuid"] as? String == uuidString } ) {
                item["timeStamp"] = Date().timeIntervalSince1970
                item["rssi"] = RSSI.intValue
                item["peripheral"] = peripheral
            } else {
                let newItem  = ["device":unprovisionedDevice, "uuid": uuidString, "rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"mac":macStr,"productId":productId.lowercased(), "timeStamp": Date().timeIntervalSince1970] as [String : Any]
                self.scanDevices.append(newItem)
                self.scanResultCallback?(self.scanDevices, false, newItem)
            }

        } else { //蓝牙设备
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                let bytesArray = [UInt8](manufacturerData)
                guard bytesArray.count > 3 else {
                    return
                }
                let cidStr = String(format: "%02X%02X", bytesArray[1],bytesArray[0])
                if cidStr.uppercased() == "0922" {  //mxchip自己的fog设备
                   mxAppLog("[MXBleScan]: 扫描出来的data:\(manufacturerData.toHexString()) name:\(String(describing: peripheral.name)) localName: \(String(describing: advertisementData[CBAdvertisementDataLocalNameKey]))")
                    guard bytesArray[3] != 1 else { //这个字段为1表示已经配网了
                        return
                    }
                    var pkStr: String?
                    var dnStr: String?
                    if bytesArray[2] == 1 {  ////dn自定义，从localName里面取
                        guard bytesArray.count > 9 else {
                            return
                        }
                        pkStr = String(format: "%02x%02x%02x%02x", bytesArray[6],bytesArray[7],bytesArray[8],bytesArray[9])
                        dnStr = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                    } else if bytesArray[2] == 2 {  //pk自定义,dn从localName取
                        guard bytesArray.count > 6 else {
                            return
                        }
                        let pkData = Data(bytesArray.suffix(from: 6))
                        pkStr = String(data: pkData, encoding: .ascii)
                        dnStr = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                    } else if bytesArray[2] == 3 {  //dn是6个字节的mac地址
                        guard bytesArray.count > 6 else {
                            return
                        }
                        let pkData = Data(bytesArray.suffix(from: 6))
                        pkStr = String(format: "%02x%02x%02x%02x", bytesArray[6],bytesArray[7],bytesArray[8],bytesArray[9])
                        dnStr = String(format: "%02x%02x%02x%02x%02x%02x", bytesArray[15],bytesArray[14],bytesArray[13],bytesArray[12],bytesArray[11],bytesArray[10])
                    } else {
                        guard bytesArray.count > 13 else {
                            return
                        }
                        pkStr = String(format: "%02x%02x%02x%02x", bytesArray[6],bytesArray[7],bytesArray[8],bytesArray[9])
                        dnStr = String(format: "%02x%02x%02x%02x", bytesArray[10],bytesArray[11],bytesArray[12],bytesArray[13])
                    }
                    if let product_key = pkStr, let device_name = dnStr {
                        if var item = self.scanDevices.first(where: { $0["productKey"] as? String == product_key && $0["deviceName"] as? String == device_name}) {
                            item["timeStamp"] = Date().timeIntervalSince1970
                            item["rssi"] = RSSI.intValue
                            item["peripheral"] = peripheral
                        } else {
                            let newItem  = ["rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"deviceName":device_name,"productKey":product_key, "timeStamp": Date().timeIntervalSince1970] as [String : Any]
                            self.scanDevices.append(newItem)
                            self.scanResultCallback?(self.scanDevices, false, newItem)
                        }
                    }
                }
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if self.isStart {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        } else {
            
        }
    }
}
