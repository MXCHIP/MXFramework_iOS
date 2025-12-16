//
//  MXRoomInfoModel.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/3.
//

import Foundation

public class MXRoomInfo: NSObject, Codable {
    
    public var roomId: Int = 0
    public var name: String?
    
    public var icon: String?
    
    public var device_count: Int = 0
    public var scene_count: Int = 0
    public var group_count: Int = 0
    public var auto_count: Int = 0
    
    public var bg_color: String?
    
    public var is_default: Bool = false
    
    public var room_address: Int = 0
    
    public var devices = [MXDeviceInfo]()
    
    public var isSelected: Bool = false  //是否选择
    public var isOpen: Bool = true //是否展开
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case name
        case icon
        case device_count
        case scene_count
        case group_count
        case auto_count
        case bg_color
        case is_default
        case room_address
        case devices
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXRoomInfo else {
            return false
        }
        return (self.roomId == obj.roomId &&
                self.name == obj.name &&
                self.bg_color == obj.bg_color &&
                self.is_default == obj.is_default &&
                self.room_address == obj.room_address)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = (try? container.decode(Int.self, forKey: .roomId)) ?? 0
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.icon = try? container.decodeIfPresent(String.self, forKey: .icon)
        self.device_count = (try? container.decode(Int.self, forKey: .device_count)) ?? 0
        self.scene_count = (try? container.decode(Int.self, forKey: .scene_count)) ?? 0
        self.group_count = (try? container.decode(Int.self, forKey: .group_count)) ?? 0
        self.auto_count = (try? container.decode(Int.self, forKey: .auto_count)) ?? 0
        self.bg_color = try? container.decodeIfPresent(String.self, forKey: .bg_color)
        self.is_default = (try? container.decode(Bool.self, forKey: .is_default)) ?? false
        self.room_address = (try? container.decode(Int.self, forKey: .room_address)) ?? 0
        self.devices = (try? container.decode([MXDeviceInfo].self, forKey: .devices)) ?? [MXDeviceInfo]()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(roomId, forKey: .roomId)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(icon, forKey: .icon)
        try? container.encode(device_count, forKey: .device_count)
        try? container.encode(scene_count, forKey: .scene_count)
        try? container.encode(group_count, forKey: .group_count)
        try? container.encode(auto_count, forKey: .auto_count)
        try? container.encodeIfPresent(bg_color, forKey: .bg_color)
        try? container.encode(is_default, forKey: .is_default)
        try? container.encode(room_address, forKey: .room_address)
        try? container.encode(devices, forKey: .devices)
    }
}

public class MXDevicesSelectRoomInfo: NSObject {
    
    public var roomId: Int = 0
    public var name: String?
    public var devices = [MXObjectInfo]()
    
    public var isSelected: Bool = false  //是否选择
    public var isOpen: Bool = true //是否展开
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXRoomInfo else {
            return false
        }
        return (self.roomId == obj.roomId &&
                self.name == obj.name)
    }
    
    public override init() {
        super.init()
    }
    
}
