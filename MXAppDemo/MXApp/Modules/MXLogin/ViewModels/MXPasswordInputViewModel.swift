//
//  MXPasswordInputViewModel.swift
//  MXApp
//
//  Created by Khazan on 2021/8/19.
//

import Foundation

class MXPasswordInputViewModel: NSObject {
    
    let model = MXPasswordInputModel()
    
    // 数据传递给model
    func store(params: Dictionary<String, Any>) -> Void {
        if let pageKind = params["pageKind"] as? Int,
           let account = params["account"] as? String {
            model.pageKind = pageKind
            model.account = account
        }
        
        if let code = params["code"] as? String {
            model.code = code
        }
        if let token = params["token"] as? String {
            model.token = token
        }
        if let register_token = params["register_token"] as? String {
            model.register_token = register_token
        }
        
    }
    
    var updatingViewClosure: ((_ model: MXPasswordInputModel) -> Void)!
    
    // 监听数据变化
    func observe(handler:@escaping (_ model: MXPasswordInputModel) -> Void) -> Void {
        self.updatingViewClosure = handler
    }
    
    // 刷新UI
    func updateViews() -> Void {
        if let closure = updatingViewClosure {
            closure(model)
        }
    }
    
    // 更新密码
    func update(password: String) -> Void {
        
        self.model.password = password
        
        updateViews()
    }
    
    // 密码是否可见
    func hiddenPassword() -> Void {
        model.passwordIsHidden = !model.passwordIsHidden
        
        updateViews()
    }
    
    // 下一步
    func nextPage() -> Void {
        if let msg = model.password.toastMessageIfIsEmpty() {
            MXToastHUD.showInfo(status: msg)
            return
        }
        signIn()
        
    }
    
    // 登录
    func signIn() -> Void {
        let areaCode = String(MXCountryManage.shard.currentCountry?.code ?? 86)
        let clientId = MXAccountModel.shared.pushID
        let iSO3 = MXCountryManage.shard.currentCountry?.ISO3
        MXAPI.user.signIn(with: model.account, password: model.password, clientid: clientId, area: areaCode, iso3: iSO3) { [weak self] (data: Any, msg: String, code: Int) in
            
            guard let ws = self,
                  let da = data as? [String: Any],
                  let token = da["token"] as? String
            else { return }
            
            ws.signIn(with: token, account: ws.model.account)
        }
        
    }
    
    // 去登录
    func signIn(with token: String, account: String) -> Void {
        let userInfo = ["token": token, "account": account]

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MXNotificationUserSignedIn"), object: nil, userInfo: userInfo)
    }
    
    
}
