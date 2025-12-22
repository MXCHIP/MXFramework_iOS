//
//  MXAppConfiguration.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/23.
//

import Foundation
import UIKit

func mxAppLog<T>(_ message: T) {
    print("\(Date())[MXApp] \(message)")
}

public class MXAppConfig: NSObject {
    public static var statusBarH : CGFloat {
        get {
            if #available(iOS 13.0, *) {
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                return scene?.statusBarManager?.statusBarFrame.size.height ?? 44
            } else {
                // 在iOS 13以下版本中，可以直接使用statusBarFrame
                return UIApplication.shared.statusBarFrame.size.height
            }
        }
    }
    public static let navBarH : CGFloat = 44.0
    
    public static let mxNameMaxLength = 30
    public static let mxScreenWidth = UIScreen.main.bounds.size.width
    public static let mxScreenHeight = UIScreen.main.bounds.size.height
    public static let mxAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    public static var MXHost = "https://sit-app-api-cloud.dev.mxchip.com.cn/"
    public static var MXAppId = ""
    public static var MXAppSecert = ""
    public static var mxAppType = 0
    public static var MXIotHTTPHost = "api-demo.fogcloud.io"
    public static var MXIotMQTTHost = "mqtt-demo.fogcloud.io"

    public static func mxLocalized(key: String) -> String {
        let currentLang = MXAccountModel.shared.language
        if let langPath = Bundle.main.path(forResource: currentLang, ofType: "lproj"),
           let langBundle = Bundle.init(path: langPath)  {
            return langBundle.localizedString(forKey: key, value: nil, table: "MXLocalizable")
        }
        return NSLocalizedString(key, tableName: "MXLocalizable", comment: "")
    }
    
    public struct MXColor {
        /// 262626
        public static var title: UIColor  {
            return UIColor(with: "262626", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.85)
        }
        /// 595959
        public static var primaryText: UIColor  {
            return UIColor(with: "595959", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.65)
        }
        /// 8C8C8C
        public static var secondaryText: UIColor  {
            return UIColor(with: "8C8C8C", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.45)
        }
        /// BFBFBF
        public static var disable: UIColor  {
            return UIColor(with: "BFBFBF", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.25)
        }
        /// EEEEEE
        public struct border  {
            public static var level1: UIColor  {
                return UIColor(with: "EEEEEE", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.15)
            }
            
            public static var level2: UIColor  {
                return UIColor(with: "EEEEEE", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.1)
            }
        }
        
        public static var red: UIColor {
            return UIColor(hex: "FF4D4F")
        }
        
        public static var yellow: UIColor {
            return UIColor(hex: "FAAD14")
        }
        
        public static var theme: UIColor {
            return UIColor(hex: "13B7F9")
        }
    }
    
    public struct MXBackgroundColor {
        public static var level1: UIColor  {
            return UIColor(with: "F2F2F7", lightModeAlpha: 1, darkModeHex: "000000", darkModeAlpha: 1)
        }
        
        public static var level3: UIColor  {
            return UIColor(with: "F8F8F8", lightModeAlpha: 1, darkModeHex: "303030", darkModeAlpha: 1)
        }
        
        public static var level4: UIColor  {
            return UIColor(with: "F5F5F5", lightModeAlpha: 1, darkModeHex: "303030", darkModeAlpha: 1)
        }
        
        public static var level5: UIColor  {
            return UIColor(with: "F5F5F5", lightModeAlpha: 1, darkModeHex: "404040", darkModeAlpha: 1)
        }
    }
    
    public struct MXWhite {
        public static var level1: UIColor  {
            return UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "000000", darkModeAlpha: 1)
        }
        
        public static var level2: UIColor  {
            return UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "121212", darkModeAlpha: 1)
        }
        
        public static var level3: UIColor  {
            return UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "1A1A1A", darkModeAlpha: 1)
        }
        
        public static var level4: UIColor  {
            return UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "303030", darkModeAlpha: 1)
        }
        
        public static var level5: UIColor  {
            return UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "404040", darkModeAlpha: 1)
        }
    }
    
}
