//
//  Untitled.swift
//  MXApp
//
//  Created by mxchip on 2025/12/15.
//

public class MXOTAInfo: NSObject, Codable {
    
    public var oss_url: String?
    public var upgrade_type: Int? //升级方式：1-提醒升级，2-强制升级
    public var version : String?
    public var current_version : String?
    public var algorithms : Int?
    public var mxHash : String?
    public var remark : String?
    public var size : Int?
    public var sign : String?
    public var sign_method: String?
    public var module: String?
    public var task_id: Int?
    public var des: String?
    public var need_app_confirm: Bool?
    public var is_app_confirmed: Bool?
    public var ota_type: Int?
    
    public var step: Int?
    
    public var has_newVersion: Bool {
        get {
            if let currentVersion = self.current_version, let newVersion = self.version {
                let status = currentVersion.compare(newVersion, options: .numeric)
                return status == .orderedAscending
            }
            return false
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case oss_url
        case upgrade_type
        case version
        case current_version
        case algorithms
        case mxHash = "hash"
        case remark
        case size
        case sign
        case sign_method
        case module
        case task_id
        case des = "description"
        case need_app_confirm
        case is_app_confirmed
        case ota_type
        case step
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.oss_url = try? container.decodeIfPresent(String.self, forKey: .oss_url)
        self.upgrade_type = try? container.decodeIfPresent(Int.self, forKey: .upgrade_type)
        self.version = try? container.decodeIfPresent(String.self, forKey: .version)
        self.current_version = try? container.decodeIfPresent(String.self, forKey: .current_version)
        self.algorithms = try? container.decodeIfPresent(Int.self, forKey: .algorithms)
        self.mxHash = try? container.decodeIfPresent(String.self, forKey: .mxHash)
        self.remark = try? container.decodeIfPresent(String.self, forKey: .remark)
        self.size = try? container.decodeIfPresent(Int.self, forKey: .size)
        self.sign = try? container.decodeIfPresent(String.self, forKey: .sign)
        self.sign_method = try? container.decodeIfPresent(String.self, forKey: .sign_method)
        self.module = try? container.decodeIfPresent(String.self, forKey: .module)
        self.task_id = try? container.decodeIfPresent(Int.self, forKey: .task_id)
        self.des = try? container.decodeIfPresent(String.self, forKey: .des)
        self.need_app_confirm = try? container.decodeIfPresent(Bool.self, forKey: .need_app_confirm)
        self.is_app_confirmed = try? container.decodeIfPresent(Bool.self, forKey: .is_app_confirmed)
        self.ota_type = try? container.decodeIfPresent(Int.self, forKey: .ota_type)
        self.step = try? container.decodeIfPresent(Int.self, forKey: .step)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(oss_url, forKey: .oss_url)
        try? container.encodeIfPresent(upgrade_type, forKey: .upgrade_type)
        try? container.encodeIfPresent(version, forKey: .version)
        try? container.encodeIfPresent(current_version, forKey: .current_version)
        try? container.encodeIfPresent(algorithms, forKey: .algorithms)
        try? container.encodeIfPresent(mxHash, forKey: .mxHash)
        try? container.encodeIfPresent(remark, forKey: .remark)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(sign, forKey: .sign)
        try? container.encodeIfPresent(sign_method, forKey: .sign_method)
        try? container.encodeIfPresent(module, forKey: .module)
        try? container.encodeIfPresent(task_id, forKey: .task_id)
        try? container.encodeIfPresent(des, forKey: .des)
        try? container.encodeIfPresent(need_app_confirm, forKey: .need_app_confirm)
        try? container.encodeIfPresent(is_app_confirmed, forKey: .is_app_confirmed)
        try? container.encodeIfPresent(ota_type, forKey: .ota_type)
        try? container.encodeIfPresent(step, forKey: .step)
    }
}
