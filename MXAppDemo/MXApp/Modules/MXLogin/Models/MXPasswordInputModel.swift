//
//  MXPasswordInputModel.swift
//  MXApp
//
//  Created by Khazan on 2021/8/19.
//

import Foundation

class MXPasswordInputModel: NSObject {
    
    // 0 code signin, 1 password signin, 2 reset password, 3 fast signin, 4 三方登陆账户绑定
    var pageKind = 0
    
    var account = ""
        
    var code = ""
    
    var password = ""
    
    var token = ""

    var register_token = ""
    
    var passwordIsHidden = true
    
    
    
}
