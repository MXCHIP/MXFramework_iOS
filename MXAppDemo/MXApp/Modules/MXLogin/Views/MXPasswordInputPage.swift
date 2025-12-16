//
//  MXPasswordInputPage.swift
//  MXApp
//
//  Created by Khazan on 2021/8/18.
//

import Foundation
import UIKit

public class MXPasswordInputPage: MXBaseViewController {
    
    let viewModel = MXPasswordInputViewModel()
    
    // 隐藏密码
    @objc func hiddenPassword(sender: UITapGestureRecognizer) -> Void {
        viewModel.hiddenPassword()
    }
    
    func updateSubviews(with model: MXPasswordInputModel) -> Void {
        
        self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_password")
        if model.password.isEmpty || model.password.isSpace() {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        
        if model.passwordIsHidden {
            hiddenLabel.text = "\u{e695}"
        } else {
            hiddenLabel.text = "\u{e693}"
        }
        
        inputTextField.isSecureTextEntry = model.passwordIsHidden
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        
        self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_login")
        
        viewModel.observe { [weak self] (model: MXPasswordInputModel) in
            self?.updateSubviews(with: model)
        }
        
        viewModel.updateViews()
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.addSubview(self.titleLB)
        self.contentView.addSubview(inputTextField)
        inputTextField.mxDelegate = self
        inputTextField.placeholder = MXAppConfig.mxLocalized(key: "mx_password_hint")
        inputTextField.isSecureTextEntry = true
        
        let leftView = UIView()
        leftView.pin.width(54).height(50)
        let psdLabel = UILabel()
        psdLabel.font = UIFont.mxIconFont(ofSize: 20)
        psdLabel.text = "\u{e694}"
        psdLabel.textColor = MXAppConfig.MXColor.primaryText
        leftView.addSubview(psdLabel)
        psdLabel.pin.left(24).vCenter().width(20).height(20)
        inputTextField.leftView = leftView
        inputTextField.leftViewMode = .always

        let rightView = UIView()
        rightView.pin.width(84).height(50)
        hiddenLabel.font = UIFont.mxIconFont(ofSize: 20)
        hiddenLabel.text = "\u{e695}"
        hiddenLabel.textColor = MXAppConfig.MXColor.disable
        rightView.addSubview(hiddenLabel)
        hiddenLabel.pin.right(24).vCenter().width(22).height(22)
        hiddenLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenPassword(sender:)))
        hiddenLabel.addGestureRecognizer(tap)
        inputTextField.rightView = rightView
        inputTextField.rightViewMode = .always
        
        self.contentView.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
        nextButton.setTitle(MXAppConfig.mxLocalized(key: "mx_confirm"), for: UIControl.State.normal)
        nextButton.isEnabled = false
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.titleLB.pin.left(24).top(24).right(24).height(24)
        inputTextField.pin.below(of: self.titleLB).marginTop(32).left(24).right(24).height(50)
        nextButton.pin.below(of: inputTextField).marginTop(24).left(24).right(24).height(50)

    }
    
    let inputTextField = MXColorTextFiled()
    
    let nextButton = MXColorButton()
    
    let hiddenLabel = UILabel()
    
    lazy var titleLB: UILabel = {
        let _label = UILabel(frame: .zero)
        _label.font = UIFont.mxSystemFont(ofSize: 24, weight: .medium)
        _label.textColor = MXAppConfig.MXColor.title
        return _label
    }()

}

extension MXPasswordInputPage: MXColorTextFiledDelegate {
    
    public func editingChanged(_ textField: UITextField) {
        
        if let text = textField.text {
            viewModel.update(password: text)
        }
    }
    
    @objc func touchUpInside(sender: UIButton) {
        viewModel.nextPage()
    }
    
}

extension MXPasswordInputPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXPasswordInputPage()
        vc.viewModel.store(params: params)
        return vc
    }
    
}
