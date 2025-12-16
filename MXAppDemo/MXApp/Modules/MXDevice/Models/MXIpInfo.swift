//
//  MXIPInfo.swift
//  MXBuild
//
//  Created by huafeng on 2024/6/27.
//

import Foundation

public class MXIpInfo: NSObject, Codable {
    
    public var ip: String?
    public var netmask: String?
    public var gateway: String?
    public var dns: String?
    
    public var mac: String?
    
    //直接转成Hex
    public var ipInfoHex: String? {
        get {
            if let ipStr = self.ip, ipStr.isValidIp(),
               let netmaskStr = self.netmask, netmaskStr.isValidIp(),
               let gatewayStr = self.gateway, gatewayStr.isValidIp(),
               let dnsStr = self.dns, dnsStr.isValidIp() {
                var hex = ""
                if let ipHex = String.convertIpToHex(ipAddress: ipStr) {
                    hex += ipHex
                }
                if let ipHex = String.convertIpToHex(ipAddress: netmaskStr) {
                    hex += ipHex
                }
                if let ipHex = String.convertIpToHex(ipAddress: gatewayStr) {
                    hex += ipHex
                }
                if let ipHex = String.convertIpToHex(ipAddress: dnsStr) {
                    hex += ipHex
                }
                return hex
                
            }
            return nil
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXIpInfo else {
            return false
        }
        
        return (self.ip == obj.ip &&
                self.netmask == obj.netmask &&
                self.gateway == obj.gateway &&
                self.dns == obj.dns &&
                self.mac == obj.mac)
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case ip
        case netmask
        case gateway
        case dns
        case mac
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.netmask = try container.decodeIfPresent(String.self, forKey: .netmask)
        self.gateway = try container.decodeIfPresent(String.self, forKey: .gateway)
        self.dns = try container.decodeIfPresent(String.self, forKey: .dns)
        self.mac = try container.decodeIfPresent(String.self, forKey: .mac)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(ip, forKey: .ip)
        try container.encodeIfPresent(netmask, forKey: .netmask)
        try container.encodeIfPresent(gateway, forKey: .gateway)
        try container.encodeIfPresent(dns, forKey: .dns)
        try container.encodeIfPresent(mac, forKey: .mac)
    }
}
