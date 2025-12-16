//
//  String+Extension.swift
//  MXApp
//
//  Created by Khazan on 2021/8/3.
//

import Foundation
import UIKit

extension String {
    
    public func nsRange(of string: String) -> NSRange? {
        guard let range = self.range(of: string) else { return nil }
        
        let startPos = self.distance(from: self.startIndex, to: range.lowerBound)
        let endPos = self.distance(from: self.startIndex, to: range.upperBound)
        return NSMakeRange(startPos, endPos - startPos)
     }
    
    public func mxSubString(with range: Range<Int>) -> String {
        let lower = range.lowerBound
        let upper = range.upperBound
        
        if upper >= self.count {
            return self
        }
        
        let start = self.index(self.startIndex, offsetBy: lower)
        let end = self.index(self.startIndex, offsetBy: upper)
        let range = start...end
        
        let sub = String(self[range])
        
        return sub
    }
    
    public func mxSubString(with range: ClosedRange<Int>) -> String {
        let lower = range.lowerBound
        let upper = range.upperBound
        
        if upper >= self.count {
            return self
        }
        
        let start = self.index(self.startIndex, offsetBy: lower)
        let end = self.index(self.startIndex, offsetBy: upper)
        let range = start...end
        
        let sub = String(self[range])
        
        return sub
    }
    
}


extension String {
    
    public func phoneNumberEncryption() -> String {
        guard self.count > 0 else {
            return self
        }
        
        guard self.isValidChinaMainlandPhoneNumber() else {
            return self.emailNumberEncryption()
        }
        var phoneNumber: String!
        
        var end = 7
        if self.count < 7 {
            end = self.count
        }
        let range = self.index(self.startIndex, offsetBy: 3)..<self.index(self.startIndex, offsetBy: end)
        
        var encryption = ""
        var length = 4
        if self.count < 7 {
            length = self.count - 3
        }
        for _ in 0..<length {
            encryption.append(contentsOf: "*")
        }
        
        phoneNumber = self.replacingCharacters(in: range, with: encryption)
        
        return phoneNumber
    }
    
    public func emailNumberEncryption() -> String {
        
        if !self.isValidEmail() {
            return self
        }
        var encryption = ""
        let strList = self.components(separatedBy: "@")
        if strList.count > 0 {
            let firstStr = strList[0]
            var strLength = 2
            if firstStr.count < 2 {
                strLength = 1
            }
            encryption.append(contentsOf: firstStr.prefix(strLength))
            for _ in 0..<3 {
                encryption.append(contentsOf: "*")
            }
            encryption.append(contentsOf: firstStr.suffix(strLength))
        }
        for i in 1 ..< strList.count {
            encryption.append(contentsOf: "@")
            encryption.append(contentsOf: strList[i])
        }
        return encryption
    }
    
}

extension String {
    public func hasEmoji() -> Bool {
        let has = self.filter({ isEmoji(with: $0)})
        return has.count > 0
    }
    
    public func isEmoji(with character: Character) -> Bool {
        let unicodeScalars = character.unicodeScalars
        guard let baseScalar = unicodeScalars.first else { return false }
        
        var isEmoji = baseScalar.properties.isEmoji
        
        if isEmoji {
            if baseScalar.properties.isEmojiPresentation {
                isEmoji = true
            } else {
                if unicodeScalars.filter({return $0.properties.isVariationSelector}).count > 0 {
                    isEmoji = true
                } else {
                    isEmoji = false
                }
            }
        }
        return isEmoji
    }
}

extension String {
    public func getStringSize(font:UIFont, viewSize: CGSize) -> CGSize {
        let rect = self.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
}
