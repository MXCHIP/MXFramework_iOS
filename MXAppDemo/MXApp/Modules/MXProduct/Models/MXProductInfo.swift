//
//  MXProductInfo.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/3.
//

import Foundation

public class MXProductInfo: NSObject, Codable {
    
    public var product_id: String?
    public var name: String?
    public var product_key : String?   //
    public var product_type : Int = 0
    public var image: String?   //产品图片
    public var cloud_platform: Int = 0  //1飞燕，2fog
    
    public var category_id: Int = 0
    public var panel_type_id: Int = 0 //面板类型
    public var link_type_id: Int = 0  //配网类型
    public var share_type: Int = 0  //是否可以分享
    public var sharing_mode: Int = 0  //是否是抢占式
    
    public var attr_map: String?
    
    public var heartbeat_interval: Int = 120 //心跳
    
    public var node_type_v2: String?  //节点类型  网关设备：gateway 网关子设备：gateway-sub 直连设备：direct
    public var protocol_type_v2: String? //通讯方式 "BLE Mesh","WiFi",""WiFi+BLE","WiFi+BLE Mesh"
    public var not_receive_message: Bool = false  //是否是仅发不收设备： true-是（不能写规则）；false-不是（能写规则）
    public var matter: Int = 0  //是否支持matter 0 不支持  1支持
    public var support_subscribe_group: Bool = false  //是否支持预置场景
    public var hide: Bool = false //是否隐藏
    
    public var color_temperature_range: String?
    
    public var properties : [MXDevicePropertyItem]?
    
    public var product_model: String? // 产品型号
    public var is_composite: Int? // 是否是复合产品：0-不是，1-是
    public var composite_products: [MXCompositeProduct]? //复合产品关联产品列表
    
    public var attrMap: [String: Any]? {
        get {
            if let attr_data = self.attr_map?.data(using: .utf8),
               let map = try? JSONSerialization.jsonObject(with: attr_data, options: .allowFragments) as? [String: Any], map.count > 0 {
                return map;
            }
            return nil
        }
    }
    
    public var needConnectWifi: Bool {
        get {
            if self.link_type_id == 7 || self.link_type_id == 8 || self.link_type_id == 13 {
                return false
            }
            return true
        }
    }
    
    public var isLight: Bool {
        get {
            return (self.category_id == 100102 ||
                    self.category_id == 100103 ||
                    self.category_id == 100104 ||
                    self.category_id == 100105 ||
                    self.category_id == 100106)
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case product_id = "feiyan_product_id"
        case name
        case product_key
        case product_type
        case image
        case cloud_platform
        case category_id
        case panel_type_id
        case link_type_id
        case share_type
        case sharing_mode
        case attr_map
        case heartbeat_interval
        case node_type_v2
        case protocol_type_v2
        case not_receive_message
        case matter
        case support_subscribe_group = "is_scene_preset"
        case hide
        case color_temperature_range
        case properties
        case product_model
        case is_composite
        case composite_products
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.product_id = try? container.decodeIfPresent(String.self, forKey: .product_id)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.product_key = try? container.decodeIfPresent(String.self, forKey: .product_key)
        self.product_type = (try? container.decode(Int.self, forKey: .product_type)) ?? 0
        self.image = try? container.decodeIfPresent(String.self, forKey: .image)
        self.cloud_platform = (try? container.decode(Int.self, forKey: .cloud_platform)) ?? 0
        self.category_id = (try? container.decode(Int.self, forKey: .category_id)) ?? 0
        self.panel_type_id = (try? container.decode(Int.self, forKey: .panel_type_id)) ?? 0
        self.link_type_id = (try? container.decode(Int.self, forKey: .link_type_id)) ?? 0
        self.share_type = (try? container.decode(Int.self, forKey: .share_type)) ?? 0
        self.sharing_mode = (try? container.decode(Int.self, forKey: .sharing_mode)) ?? 0
        
        self.attr_map  = try? container.decodeIfPresent(String.self, forKey: .attr_map)
        self.heartbeat_interval = (try? container.decode(Int.self, forKey: .heartbeat_interval)) ?? 120
        self.node_type_v2 = try? container.decodeIfPresent(String.self, forKey: .node_type_v2)
        self.protocol_type_v2 = try? container.decodeIfPresent(String.self, forKey: .protocol_type_v2)
        self.not_receive_message = (try? container.decode(Bool.self, forKey: .not_receive_message)) ?? false
        self.matter = (try? container.decode(Int.self, forKey: .matter)) ?? 0
        self.support_subscribe_group = (try? container.decode(Bool.self, forKey: .support_subscribe_group)) ?? false
        self.hide = (try? container.decode(Bool.self, forKey: .hide)) ?? false
        
        self.color_temperature_range = try? container.decodeIfPresent(String.self, forKey: .color_temperature_range)
        
        self.properties = try container.decodeIfPresent([MXDevicePropertyItem].self, forKey: .properties)
        
        self.product_model = try? container.decodeIfPresent(String.self, forKey: .product_model)
        self.is_composite = try? container.decodeIfPresent(Int.self, forKey: .is_composite)
        self.composite_products = try? container.decodeIfPresent([MXCompositeProduct].self, forKey: .composite_products)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(product_id, forKey: .product_id)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(product_key, forKey: .product_key)
        try? container.encode(product_type, forKey: .product_type)
        try? container.encodeIfPresent(image, forKey: .image)
        try? container.encode(cloud_platform, forKey: .cloud_platform)
        try? container.encode(category_id, forKey: .category_id)
        try? container.encode(panel_type_id, forKey: .panel_type_id)
        try? container.encode(link_type_id, forKey: .link_type_id)
        try? container.encode(share_type, forKey: .share_type)
        try? container.encode(sharing_mode, forKey: .sharing_mode)
        try? container.encodeIfPresent(attr_map, forKey: .attr_map)
        try? container.encode(heartbeat_interval, forKey: .heartbeat_interval)
        try? container.encodeIfPresent(node_type_v2, forKey: .node_type_v2)
        try? container.encodeIfPresent(protocol_type_v2, forKey: .protocol_type_v2)
        try? container.encode(not_receive_message, forKey: .not_receive_message)
        try? container.encode(matter, forKey: .matter)
        try? container.encode(support_subscribe_group, forKey: .support_subscribe_group)
        try? container.encode(hide, forKey: .hide)
        try? container.encode(color_temperature_range, forKey: .color_temperature_range)
        
        try container.encodeIfPresent(properties, forKey: .properties)
        
        try? container.encode(product_model, forKey: .product_model)
        try? container.encode(is_composite, forKey: .is_composite)
        try? container.encode(composite_products, forKey: .composite_products)
    }
}


public class MXCategoryInfo: NSObject, Codable {
    
    public var name: String?
    public var category_id: Int = 0
    public var categorys : Array<MXCategoryInfo>?
    public var products : Array<MXProductInfo>?
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case category_id
        case categorys
        case products
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.category_id = (try? container.decode(Int.self, forKey: .category_id)) ?? 0
        self.categorys = try? container.decodeIfPresent([MXCategoryInfo].self, forKey: .categorys)
        self.products = try? container.decodeIfPresent([MXProductInfo].self, forKey: .products)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encode(category_id, forKey: .category_id)
        try? container.encodeIfPresent(categorys, forKey: .categorys)
        try? container.encodeIfPresent(products, forKey: .products)
    }
}

public class MXCompositeProduct: NSObject, Codable {

    public var index: Int?
    public var product_key : String?
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case index
        case product_key
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.index = try? container.decodeIfPresent(Int.self, forKey: .index)
        self.product_key = try? container.decodeIfPresent(String.self, forKey: .product_key)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(index, forKey: .index)
        try? container.encodeIfPresent(product_key, forKey: .product_key)
    }
}
