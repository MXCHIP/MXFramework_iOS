//
//  MXPropertyInfo.swift
//  MXApp
//
//  Created by huafeng on 2025/4/10.
//

import UIKit
import Foundation

public class MXDevicePropertyItem: NSObject, Codable {
    
    public var identifier: String?
    public var name: String?
    public var compare_type : String = "=="
    public var value: AnyObject?
    public var dataType: MXPropertyDataType?
    
    public var one_click_action: Bool = false  //一键执行动作
    
    public var local_auto_condtion: Bool = false  //本地自动化条件
    public var local_auto_action: Bool = false //本地自动化动作
    
    public var gateway_auto_condtion: Bool = false  //网关自动化条件
    public var gateway_auto_action: Bool = false //网关自动化动作
    
    public var cloud_auto_condtion: Bool = false  //云端自动化条件
    public var cloud_auto_action: Bool = false //云端自动化动作
    
    public var duration: Int?
    
    public func valueCompare(_ objValue: AnyObject?) -> Bool {
        var valueCompare : Bool = false
        if self.dataType?.type == "struct" {
            if let newValue = self.value as? [String : Int], let newObjValue = objValue as? [String: Int] {
                valueCompare = (newValue == newObjValue)
            } else if self.value == nil, objValue == nil {
                valueCompare = true
            }
        } else if self.dataType?.type == "array" {
            if let newValue = self.value as? [Int], let newObjValue = objValue as? [Int] {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? [[String: Int]], let newObjValue = objValue as? [[String: Int]] {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? [String], let newObjValue = objValue as? [String] {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? [Double], let newObjValue = objValue as? [Double] {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? [Float], let newObjValue = objValue as? [Float] {
                valueCompare = (newValue == newObjValue)
            } else if self.value == nil, objValue == nil {
                valueCompare = true
            }
        } else {
            if let newValue = self.value as? String, let newObjValue = objValue as? String {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? Double, let newObjValue = objValue as? Double {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? Int, let newObjValue = objValue as? Int {
                valueCompare = (newValue == newObjValue)
            } else if self.value == nil, objValue == nil {
                valueCompare = true
            }
        }
        return valueCompare
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXDevicePropertyItem else {
            return false
        }
        
        let valueCompare : Bool = self.valueCompare(obj.value)
        
        return (self.identifier == obj.identifier &&
                self.name == obj.name &&
                self.compare_type == obj.compare_type &&
                valueCompare &&
                self.duration == obj.duration)
    }
    
    // MARK: - Codable
    public enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case value
        case dataType
        case compare_type
        case one_click_action
        case local_auto_condtion
        case local_auto_action
        case gateway_auto_condtion
        case gateway_auto_action
        case cloud_auto_condtion
        case cloud_auto_action
        case duration
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try? container.decodeIfPresent(String.self, forKey: .identifier)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.dataType = try? container.decodeIfPresent(MXPropertyDataType.self, forKey: .dataType)
        self.compare_type = (try? container.decode(String.self, forKey: .compare_type)) ?? "=="
        switch self.dataType?.type {
        case "struct":
            self.value = try? container.decodeIfPresent([String : Int].self, forKey: .value) as AnyObject?
            break
        case "bool":
            self.value = try? container.decodeIfPresent(Int.self, forKey: .value) as AnyObject?
            break
        case "enum":
            self.value = try? container.decodeIfPresent(Int.self, forKey: .value) as AnyObject?
            break
        case "string":
            self.value = try? container.decodeIfPresent(String.self, forKey: .value) as AnyObject?
            break
        case "text":
            self.value = try? container.decodeIfPresent(String.self, forKey: .value) as AnyObject?
            break
        case "hex":
            self.value = try? container.decodeIfPresent(String.self, forKey: .value) as AnyObject?
            break
        case "array":
            if let newTypeObj = self.dataType?.specs as? MXPropertyDataType, let newDataType = newTypeObj.item?.type {
                switch newDataType {
                case "struct":
                    self.value = try? container.decodeIfPresent([[String : Int]].self, forKey: .value) as AnyObject?
                    break
                case "bool":
                    self.value = try? container.decodeIfPresent([Int].self, forKey: .value) as AnyObject?
                    break
                case "enum":
                    self.value = try? container.decodeIfPresent([Int].self, forKey: .value) as AnyObject?
                    break
                case "string":
                    self.value = try? container.decodeIfPresent([String].self, forKey: .value) as AnyObject?
                    break
                case "text":
                    self.value = try? container.decodeIfPresent([String].self, forKey: .value) as AnyObject?
                    break
                case "hex":
                    self.value = try? container.decodeIfPresent([String].self, forKey: .value) as AnyObject?
                    break
                case "double":
                    self.value = try? container.decodeIfPresent([Double].self, forKey: .value) as AnyObject?
                    break
                case "float":
                    self.value = try? container.decodeIfPresent([Float].self, forKey: .value) as AnyObject?
                    break
                default:
                    self.value = try? container.decode([Int].self, forKey: .value) as AnyObject
                    break
                }
            } else { //兼容老的
                self.value = try? container.decode([Int].self, forKey: .value) as AnyObject
            }
            break
        default:
            if let newValue = try? container.decode(Double.self, forKey: .value) {
                if self.dataType?.type == "double" || self.identifier == "ColorTemperature" {
                    self.value = newValue as AnyObject
                } else if dataType?.type == "float" {
                    self.value = Float(newValue) as AnyObject
                } else {
                    self.value = Int(newValue) as AnyObject
                }
            } else if let newValue = try? container.decode(String.self, forKey: .value) {
                if let doubleValue = Double(newValue) {
                    //避免数据类型是字符串解析不出来的问题
                    self.value = Int(doubleValue) as AnyObject
                } else {
                    self.value = newValue as AnyObject
                }
            }
            break
        }
        
        self.one_click_action = (try? container.decode(Bool.self, forKey: .one_click_action)) ?? false
        self.local_auto_condtion = (try? container.decode(Bool.self, forKey: .local_auto_condtion)) ?? false
        self.local_auto_action = (try? container.decode(Bool.self, forKey: .local_auto_action)) ?? false
        self.gateway_auto_condtion = (try? container.decode(Bool.self, forKey: .gateway_auto_condtion)) ?? false
        self.gateway_auto_action = (try? container.decode(Bool.self, forKey: .gateway_auto_action)) ?? false
        self.cloud_auto_condtion = (try? container.decode(Bool.self, forKey: .cloud_auto_condtion)) ?? false
        self.cloud_auto_action = (try? container.decode(Bool.self, forKey: .cloud_auto_action)) ?? false
        
        self.duration = try? container.decodeIfPresent(Int.self, forKey: .duration)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(identifier, forKey: .identifier)
        try? container.encodeIfPresent(name, forKey: .name)
        if dataType?.type == "struct", let newValue = self.value as? [String : Int] {
            try? container.encodeIfPresent(newValue, forKey: .value)
        } else if dataType?.type == "array" {
            if let newTypeObj = self.dataType?.specs as? MXPropertyDataType, let newDataType = newTypeObj.item?.type {
                if newDataType == "struct", let newValue = self.value as? [[String: Int]] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else if newDataType == "double", let newValue = self.value as? [Double] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else if newDataType == "float", let newValue = self.value as? [Float] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else if (newDataType == "string" || newDataType == "text" || newDataType == "hex"), let newValue = self.value as? [String] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else if (newDataType == "bool" || newDataType == "enum"), let newValue = self.value as? [Int] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else if let newValue = self.value as? [Int] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                }
            } else { //兼容老的
                if let newValue = self.value as? [Int] {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                }
            }
        } else if (dataType?.type == "bool" || dataType?.type == "enum"), let newValue = self.value as? Int {
            try? container.encodeIfPresent(newValue, forKey: .value)
        } else if (dataType?.type == "string" || self.dataType?.type == "text"), let newValue = self.value as? String {
            try? container.encodeIfPresent(newValue, forKey: .value)
        } else if dataType?.type == "double", let newValue = self.value as? Double {
            try? container.encodeIfPresent(newValue, forKey: .value)
        } else if dataType?.type == "float", let newValue = self.value as? Float {
            try? container.encodeIfPresent(newValue, forKey: .value)
        } else {
            if let newValue = self.value as? Int {
                try? container.encodeIfPresent(newValue, forKey: .value)
            } else if let newValue = self.value as? Double {
                if identifier == "ColorTemperature" {
                    try? container.encodeIfPresent(newValue, forKey: .value)
                } else {
                    try? container.encodeIfPresent(Int(newValue), forKey: .value)
                }
            } else if let newValue = self.value as? String {
                try? container.encodeIfPresent(newValue, forKey: .value)
            }
        }
        try? container.encodeIfPresent(dataType, forKey: .dataType)
        try? container.encodeIfPresent(compare_type, forKey: .compare_type)
        
        try? container.encodeIfPresent(one_click_action, forKey: .one_click_action)
        try? container.encodeIfPresent(local_auto_condtion, forKey: .local_auto_condtion)
        try? container.encodeIfPresent(local_auto_action, forKey: .local_auto_action)
        try? container.encodeIfPresent(gateway_auto_condtion, forKey: .gateway_auto_condtion)
        try? container.encodeIfPresent(gateway_auto_action, forKey: .gateway_auto_action)
        try? container.encodeIfPresent(cloud_auto_condtion, forKey: .cloud_auto_condtion)
        try? container.encodeIfPresent(cloud_auto_action, forKey: .cloud_auto_action)
        try? container.encodeIfPresent(duration, forKey: .duration)
    }
}

extension MXDevicePropertyItem {
    
    var desString: String? {
        get {
            if let type = self.dataType?.type {
                var valueStr = ""
                if (type == "bool" || type == "enum") {
                    if let dataValue = self.value as? Int, let specsParams = self.dataType?.specs as? [String: String] {
                        valueStr = (specsParams[String(dataValue)] ?? "")
                    }
                } else if (type == "string" || type == "text") {
                    if let dataValue = self.value as? String, self.identifier != "Breath" {
                        valueStr = dataValue
                    }
                } else if let value = self.value as? Double {
                    var floatNum = 0
                    if let stepStr = self.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                        if step < 0.1 {
                            floatNum = 2
                        } else if step < 1 {
                            floatNum = 1
                        }
                    }
                    valueStr = String(format: "%.\(floatNum)lf", value)
                }
                if valueStr.count > 0 {
                    return (self.name ?? "") + "-\(valueStr)"
                }
            }
            return (self.name ?? "")
        }
    }
    
    func attributedString() -> NSAttributedString? {
        if let type = self.dataType?.type {
            if (type == "bool" || type == "enum") {
                if let dataValue = self.value as? Int, let specsParams = self.dataType?.specs as? [String: String] {
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + ":" + (specsParams[String(dataValue)] ?? "") + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                }
            } else if (type == "string" || type == "text") {
                if let dataValue = self.value as? String {
                    if self.identifier == "Breath" {
                        let valueStr = NSAttributedString(string: ((self.name ?? "") + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                        return valueStr
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + ":" + dataValue + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                }
            } else if type == "struct" {
                if let p_identifier = self.identifier,
                   p_identifier == "HSVColor",
                   let dataValue = self.value as? [String: Int],
                   let hValue = dataValue["Hue"],
                   let sValue = dataValue["Saturation"],
                   let vValue = dataValue["Value"] {
                    let str = NSMutableAttributedString()
                    let nameStr = NSAttributedString(string: (self.name ?? "") + " ", attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(nameStr)
                    let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.mxIconFont(ofSize: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                    str.append(valueStr)
                    return str
                } else if let dataValue = self.value as? [String: Any], let specs = self.dataType?.specs as? [MXDevicePropertyItem] {
                    let str = NSMutableAttributedString()
                    let nameStr = NSAttributedString(string: (self.name ?? "") + " ", attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(nameStr)
                    let startStr = NSAttributedString(string:"{", attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(startStr)
                    for sub in specs {
                        if let sub_identifier = sub.identifier, let sub_value = dataValue[sub_identifier]  {
                            sub.value = sub_value as AnyObject
                            if let subValueStr = sub.attributedString() {
                                str.append(subValueStr)
                                let spaceStr = NSAttributedString(string: " ", attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                                str.append(spaceStr)
                            }
                        }
                    }
                    let endStr = NSAttributedString(string:"}", attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(endStr)
                    return str
                }
            } else {
                if let dataValue = self.value as? Int {
                    var compareType = self.compare_type
                    if compareType == "==" {
                        compareType = ":"
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(dataValue) + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                } else if let dataValue = self.value as? Double {
                    var compareType = self.compare_type
                    if compareType == "==" {
                        compareType = ":"
                    }
                    var floatNum = 0
                    if let stepStr = self.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                        if step < 0.1 {
                            floatNum = 2
                        } else if step < 1 {
                            floatNum = 1
                        }
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(format: "%.\(floatNum)lf", dataValue) + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                } else if let dataValue = self.value as? String {
                    if self.identifier == "Breath" {
                        let valueStr = NSAttributedString(string: ((self.name ?? "") + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                        return valueStr
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + ":" + dataValue + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                }
            }
        } else {
            if let dataValue = self.value as? Int {
                var compareType = self.compare_type
                if compareType == "==" {
                    compareType = ":"
                }
                let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(dataValue) + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                return valueStr
            } else if let dataValue = self.value as? Double {
                var compareType = self.compare_type
                if compareType == "==" {
                    compareType = ":"
                }
                let floatNum = 0
                let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(format: "%.\(floatNum)lf", dataValue) + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                return valueStr
            } else if let dataValue = self.value as? String {
                if self.identifier == "Breath" {
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    return valueStr
                }
                let valueStr = NSAttributedString(string: ((self.name ?? "") + ":" + dataValue + " "), attributes: [.font: UIFont.mxSystemFont(ofSize: 14),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                return valueStr
            }
        }
        return nil
    }
    
}

public class MXPropertyDataType: NSObject, Codable {
    
    public var type: String?
    public var specs: AnyObject?
    public var item: MXPropertyDataType?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case type
        case specs
        case item
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try? container.decodeIfPresent(String.self, forKey: .type)
        self.item = try? container.decodeIfPresent(MXPropertyDataType.self, forKey: .item)
        if self.type == "struct" {
            if let params = try? container.decodeIfPresent([MXDevicePropertyItem].self, forKey: .specs)  {
                self.specs = params as AnyObject
            }
        } else if self.type == "array" {
            if let params = try? container.decodeIfPresent(MXPropertyDataType.self, forKey: .specs)  {
                self.specs = params as AnyObject
            }
        } else {
            if let params = try? container.decodeIfPresent([String : String].self, forKey: .specs) {
                self.specs = params as AnyObject
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(type, forKey: .type)
        try? container.encodeIfPresent(item, forKey: .item)
        if self.type == "struct" {
            if let newSpecs = self.specs as? [MXDevicePropertyItem] {
                try? container.encodeIfPresent(newSpecs, forKey: .specs)
            }
        } else if self.type == "array" {
            if let newSpecs = self.specs as? MXPropertyDataType {
                try? container.encodeIfPresent(newSpecs, forKey: .specs)
            }
        } else {
            if let newSpecs = self.specs as? [String : String] {
                try? container.encodeIfPresent(newSpecs, forKey: .specs)
            }
        }
    }
}
