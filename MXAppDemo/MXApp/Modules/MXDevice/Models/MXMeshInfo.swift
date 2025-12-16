//
//  MXDeviceMeshInfo.swift
//  MXApp
//
//  Created by huafeng on 2025/4/10.
//


public class MXMeshInfo: NSObject, Codable {
    
    public var unicastAddress: String?
    public var deviceKey: String?
    public var deviceUUID: String?
    public var UUID: String?
    public var cid: String?
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXMeshInfo else {
            return false
        }
        
        return (self.unicastAddress == obj.unicastAddress &&
                self.deviceKey == obj.deviceKey &&
                self.deviceUUID == obj.deviceUUID &&
                self.UUID == obj.UUID &&
                self.cid == obj.cid)
    }
    
    init (with data: [String: Any]) {
        if let unicastAddress = data["unicastAddress"] as? String,
           let address = UInt16(unicastAddress, radix:16) {
            self.unicastAddress = String(format: "%04x", address)
        }
        if let deviceKey = data["deviceKey"] as? String {
            self.deviceKey = deviceKey
        }
        if let deviceUUID = data["deviceUUID"] as? String,
           deviceUUID.count > 0 {
            self.deviceUUID = deviceUUID
        }
        if let UUID = data["UUID"] as? String {
            self.UUID = UUID
        }
        if let cid = data["cid"] as? String {
            self.cid = cid
        }
    }
    
    func toDictory() -> [String: Any] {
        var dic = [String: Any]()
        
        if let unicastAddress = unicastAddress {
            dic["unicastAddress"] = unicastAddress
        }
        if let deviceKey = deviceKey {
            dic["deviceKey"] = deviceKey
        }
        if let deviceUUID = deviceUUID {
            dic["deviceUUID"] = deviceUUID
        }
        if let UUID = UUID {
            dic["UUID"] = UUID
        }
        if let cid = cid {
            dic["cid"] = cid
        }
        
        return dic
    }
    
    // XXXXXXXX7XXXXXXXX
    // XXXXXXXX31XXXXXXXX

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case unicastAddress
        case deviceKey
        case deviceUUID
        case UUID
        case cid
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let unicastAddress = try container.decodeIfPresent(String.self, forKey: .unicastAddress),
           let address = UInt16(unicastAddress, radix:16) {
            self.unicastAddress = String(format: "%04x", address)
        }
        self.deviceKey = try container.decodeIfPresent(String.self, forKey: .deviceKey)
        self.deviceUUID = try container.decodeIfPresent(String.self, forKey: .deviceUUID)
        if let uuidStr = self.deviceUUID, uuidStr.count <= 0 {
            self.deviceUUID = nil
        }
        self.UUID = try container.decodeIfPresent(String.self, forKey: .UUID)
        self.cid = try container.decodeIfPresent(String.self, forKey: .cid)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(unicastAddress, forKey: .unicastAddress)
        try container.encodeIfPresent(deviceKey, forKey: .deviceKey)
        try container.encodeIfPresent(deviceUUID, forKey: .deviceUUID)
        try container.encodeIfPresent(UUID, forKey: .UUID)
        try container.encodeIfPresent(cid, forKey: .cid)
    }
}
