//
//  CodeView.swift
//  MXApp
//
//  Created by Khazan on 2021/6/17.
//

import Foundation
import UIKit
import PinLayout

public protocol CodeViewDelegate {
    
    // 编辑验证码
    func editingCode(code: String) -> Void
    
    // 验证验证码
    func finished(code: String) -> Void
}

public class CodeView: UIView {
    
    func begainEditing() -> Void {
        guard let first = self.subviews.first else { return }
        first.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        if first.isFirstResponder {
           return
        }
        first.becomeFirstResponder()
    }
    
    var delegate: CodeViewDelegate?
    
    var contentBGColor: UIColor = UIColor(hex: "F4F7F8")
    
    let margin: CGFloat = 10.0
    
    var count = 0

    var ifDeletedLast = false

    var ifEdited = false
    
    func createElement(count: Int) -> Void {
        self.count = count
        
        for _ in 0..<count {
            let textField = CodeTextField()
            self.addSubview(textField)
            textField.codeDelegate = self
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let itemWidth:CGFloat = 40.0

        for (index, view) in self.subviews.enumerated() {
            view.pin.width(itemWidth).top().bottom()
            if index == 0 {
                view.pin.left()
            } else {
                let theLast = self.subviews[index-1]
                view.pin.after(of: theLast).marginLeft(margin)
            }
        }
    }
    
    func code() -> String {
        var code = ""
        for view in self.subviews {
            if let textField = view as? UITextField {
                code.append(textField.text ?? "")
            }
        }
        return code
    }
    
    init(with elementCount: Int) {
        super.init(frame: .zero)
        createElement(count: elementCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension CodeView: CodeTextFieldDelegate {
    
    public func textFieldDeleteBackward(_ current: UITextField) {
        
        textFieldBackToTheLast(current)
    }
    
    public func textFieldDidBeginEditing(_ current: UITextField) {

        if ifEdited {
            ifEdited = false
            return
        }
        
        let code = self.code()
        if code.count == 0 {
            guard let first = self.subviews.first else { return }
            first.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
            if first.isFirstResponder {
               return
            }
            current.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                first.becomeFirstResponder()
            }
        } else if code.count == count {
            guard let last = self.subviews.last else { return }
            last.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
            if last.isFirstResponder {
               return
            }
            current.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                last.becomeFirstResponder()
            }
        } else {
            for (index, view) in self.subviews.enumerated() {
                if index == code.count {
                    view.becomeFirstResponder()
                    view.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
                }
            }
        }
    }
    
    public func textFieldEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        self.delegate?.editingCode(code: self.code())
        
        if text.count > 0 {
            textFieldSkipToTheNext(textField)
        } else {
            guard let index = self.subviews.firstIndex(of: textField) else { return }
            if index == count-1 {
                ifDeletedLast = true
            }
        }
    }
    
    
    // 下一个
    func textFieldSkipToTheNext(_ current: UITextField) {
        guard let index = self.subviews.firstIndex(of: current) else { return }
        current.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        
        if index < self.subviews.count-1 {
            ifEdited = true
            guard let theNext = self.subviews[index+1] as? UITextField else { return }
            if theNext.isFirstResponder {
               return
            }
            theNext.becomeFirstResponder()
            theNext.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        } else {
            ifEdited = false
            current.endEditing(true)
            self.delegate?.finished(code: self.code())
        }
        
    }
    
    // 上一个
    func textFieldBackToTheLast(_ current: UITextField) {
        guard let index = self.subviews.firstIndex(of: current) else { return }
        if index == 0 {
            return
        }
        if index-1 >= self.subviews.count {
            return
        }

        if ifDeletedLast {
            ifDeletedLast = false
            return
        }
        
        ifEdited = true

        guard let theLast = self.subviews[index-1] as? UITextField else { return }
    
        if theLast.isFirstResponder {
           return
        }

        current.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        theLast.becomeFirstResponder()
        theLast.text = ""
        theLast.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        
    }

        
}
