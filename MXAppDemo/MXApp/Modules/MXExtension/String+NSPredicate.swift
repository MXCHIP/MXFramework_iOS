//
//  String+NSPredicate.swift
//  MXApp
//
//  Created by Khazan on 2021/9/14.
//

import Foundation

// https://mxchip.yuque.com/xofya6/app/bdgc9x#0b7e
extension String {
    
    public func isEmpty() -> Bool {
        return self.trimmingCharacters(in: .whitespaces).count == 0
    }
    
    public func isSpace() -> Bool {
        let regEx = "  *"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return pred.evaluate(with: self)
    }
    
    // https://support.huaweicloud.com/intl/zh-cn/productdesc-msgsms/phone_numbers.html
    // 最短5位，最长11位
    public func isValidPhoneNumber() -> Bool {
        
        let emailRegEx = "[0-9]{5,11}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }

    // 大陆手机号 11位
    public func isValidChinaMainlandPhoneNumber() -> Bool {
        
        let emailRegEx = "1[3-9][0-9]{9}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    
    public func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    public func isValidPassword() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]{6,16}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    public func isValidName() -> Bool {
//        var length = 15
//        if MXAccountModel.shared.language.split(separator: "-").first == "en" {
//            length = 100
//        }
        
//        let regEx = "[\u{4e00}-\u{9fa5}A-Z0-9a-z_+-/\\s]{1,15}"
//        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
//        return pred.evaluate(with: self)
        
        return (self.count > 0 && self.count <= MXAppConfig.mxNameMaxLength);
    }
    
    public func isValidIp() -> Bool {
        let ipRegEx = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        let ipPred = NSPredicate(format:"SELF MATCHES %@", ipRegEx)
        
        return ipPred.evaluate(with: self)
    }
    
    public static func convertIpToHex(ipAddress: String) -> String? {
        var addr = inet_addr(ipAddress.cString(using: .utf8))
        
        if (Int32(bitPattern: addr) == INADDR_NONE) {
            return nil // IP地址不支持的格式  Int32(bitPattern: addr) == -1这个校验去掉，255.255.255.255是无效的IP，但子网掩码可以
        } else {
            let bytes = withUnsafeBytes(of:&addr) {$0}
            var hexAddr = ""
            for item in bytes {
                hexAddr += String(format: "%02X", item)
            }
            return hexAddr
        }
    }
    
    public func isKVIdentifier() -> Bool {
        let kvRegEx = "(KV|KV_)[A-F0-9a-f]{4}"
        let kvPred = NSPredicate(format:"SELF MATCHES %@", kvRegEx)
        return kvPred.evaluate(with: self)
    }
    
}

extension String {
    
    public func toastMessageIfIsValidPhoneNumber() -> String? {
        
        var string: String?

        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidAccount() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else {
            if MXCountryManage.shard.currentCountry?.ServerStation == "China" {
                if !self.isValidChinaMainlandPhoneNumber() {
                    string = MXAppConfig.mxLocalized(key: "mx_account_phone_invalid")
                }
            } else {
                if !self.isValidEmail() {
                    string = MXAppConfig.mxLocalized(key: "mx_account_email_invalid")
                }
            }
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidSceneName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else if !self.isValidName() {
            string = String(format: MXAppConfig.mxLocalized(key: "mx_name_invalid"), MXAppConfig.mxNameMaxLength)
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidUserName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else if !self.isValidName() {
            string = String(format: MXAppConfig.mxLocalized(key: "mx_name_invalid"), MXAppConfig.mxNameMaxLength)
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidRoomName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else if !self.isValidName() {
            string = String(format: MXAppConfig.mxLocalized(key: "mx_name_invalid"), MXAppConfig.mxNameMaxLength)
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidHomeName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else if !self.isValidName() {
            string = String(format: MXAppConfig.mxLocalized(key: "mx_name_invalid"), MXAppConfig.mxNameMaxLength)
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidDeviceName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_no_input")
        } else if !self.isValidName() {
            string = String(format: MXAppConfig.mxLocalized(key: "mx_name_invalid"), MXAppConfig.mxNameMaxLength)
        }
        
        return string
    }
    
    public func toastMessageIfIsInValidGroupName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = MXAppConfig.mxLocalized(key: "mx_group_name_input_hint")
        } else if !self.isValidName() {
            string = MXAppConfig.mxLocalized(key: "mx_group_name_invalid")
        }
        
        return string
    }
    
    public func isValidGatewayPassword() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]{6,32}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
}



// 安卓判断输入规则
// 1.判断文案是否为空
// 2.非空下调用接口，验证文本格式，使用接口文案
// 3.文本格式正确，提示当前业务文案
extension String {
    
    public func toastMessageIfIsEmpty(with message: String? = nil) -> String? {
        if self.isEmpty {
            return message ?? MXAppConfig.mxLocalized(key: "mx_no_input")
        }
        return nil
    }
    
}
