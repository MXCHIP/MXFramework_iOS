//
//  MXCodeInputModel.swift
//  MXApp
//
//  Created by Khazan on 2021/9/13.
//

import Foundation

class MXCodeInputModel: NSObject {
    
    // 0 code signin, 1 password signin, 2 reset password, 3 fast signin, 4 三方登陆账户绑定
    var pageKind = 0
    
    var account = ""
        
    var code = ""

    var ifExist = false
    
    var register_token = ""
    
    
    
    let totalTime = 60
    
    let timeInterval = 1
    
    var isCountDown = false
    
    var remainder = 0
    
    override init() {
        super.init()
        
        remainder = totalTime
    }
    
}
