//
//  MXAccountInputModel.swift
//  MXApp
//
//  Created by Khazan on 2021/8/11.
//

import Foundation


class MXAccountInputModel: NSObject {
    
    var ifAgree = false
    
    // 0 code signin, 1 password signin, 2 reset password, 3 三方登陆账户绑定， 5 忘记密码
    var pageKind = 0
    
    var account = ""

    var register_token = ""
    
    var shouldAnimateProtocolView = false
    
}
