//
//  UIColor+Extension.swift
//  MXApp
//
//  Created by huafeng on 2024/9/6.
//

import Foundation
import UIKit

extension UIColor {
    
    public var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    public convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    public convenience init(hex: String, alpha : Float) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: CGFloat(alpha)
        )
    }
    
    public convenience init(with lightModeHex: String,
                     lightModeAlpha: Float,
                     darkModeHex: String,
                     darkModeAlpha : Float) {
        
        self.init { (trait: UITraitCollection) in
            if trait.userInterfaceStyle == .light {
                return UIColor(hex: lightModeHex, alpha: lightModeAlpha)
            } else {
                return UIColor(hex: darkModeHex, alpha: darkModeAlpha)
            }
        }
    }
    
}
