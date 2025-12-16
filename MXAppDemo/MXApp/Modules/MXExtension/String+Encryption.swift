//
//  String+Encryption.swift
//  MXApp
//
//  Created by 华峰 on 2021/7/7.
//

import Foundation
import CommonCrypto
import CryptoKit

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func base64Encoding() -> String {
        let strData = self.data(using: .utf8)
        if let base64 = strData?.base64EncodedString() {
            return base64
        }
        return ""
    }
}
