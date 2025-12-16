//
//  MXDeviceInfo.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/3.
//

import Foundation

open class MXObjectInfo: NSObject, Codable {
    public var device_type: Int = 0 //0 是设备  1 群组
    public var name: String?  //
    public var image: String?  //
    public var isFavorite: Bool = true
    
    public var propertys : [MXDevicePropertyItem]?
    
    public var isSelected: Bool = false
    
    //房间信息
    public var roomId : Int = 0
    public var roomName : String?
    
    //产品相关信息
    public var category_pid: Int?
    public var category_id: Int?
    public var productKey : String?  //pk
    public var productName: String?  //产品名称
    public var productImage: String?  //产品图片
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case device_type
        case roomId = "room_id"
        case roomName = "room_name"
        case isFavorite = "show"
        case propertys
        case name
        case image
        case category_pid
        case category_id
        case productKey = "product_key"
        case productName = "product_name"
        case productImage = "product_image"
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXDeviceInfo else {
            return false
        }
        return (self.roomId == obj.roomId &&
                self.roomName == obj.roomName &&
                self.isFavorite == obj.isFavorite &&
                self.device_type == obj.device_type &&
                self.propertys == obj.propertys &&
                self.name == obj.name &&
                self.image == obj.image  &&
                self.productKey == obj.productKey &&
                self.propertys == obj.propertys)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = (try? container.decode(Int.self, forKey: .roomId)) ?? 0
        self.roomName = try? container.decodeIfPresent(String.self, forKey: .roomName)
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
        self.propertys = try? container.decodeIfPresent([MXDevicePropertyItem].self, forKey: .propertys)
        self.device_type = (try? container.decodeIfPresent(Int.self, forKey: .device_type)) ?? 0
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.image = try? container.decodeIfPresent(String.self, forKey: .image)
        
        self.category_pid = try? container.decodeIfPresent(Int.self, forKey: .category_pid)
        self.category_id = try? container.decodeIfPresent(Int.self, forKey: .category_id)
        self.productKey = try? container.decodeIfPresent(String.self, forKey: .productKey)
        self.productName = try? container.decodeIfPresent(String.self, forKey: .productName)
        self.productImage = try? container.decodeIfPresent(String.self, forKey: .productImage)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(roomId, forKey: .roomId)
        try? container.encodeIfPresent(roomName, forKey: .roomName)
        try? container.encode(isFavorite, forKey: .isFavorite)
        try? container.encodeIfPresent(propertys, forKey: .propertys)
        try? container.encodeIfPresent(device_type, forKey: .device_type)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(image, forKey: .image)
        
        try? container.encodeIfPresent(productKey, forKey: .productKey)
        try? container.encodeIfPresent(productName, forKey: .productName)
        try? container.encodeIfPresent(productImage, forKey: .productImage)
        
        try? container.encodeIfPresent(category_pid, forKey: .category_pid)
        try? container.encodeIfPresent(category_id, forKey: .category_id)
        
    }
}

open class MXDeviceInfo: MXObjectInfo {
    public var device_id: Int = 0
    
    public var iotId: String?  //设备iotId
    
    //设备信息
    public var nickName: String? //设备昵称
    
    public var uuid: String?  //mesh设备的uuid
    public var deviceName: String?  //dn
    public var firmware_version : String?  //固件版本号
    public var mcu_version: String?
    public var mac: String?
    public var wifi_mac: String?  //wifi mac
    public var eth_mac: String?  //以太网mac
    
    public var share_type: Int = 0  //是否可以分享
    public var isOnline: Bool = false //云端是否在线
    public var isShare : Bool = false //是否是分享设备
    
    public var createTime: Int = 0 //创建时间
    public var buildTime: Int = 0 //绑定时间
    
    public var is_master: Int = 0  //组控设备列表数据
    public var service: Int = 0 //组控设备列表数据
    
    public var isSubDevice: Bool = false  //是否是拆分的子设备（多建开关拆分）
    
    public var isValid: Bool = true //是否是有效节点
    public var writtenStatus: Int = 0  //0未开始 1正在写入 2写入成功 3写入失败
    public var isIntoGroup: Bool = true  //true 添加入组， false 移除出组
    public var group_written: Bool = true  //群组是否同步成功
    public var recovery_status: Int = 0  //0 未写入  1已写入
    public var status: Int = 0  //0新增待写入 1写入成功  2更新待写入  3删除待写入
    
    //产品相关信息
    open var productInfo: MXProductInfo? {
        get {
            return MXProductManager.shard.getProductInfo(pk: self.productKey)
        }
    }
    
    public var gateway_is_main: Int? //是否是主网关: -1 - 未配置; 0 - 从网关; 1 - 主网关
    public var gateway_network_mode: Int? //联网方式： -1 - 未配置；0- 使用以太网络；1- 使用WiFi网络
    public var wifi_group_enable: Int?
    
    public var ip: String? //网关模版施工需要获取IP上传
    public var static_ip: MXIpInfo?
    public var ip_strategy: Int? // IP分配策略 0 IP段静态IP 1 动态分配 2 mac绑定ip
    
    public var fastIndex: Int? //快捷控制的number
    
    public var showName: String? {
        get {
            if let show_name = self.nickName, show_name.count > 0 {
                return show_name
            } else if let show_name = self.name, show_name.count > 0 {
                return show_name
            } else if let show_name = self.productName, show_name.count > 0 {
                return show_name
            }
            return nil
        }
    }
    
    public var showImage: String? {
        get {
            if let img = self.image, img.count > 0 {
                return img
            } else if let img = self.productImage, img.count > 0  {
                return img
            } else {
                return self.productInfo?.image
            }
        }
    }
    
    public var isCentralControl: Bool {
        get {
            if self.category_id == 140301 || self.category_id == 140302 || self.category_id == 140303 {
                return true
            }
            return false
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case device_id
        case iotId = "iotid"
        case roomId = "room_id"
        case roomName = "room_name"
        case isFavorite = "show"
        case propertys
        case nickName = "nick_name"
        case name
        case image
        case productKey = "product_key"
        case productName = "product_name"
        case productImage = "product_image"
        case uuid
        case deviceName = "device_name"
        case share_type
        case isOnline = "online"
        case isShare = "is_share"
        case firmware_version
        case mcu_version
        case is_master
        case service
        case buildTime = "bind_time"
        case createTime = "ctime"
        case isValid = "valid"
        case group_written
        case recovery_status
        case mac
        case wifi_mac
        case eth_mac
        case status
        case gateway_is_main
        case gateway_network_mode
        case wifi_group_enable
        case ip
        case static_ip
        case ip_strategy
        case fastIndex = "number"
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXDeviceInfo else {
            return false
        }
        return (self.iotId == obj.iotId &&
                self.roomId == obj.roomId &&
                self.roomName == obj.roomName &&
                self.isFavorite == obj.isFavorite &&
                self.device_id == obj.device_id &&
                self.device_type == obj.device_type &&
                self.propertys == obj.propertys &&
                self.name == obj.name &&
                self.image == obj.image  &&
                self.uuid == obj.uuid &&
                self.nickName == obj.nickName &&
                self.deviceName == obj.deviceName &&
                self.productKey == obj.productKey &&
                self.isValid == obj.isValid &&
                self.mac == obj.mac &&
                self.fastIndex == obj.fastIndex)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.device_type = 0
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.iotId = try? container.decodeIfPresent(String.self, forKey: .iotId)
        self.device_id = (try? container.decodeIfPresent(Int.self, forKey: .device_id)) ?? 0
        self.uuid = try? container.decodeIfPresent(String.self, forKey: .uuid)
        self.nickName = try? container.decodeIfPresent(String.self, forKey: .nickName)
        self.deviceName = try? container.decodeIfPresent(String.self, forKey: .deviceName)
        
        self.productKey = try? container.decodeIfPresent(String.self, forKey: .productKey)
        self.productName = try? container.decodeIfPresent(String.self, forKey: .productName)
        self.productImage = try? container.decodeIfPresent(String.self, forKey: .productImage)
        
        if (self.image?.count ?? 0) == 0, let pkImg = self.productImage, pkImg.count > 0 {
            self.image = pkImg
        }
        
        self.share_type = (try? container.decode(Int.self, forKey: .share_type)) ?? 0
        
        self.isShare = (try? container.decode(Bool.self, forKey: .isShare)) ?? false
        self.isOnline = (try? container.decode(Bool.self, forKey: .isOnline)) ?? false
        
        self.firmware_version = try? container.decodeIfPresent(String.self, forKey: .firmware_version)
        self.mcu_version = try? container.decodeIfPresent(String.self, forKey: .mcu_version)
        
        self.is_master = (try? container.decode(Int.self, forKey: .is_master)) ?? 0
        self.service = (try? container.decode(Int.self, forKey: .service)) ?? 0
        
        self.createTime = (try? container.decode(Int.self, forKey: .createTime)) ?? 0
        self.buildTime = (try? container.decode(Int.self, forKey: .buildTime)) ?? 0
        
        self.isValid = (try? container.decode(Bool.self, forKey: .isValid)) ?? true
        self.group_written = (try? container.decode(Bool.self, forKey: .group_written)) ?? true
        self.recovery_status = (try? container.decode(Int.self, forKey: .recovery_status)) ?? 0
        self.status = (try? container.decodeIfPresent(Int.self, forKey: .status)) ?? 0
        
        self.mac = try? container.decodeIfPresent(String.self, forKey: .mac)
        self.wifi_mac = try container.decodeIfPresent(String.self, forKey: .wifi_mac)
        self.eth_mac = try container.decodeIfPresent(String.self, forKey: .eth_mac)
        
        self.gateway_is_main = try? container.decodeIfPresent(Int.self, forKey: .gateway_is_main)
        self.gateway_network_mode = try? container.decodeIfPresent(Int.self, forKey: .gateway_network_mode)
        self.wifi_group_enable = try? container.decodeIfPresent(Int.self, forKey: .wifi_group_enable)
        
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.static_ip = try container.decodeIfPresent(MXIpInfo.self, forKey: .static_ip)
        self.ip_strategy = try container.decodeIfPresent(Int.self, forKey: .ip_strategy)
        
        self.fastIndex = try container.decodeIfPresent(Int.self, forKey: .fastIndex)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(iotId, forKey: .iotId)
        try? container.encodeIfPresent(device_id, forKey: .device_id)
        try? container.encodeIfPresent(uuid, forKey: .uuid)
        try? container.encodeIfPresent(nickName, forKey: .nickName)
        try? container.encodeIfPresent(deviceName, forKey: .deviceName)
        
        try? container.encodeIfPresent(productKey, forKey: .productKey)
        try? container.encodeIfPresent(productName, forKey: .productName)
        try? container.encodeIfPresent(productImage, forKey: .productImage)
        
        try? container.encode(share_type, forKey: .share_type)
        
        try? container.encode(isShare, forKey: .isShare)
        try? container.encode(isOnline, forKey: .isOnline)
        
        try? container.encodeIfPresent(firmware_version, forKey: .firmware_version)
        try? container.encodeIfPresent(mcu_version, forKey: .mcu_version)
        
        try? container.encode(is_master, forKey: .is_master)
        try? container.encode(service, forKey: .service)
        
        try? container.encodeIfPresent(createTime, forKey: .createTime)
        try? container.encodeIfPresent(buildTime, forKey: .buildTime)
        
        try? container.encode(isValid, forKey: .isValid)
        try? container.encode(group_written, forKey: .group_written)
        try? container.encode(recovery_status, forKey: .recovery_status)
        try? container.encodeIfPresent(status, forKey: .status)
        
        try? container.encodeIfPresent(mac, forKey: .mac)
        try? container.encodeIfPresent(wifi_mac, forKey: .wifi_mac)
        try? container.encodeIfPresent(eth_mac, forKey: .eth_mac)
        
        try? container.encodeIfPresent(gateway_is_main, forKey: .gateway_is_main)
        try? container.encodeIfPresent(gateway_network_mode, forKey: .gateway_network_mode)
        try? container.encodeIfPresent(wifi_group_enable, forKey: .wifi_group_enable)
        
        try? container.encodeIfPresent(ip, forKey: .ip)
        try? container.encodeIfPresent(static_ip, forKey: .static_ip)
        try? container.encodeIfPresent(ip_strategy, forKey: .ip_strategy)
        
        try? container.encodeIfPresent(fastIndex, forKey: .fastIndex)
        
    }
}

public class MXCategoryExtend: NSObject, Codable {
    
    public var switch_number: Int = 0
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case switch_number
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.switch_number = (try? container.decode(Int.self, forKey: .switch_number)) ?? 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(switch_number, forKey: .switch_number)
    }
}
