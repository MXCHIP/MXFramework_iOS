//
//  CodeTextField.swift
//  MXApp
//
//  Created by Khazan on 2021/6/17.
//

import Foundation
import UIKit

public protocol CodeTextFieldDelegate {
    
    func textFieldDeleteBackward(_ current: UITextField) -> Void
    
    func textFieldDidBeginEditing(_ current: UITextField) -> Void

    func textFieldEditing(_ current: UITextField) -> Void

}


public class CodeTextField: UITextField {
    
    var codeDelegate: CodeTextFieldDelegate?
    
    // 删除
    public override func deleteBackward() {
        super.deleteBackward()
        codeDelegate?.textFieldDeleteBackward(self)
    }
        
    // 编辑中
    @objc func editing(sender: UITextField) -> Void {
        codeDelegate?.textFieldEditing(sender)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.stepUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stepUp() -> Void {
        self.textAlignment = .center
        self.keyboardType = .numberPad
        self.delegate = self
        self.addTarget(self, action: #selector(editing(sender:)), for: .editingChanged)
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 2
        self.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        self.tintColor = MXAppConfig.MXColor.theme
        self.textColor = MXAppConfig.MXColor.title
        self.font = UIFont(name: "DINAlternate-Bold", size: 24)
    }
    
}

extension CodeTextField: UITextFieldDelegate {
    
    // 开始编辑
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        codeDelegate?.textFieldDidBeginEditing(textField)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 {
            return false
        }
        if range.location > 0 {
            return false
        }
        return true
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
}
