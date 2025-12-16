//
//  MXHomeInfoModel.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/3.
//

import Foundation

public class MXHomeInfo: NSObject, Codable {
    
    public var homeId: Int = 0
    public var name: String?
    public var isCurrentHome : Bool = false
    public var networkKey: String?
    public var appKey: String?
    public var location_key: String?
    public var country_name : String?
    public var province_name : String?
    public var city_name : String?
    public var address : String = MXAppConfig.mxLocalized(key: "mx_no_set")
    public var roomCount : Int = 0
    public var deviceCount : Int = 0
    public var userCount : Int = 1
    public var role : Int = 0  //0是家庭拥有者， 1为管理员，  2普通用户
    
    //以下信息用于缓存
    public var meshInfoString: String? //json字符串
    public var meshAddress: Int?
    public var seq: Int?
    public var rooms: [MXRoomInfo]?
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case homeId  = "home_id"
        case name
        case isCurrentHome = "current_home"
        case networkKey = "network_key"
        case appKey = "app_key"
        case roomCount = "room_count"
        case deviceCount = "device_count"
        case userCount = "member_count"
        case address
        case role
        case location_key = "location_key"
        case country_name = "country_name"
        case province_name = "province_name"
        case city_name = "city_name"
        case meshInfoString
        case meshAddress
        case seq
        case rooms
        case scenes
        case autos
        case show_whole_home
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.homeId = (try? container.decode(Int.self, forKey: .homeId)) ?? 0
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.isCurrentHome = (try? container.decode(Bool.self, forKey: .isCurrentHome)) ?? false
        self.networkKey = try? container.decodeIfPresent(String.self, forKey: .networkKey)
        self.appKey = try? container.decodeIfPresent(String.self, forKey: .appKey)
        self.roomCount = (try? container.decode(Int.self, forKey: .roomCount)) ?? 0
        self.deviceCount = (try? container.decode(Int.self, forKey: .deviceCount)) ?? 0
        self.userCount = (try? container.decode(Int.self, forKey: .userCount)) ?? 0
        self.address = (try? container.decode(String.self, forKey: .address)) ?? MXAppConfig.mxLocalized(key: "mx_no_set")
        self.location_key = try? container.decodeIfPresent(String.self, forKey: .location_key)
        self.country_name = try? container.decodeIfPresent(String.self, forKey: .country_name)
        self.province_name = try? container.decodeIfPresent(String.self, forKey: .province_name)
        self.city_name = try? container.decodeIfPresent(String.self, forKey: .city_name)
        self.role = (try? container.decode(Int.self, forKey: .role)) ?? 0
        
        self.meshInfoString = try? container.decodeIfPresent(String.self, forKey: .meshInfoString)
        self.meshAddress = try? container.decodeIfPresent(Int.self, forKey: .meshAddress)
        self.seq = try? container.decodeIfPresent(Int.self, forKey: .seq)
        self.rooms = try? container.decodeIfPresent([MXRoomInfo].self, forKey: .rooms)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(homeId, forKey: .homeId)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(networkKey, forKey: .networkKey)
        try? container.encodeIfPresent(appKey, forKey: .appKey)
        try? container.encodeIfPresent(roomCount, forKey: .roomCount)
        try? container.encodeIfPresent(deviceCount, forKey: .deviceCount)
        try? container.encodeIfPresent(userCount, forKey: .userCount)
        try? container.encodeIfPresent(address, forKey: .address)
        try? container.encodeIfPresent(location_key, forKey: .location_key)
        try? container.encodeIfPresent(country_name, forKey: .country_name)
        try? container.encodeIfPresent(province_name, forKey: .province_name)
        try? container.encodeIfPresent(city_name, forKey: .city_name)
        try? container.encode(isCurrentHome, forKey: .isCurrentHome)
        try? container.encodeIfPresent(role, forKey: .role)
        
        try? container.encodeIfPresent(meshInfoString, forKey: .meshInfoString)
        try? container.encodeIfPresent(meshAddress, forKey: .meshAddress)
        try? container.encodeIfPresent(seq, forKey: .seq)
        try? container.encodeIfPresent(rooms, forKey: .rooms)
    }
}
