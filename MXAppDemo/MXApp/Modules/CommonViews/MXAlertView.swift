//
//  MXAlertView.swift
//  MXApp
//
//  Created by Khazan on 2021/8/2.
//

import Foundation
import UIKit
import WebKit
import PinLayout
import SDWebImage

open class MXCustomizeAlertView: UIView {
    
    /// 弹窗
    open func show() -> Void {
        if let window = UIApplication.shared.delegate?.window {
            window?.addSubview(self)
        } else {
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                   if let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                      let window = sceneDelegate.window  {
                       window?.addSubview(self)
                   } else if let window = windowScene.windows.first  {
                       window.addSubview(self)
                   }
                }
            } else {
                if let window = UIApplication.shared.keyWindow {
                    window.addSubview(self)
                }
            }
        }
    }
    
    /// 关闭弹窗
    public func autoDisappear() -> Void {
        if self.isAutoDisappear {
            self.disappear()
        }
    }
    
    public func disappear() -> Void {
        self.removeFromSuperview()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubviews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initSubviews() -> Void {
        self.backgroundColor = UIColor(hex: "000000").withAlphaComponent(0.4)

        self.addSubview(contentView)
        contentView.backgroundColor = MXAppConfig.MXWhite.level4
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        contentView.pin.center().width(304).height(426)
    }
    
    var contentView = UIView()
    
    var isAutoDisappear = true

}

public class MXAlertView: MXCustomizeAlertView {
        
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - leftButtonTitle: 左按钮标题
    ///   - rightButtonTitle: 右按钮标题
    ///   - leftButtonCallBack: 左按钮点击事件
    ///   - rightButtonCallBack: 右按钮点击事件
    public convenience init(title: String, message: String, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping (() -> Void), rightButtonCallBack:@escaping (() -> Void)) {
        self.init()
        self.titleLabel.text = title
        
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = MXAppConfig.MXColor.primaryText
        messageLabel.font = UIFont.mxSystemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        self.messageLabel = messageLabel
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = MXAppConfig.MXBackgroundColor.level5
        leftButton.setTitleColor(MXAppConfig.MXColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = MXAppConfig.MXColor.theme
        rightButton.setTitleColor(.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.leftButtonClosure = leftButtonCallBack
        self.rightButtonClosure = rightButtonCallBack
    }
    
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - confirmButtonTitle: 按钮标题
    ///   - confirmButtonCallBack: 按钮点击事件
    public convenience init(title: String, message: String, confirmButtonTitle:String, confirmButtonCallBack: @escaping (() -> Void)) {
        self.init()
        self.titleLabel.text = title
        
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = MXAppConfig.MXColor.primaryText
        messageLabel.font = UIFont.mxSystemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        self.messageLabel = messageLabel
        
        let confirmButton = UIButton()
        confirmButton.setTitle(confirmButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(confirmButton)
        confirmButton.backgroundColor = MXAppConfig.MXColor.theme
        confirmButton.setTitleColor(.white, for: UIControl.State.normal)
        confirmButton.layer.cornerRadius = 22
        confirmButton.addTarget(self, action: #selector(confirmButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.confirmButton = confirmButton
        
        self.confirmButtonClosure = confirmButtonCallBack
    }
    
    public convenience init(title: String, placeholder: String, text: String? = nil, maxLength: Int? = nil, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping ((_ textField: UITextField, _ alert: MXAlertView) -> Void), rightButtonCallBack:@escaping ((_ textField: UITextField, _ alert: MXAlertView) -> Void)) {
        self.init()
        self.isAutoDisappear = false
        
        self.titleLabel.text = title
        
        if let length = maxLength {
            self.inputMaxCount = length;
        }

        let textField = UITextField()
        contentView.addSubview(textField)
        textField.placeholder = placeholder
        textField.text = text
        textField.layer.borderWidth = 2
        textField.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        textField.layer.cornerRadius = 8
        textField.textColor = MXAppConfig.MXColor.primaryText
        textField.font = UIFont.mxSystemFont(ofSize: 16)
        textField.tintColor = MXAppConfig.MXColor.theme
        let leftView = UIView()
        leftView.pin.width(16).height(0)
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        self.textField = textField
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = MXAppConfig.MXBackgroundColor.level5
        leftButton.setTitleColor(MXAppConfig.MXColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = MXAppConfig.MXColor.theme
        rightButton.setTitleColor(.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.inputLeftButtonClosure = leftButtonCallBack
        self.inputRightButtonClosure = rightButtonCallBack
    }
    
    public convenience init(title: String, titleColor: UIColor? = nil, message: String? = nil,  placeholder: String, text: String? = nil, maxLength: Int? = nil, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping ((_ textField: UITextField, _ alert: MXAlertView) -> Void), rightButtonCallBack:@escaping ((_ textField: UITextField, _ alert: MXAlertView) -> Void)) {
        self.init()
        self.isAutoDisappear = false
        
        self.titleLabel.text = title
        self.titleLabel.textColor = titleColor ?? MXAppConfig.MXColor.title
        
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = MXAppConfig.MXColor.primaryText
        messageLabel.font = UIFont.mxSystemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        self.messageLabel = messageLabel
        
        if let length = maxLength {
            self.inputMaxCount = length;
        }

        let textField = UITextField()
        contentView.addSubview(textField)
        textField.placeholder = placeholder
        textField.text = text
        textField.layer.borderWidth = 2
        textField.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        textField.layer.cornerRadius = 8
        textField.textColor = MXAppConfig.MXColor.primaryText
        textField.font = UIFont.mxSystemFont(ofSize: 16)
        textField.tintColor = MXAppConfig.MXColor.theme
        let leftView = UIView()
        leftView.pin.width(16).height(0)
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        self.textField = textField
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = MXAppConfig.MXBackgroundColor.level5
        leftButton.setTitleColor(MXAppConfig.MXColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = MXAppConfig.MXColor.theme
        rightButton.setTitleColor(.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.inputLeftButtonClosure = leftButtonCallBack
        self.inputRightButtonClosure = rightButtonCallBack
    }
    
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容
    ///   - leftButtonTitle: 左按钮标题
    ///   - rightButtonTitle: 右按钮标题
    ///   - leftButtonCallBack: 左按钮点击事件
    ///   - rightButtonCallBack: 右按钮点击事件
    public convenience init(title: String, message: String, linkStrs: [String]? = nil, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping (() -> Void), rightButtonCallBack:@escaping (() -> Void), linkCallBack:@escaping ((_ value: Int) -> Void)) {
        self.init()
        self.titleLabel.text = title
        self.links = linkStrs
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .left
        messageLabel.textColor = MXAppConfig.MXColor.primaryText
        messageLabel.font = UIFont.mxSystemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        
        messageLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(messageTapGestureAction(gesture:)))
        messageLabel.addGestureRecognizer(tap)
        
        let font = UIFont.mxSystemFont(ofSize: 14)
        let attributedString = NSMutableAttributedString(string: message, attributes: [.font: font, .foregroundColor: MXAppConfig.MXColor.primaryText])
        if let links = linkStrs {
            for link in links {
                if let range1 = message.nsRange(of: link) {
                    attributedString.setAttributes([.font: font, .foregroundColor: MXAppConfig.MXColor.theme, .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: MXAppConfig.MXColor.theme], range: range1)
                }
            }
        }
        messageLabel.attributedText = attributedString
        self.messageLabel = messageLabel
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = MXAppConfig.MXBackgroundColor.level3
        leftButton.setTitleColor(MXAppConfig.MXColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = MXAppConfig.MXColor.theme
        rightButton.setTitleColor(.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.leftButtonClosure = leftButtonCallBack
        self.rightButtonClosure = rightButtonCallBack
        self.linkTapCallback = linkCallBack
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            // 调整视图布局，例如将某个输入框的上边缘上移键盘高度距离
           mxAppLog("键盘高度：\(keyboardHeight)")
            if self.frame.size.height - self.contentView.frame.maxY < keyboardHeight {
                self.contentView.pin.bottom(keyboardHeight)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        contentView.pin.center()
    }
    
//    /// 点击弹窗按钮
//    /// - Parameters:
//    ///   - left: 点击左边按钮
//    ///   - right: 点击右边按钮
//    func didSelectedButton(left: @escaping () -> Void, right:@escaping () -> Void) -> Void {
//        self.leftButtonClosure = left
//        self.rightButtonClosure = right
//    }
    
    public override func show() {
        super.show()
        if let textField = textField {
            // 添加键盘显示通知
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            // 添加键盘隐藏通知
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            textField.becomeFirstResponder()
        }
    }
    
    public func show(keyword: Bool = false) {
        super.show()
        // 添加键盘显示通知
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 添加键盘隐藏通知
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if let textField = textField, keyword {
            textField.becomeFirstResponder()
        }
    }
    
    public override func disappear() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.disappear()
    }
    
    public override func initSubviews() -> Void {
        super.initSubviews()
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.textColor = MXAppConfig.MXColor.title
        titleLabel.font = UIFont.mxSystemFont(ofSize: 18, weight: .medium)
        titleLabel.numberOfLines = 0
    }
    
    // 点击协议
    @objc func messageTapGestureAction(gesture: UITapGestureRecognizer) -> Void {
        if let lab = self.messageLabel, let pro = self.messageLabel?.text, let links = self.links {
            for i in 0 ..< links.count {
                let link = links[i]
                if let range1 = pro.nsRange(of: link) {
                    let tapped = gesture.didTapAttributedTextInLabel(label: lab, inRange: range1)
                    if tapped {
                        self.autoDisappear()
                        self.linkTapCallback?(i)
                    }
                }
            }
        }

    }
    
    @objc func leftButtonAction(sender: UIButton) -> Void {
        autoDisappear()
        if let closure = self.leftButtonClosure {
            closure()
        }
        if let closure = inputLeftButtonClosure, let textField = textField {
            closure(textField, self)
        }
    }
    
    @objc func rightButtonAction(sender: UIButton) -> Void {
        autoDisappear()
        if let closure = self.rightButtonClosure {
            closure()
        }
        if let closure = inputRightButtonClosure, let textField = textField {
            closure(textField, self)
        }
    }
    
    @objc func confirmButtonAction(sender: UIButton) -> Void {
        autoDisappear()
        guard let closure = self.confirmButtonClosure else { return }
        closure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.pin.top(24).width(256).sizeToFit(.width)
        
        if let messageLabel = messageLabel {
            messageLabel.pin.below(of: titleLabel).marginTop(16).width(256).sizeToFit(.width)
            if let textField = textField {
                textField.pin.below(of: messageLabel).marginTop(16).width(256).height(50)
                if let leftButton = leftButton {
                    leftButton.pin.below(of: textField, aligned: .left).marginTop(32).width(120).height(44)
                }
                if let rightButton = rightButton {
                    rightButton.pin.below(of: textField, aligned: .right).marginTop(32).width(120).height(44)
                }
                if let confirmButton = confirmButton {
                    confirmButton.pin.below(of: textField).marginTop(32).width(256).height(44)
                }
            } else {
                if let leftButton = leftButton {
                    leftButton.pin.below(of: messageLabel, aligned: .left).marginTop(32).width(120).height(44)
                }
                if let rightButton = rightButton {
                    rightButton.pin.below(of: messageLabel, aligned: .right).marginTop(32).width(120).height(44)
                }
                if let confirmButton = confirmButton {
                    confirmButton.pin.below(of: messageLabel).marginTop(32).width(256).height(44)
                }
            }
            
            contentView.pin.wrapContent(padding: 24.0).center()
        } else if let textField = textField {
            textField.pin.below(of: titleLabel).marginTop(16).width(256).height(50)
            if let leftButton = leftButton {
                leftButton.pin.below(of: textField, aligned: .left).marginTop(32).width(120).height(44)
            }
            if let rightButton = rightButton {
                rightButton.pin.below(of: textField, aligned: .right).marginTop(32).width(120).height(44)
            }
            
            contentView.pin.wrapContent(padding: 24.0).center()
        }
        
    }
    
    let titleLabel = UILabel()
    
    var messageLabel: UILabel?

    var textField: UITextField?

    var leftButton: UIButton?
    var rightButton: UIButton?

    var leftButtonClosure: (() -> Void)?
    var rightButtonClosure: (() -> Void)?
    
    var confirmButton: UIButton?
    var confirmButtonClosure: (() -> Void)?

    var inputLeftButtonClosure: ((_ textField: UITextField, _ alert: MXAlertView) -> Void)?
    var inputRightButtonClosure: ((_ textField: UITextField, _ alert: MXAlertView) -> Void)?
    
    var inputMaxCount: Int = 0
    
    var links:[String]?
    var linkTapCallback: ((_ value: Int) -> Void)?
    
}

extension MXAlertView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.hasEmoji() {
            return false
        }
//        if self.inputMaxCount > 0 {
//            if let text = textField.text, let textRange = Range(range, in: text) {
//                let mStr = text.replacingCharacters(in: textRange, with: string);
//                if mStr.trimmingCharacters(in: .whitespaces).count > self.inputMaxCount {
//                    return false
//                }
//            }
//        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


