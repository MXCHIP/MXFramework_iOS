//
//  MXCountryInfo.swift
//  Antadi
//
//  Created by huafeng on 2024/11/26.
//


public class MXCountryInfo: NSObject, Codable {
    
    public var ISO2: String?
    public var ISO3: String?
    public var code: Int?
    public var ServerStation: String?
    public var area_name: String?
    public var area_english_name: String?
    public var pinyin: String?
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXCountryInfo else {
            return false
        }
        return (self.ISO3 == obj.ISO3)
    }
    
    public var showName: String? {
        get {
            if MXAccountModel.shared.language.hasPrefix("zh-Hans") {
                return self.area_name
            }
            return self.area_english_name
        }
    }
    
    public var indexStr: String {
        get {
            if MXAccountModel.shared.language.hasPrefix("zh-Hans") {
                if let index = self.pinyin?.first {
                    return String(index).uppercased()
                }
                return "#"
            }
            if let index = self.area_english_name?.first {
                return String(index).uppercased()
            }
            return "#"
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case ISO2
        case ISO3
        case code
        case ServerStation
        case area_name
        case area_english_name
        case pinyin
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ISO2 = try? container.decodeIfPresent(String.self, forKey: .ISO2)
        self.ISO3 = try? container.decodeIfPresent(String.self, forKey: .ISO3)
        self.code = try? container.decodeIfPresent(Int.self, forKey: .code)
        self.ServerStation = try? container.decodeIfPresent(String.self, forKey: .ServerStation)
        self.area_name = try? container.decodeIfPresent(String.self, forKey: .area_name)
        self.area_english_name = try? container.decodeIfPresent(String.self, forKey: .area_english_name)
        self.pinyin = try? container.decodeIfPresent(String.self, forKey: .pinyin)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(ISO2, forKey: .ISO2)
        try? container.encodeIfPresent(ISO3, forKey: .ISO3)
        try? container.encodeIfPresent(code, forKey: .code)
        try? container.encodeIfPresent(ServerStation, forKey: .ServerStation)
        try? container.encodeIfPresent(area_name, forKey: .area_name)
        try? container.encodeIfPresent(area_english_name, forKey: .area_english_name)
        try? container.encodeIfPresent(pinyin, forKey: .pinyin)
    }
}
