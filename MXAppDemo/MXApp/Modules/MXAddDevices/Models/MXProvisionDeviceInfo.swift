//
//  MXPairDeviceInfo.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/25.
//

import Foundation
import CoreBluetooth

public class MXProvisionDeviceInfo: NSObject, Codable {
    
    public var name: String?
    public var mac: String?
    public var deviceName: String?
    public var uuid: String?
    public var firmware_version: String?
    
    public var ip: String?
    public var wifi_mac: String?  //wifi mac
    public var eth_mac: String? //以太网mac
    
    //Fog 需要进行签名相关的校验
    public var signType: Int?  //签名类型
    public var sign: String?  //签名
    
    public var productInfo : MXProductInfo?
    public var composite_product_key: String? // 复合产品 product_key
    
    public var device: UnprovisionedDevice?
    public var peripheral: CBPeripheral?
    
    public var provisionStatus : Int = 0 //0未开始，1进行中， 2成功  3失败
    public var provisionStepList = Array<MXProvisionStepInfo>()
    public var isOpen: Bool = false //是否展开
    
    public var isSelected : Bool = false
    
    public var iotId : String?
    
    public var timeStamp : TimeInterval = Date().timeIntervalSince1970
    public var provisionError: String?
    
    public var roomId : Int?
    
    public var deviceIdentifier: String? {
        get {
            if let uuidStr = self.uuid, uuidStr.count > 0 {
                return uuidStr
            } else if let pk = self.productInfo?.product_key, let dn = self.deviceName {
                return pk + dn
            }
            return nil
        }
    }
    
    public func refreshStep(step: Int) {
        for i in 0..<self.provisionStepList.count {
            let info = self.provisionStepList[i]
            if i < step {
                info.status = 2
            } else if i == step {
                info.status = 1
            } else {
                info.status = 0
            }
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case mac
        case deviceName
        case uuid
        case firmware_version
        case productInfo
        case signType
        case sign
        case ip
        case wifi_mac
        case eth_mac
    }
    
    public override init() {
        super.init()
    }
    
    public convenience init(params:[String: Any]) {
        self.init()
        self.name = params["name"] as? String
        self.device = params["device"] as? UnprovisionedDevice
        self.uuid = params["uuid"] as? String
        self.peripheral = params["peripheral"] as? CBPeripheral
        self.mac = params["mac"] as? String
        self.deviceName = params["deviceName"] as? String
        self.firmware_version = params["firmware_version"] as? String
        if let pId = params["productId"] as? String, let pInfo = MXProductManager.shard.getProductInfo(pid: pId) {
            self.productInfo = pInfo
        } else if let pk = params["productKey"] as? String, let pInfo = MXProductManager.shard.getProductInfo(pk: pk) {
            self.productInfo = pInfo
        }
       mxAppLog("发现设备的pk:\(String(describing: self.productInfo?.product_key)) uuid = \(String(describing: self.uuid))")
        if self.productInfo?.is_composite == 1 {
            self.composite_product_key = self.productInfo?.product_key
            self.productInfo = MXProductManager.getProductInfo(uuid: self.uuid)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.mac = try? container.decodeIfPresent(String.self, forKey: .mac)
        self.deviceName = try? container.decodeIfPresent(String.self, forKey: .deviceName)
        self.uuid = try? container.decodeIfPresent(String.self, forKey: .uuid)
        self.firmware_version = try? container.decodeIfPresent(String.self, forKey: .firmware_version)
        self.productInfo = try? container.decodeIfPresent(MXProductInfo.self, forKey: .productInfo)
        
        self.signType = try container.decodeIfPresent(Int.self, forKey: .signType)
        self.sign = try container.decodeIfPresent(String.self, forKey: .sign)
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.wifi_mac = try container.decodeIfPresent(String.self, forKey: .wifi_mac)
        self.eth_mac = try container.decodeIfPresent(String.self, forKey: .eth_mac)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(mac, forKey: .mac)
        try? container.encodeIfPresent(deviceName, forKey: .deviceName)
        try? container.encodeIfPresent(uuid, forKey: .uuid)
        try? container.encodeIfPresent(firmware_version, forKey: .firmware_version)
        try? container.encodeIfPresent(productInfo, forKey: .productInfo)
        try? container.encodeIfPresent(sign, forKey: .sign)
        try? container.encodeIfPresent(signType, forKey: .signType)
        try? container.encodeIfPresent(ip, forKey: .ip)
        try? container.encodeIfPresent(wifi_mac, forKey: .wifi_mac)
        try? container.encodeIfPresent(eth_mac, forKey: .eth_mac)
    }
}

public class MXProvisionStepInfo: NSObject, Codable {
    
    public var name: String?
    public var status: Int = 0  //0未开始 1进行中  2成功   3失败
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case status
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.status = (try? container.decode(Int.self, forKey: .status)) ?? 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encode(status, forKey: .status)
    }
}
