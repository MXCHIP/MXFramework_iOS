//
//  MXAccountModel.swift
//  MXApp
//
//  Created by Khazan on 2021/6/11.
//

import Foundation
import UIKit
import MXAPIManager

open class MXAccountModel: NSObject {
    
    // singleton
    public static let shared = MXAccountModel()
    
    public var language : String {
        get {
            if let lang = UserDefaults.standard.string(forKey: "MXAppCurrentLanguage") {
                return lang
            }
            return "zh-Hans"
        }
        set {
            MXAPIManager.shared.update(language: newValue)
            UserDefaults.standard.set(newValue, forKey: "MXAppCurrentLanguage")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MXNotificationAppLanguageChange"), object: nil)
        }
    }
    
    public var token: String? {
        get {
            return  UserDefaults.standard.string(forKey: "MXToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXToken")
        }
    }
    
    public var account: String? {
        get {
            return  UserDefaults.standard.string(forKey: "MXAccount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXAccount")
        }
    }
    
    public var pushID = ""
    
    // 用户当前位置
    public var locationLatitude: Double?
    public var locationLongitude: Double?

    public func isSignedIn() -> Bool {
        if self.token != nil {
            return true
        }
        
        return false
    }
    
    // signIn
    public func signIn(with token: String) -> Void {
        self.token = token
    }
    
    // 登出
    public func signOut() -> Void {
        self.token = nil
        MXAPIManager.shared.update(token: "")
    }
    
}
