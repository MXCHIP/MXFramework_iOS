//
//  MXAccountInputPage.swift
//  MXApp
//
//  Created by Khazan on 2021/8/11.
//

import Foundation
import UIKit

public class MXAccountInputPage: MXBaseViewController {
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initSubviews()
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.addSubview(self.titleLB)
        
        self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_password_login")
        
        self.contentView.addSubview(inputTextField)
        inputTextField.mxDelegate = self
        
        if MXCountryManage.shard.currentCountry?.ServerStation == "China" {
            inputTextField.placeholder = MXAppConfig.mxLocalized(key: "mx_account_phone_hint")
            let leftView = UIView()
            leftView.pin.width(70).height(50)
            numberLabel.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
            numberLabel.text = "(+" + "86" + ")"
            numberLabel.textColor = MXAppConfig.MXColor.secondaryText
            leftView.addSubview(numberLabel)
            numberLabel.pin.left(20).height(20).vCenter().sizeToFit(.height)
            inputTextField.leftView = leftView
            inputTextField.leftViewMode = .always
            inputTextField.keyboardType = .phonePad
        } else {
            inputTextField.placeholder = MXAppConfig.mxLocalized(key: "mx_account_email_hint")
            let leftView = UIView()
            leftView.pin.width(50).height(50)
            numberLabel.font = UIFont.mxIconFont(ofSize: 16)
            numberLabel.text = "\u{e894}"
            numberLabel.textColor = MXAppConfig.MXColor.primaryText
            leftView.addSubview(numberLabel)
            numberLabel.pin.left(20).width(20).height(20).vCenter()
            inputTextField.leftView = leftView
            inputTextField.leftViewMode = .always
            inputTextField.keyboardType = .emailAddress
        }
        
        self.contentView.addSubview(nextButton)
        nextButton.setTitle(MXAppConfig.mxLocalized(key: "mx_next"), for: UIControl.State.normal)
        nextButton.addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
        nextButton.isEnabled = false
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.titleLB.pin.left(24).top(24).right(24).height(24)
        inputTextField.pin.below(of: self.titleLB).marginTop(32).left(24).right(24).height(50)
        nextButton.pin.below(of: inputTextField).marginTop(24).left(24).right(24).height(50)
    }
    let numberLabel = UILabel()
    let inputTextField = MXColorTextFiled()
    let nextButton = MXColorButton()
    
    lazy var titleLB: UILabel = {
        let _label = UILabel(frame: .zero)
        _label.font = UIFont.mxSystemFont(ofSize: 24, weight: .medium)
        _label.textColor = MXAppConfig.MXColor.title
        return _label
    }()
}

// 输入账户
extension MXAccountInputPage: MXColorTextFiledDelegate {
    
    public func editingChanged(_ textField: UITextField) {
        
        if let text = textField.text {
            nextButton.isEnabled = text.count > 0 ? true : false
        }
    }
    
    @objc func touchUpInside(sender: UIButton) {
        guard let account = self.inputTextField.text?.trimmingCharacters(in: .whitespaces),
              account.count > 0 else {
            return
        }
        self.view.endEditing(true)
        let url = "https://com.mxchip.bta/page/account/password"
        let params = ["pageKind": 1,
                      "account": account] as [String : Any]
        MXURLRouter.open(url: url, params: params)
    }
    
}

extension MXAccountInputPage: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        } else {
            return true
        }
    }
    
}

extension MXAccountInputPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAccountInputPage()
        return vc
    }
    
}
