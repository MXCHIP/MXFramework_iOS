//
//  MXColorTextFiled.swift
//  MXApp
//
//  Created by Khazan on 2021/9/13.
//

import Foundation
import UIKit

public protocol MXColorTextFiledDelegate {
    
    func editingChanged(_ textField: UITextField)
}

public class MXColorTextFiled: UITextField {
    
    @objc func editingChanged(sender: UITextField) -> Void {
        mxDelegate?.editingChanged(sender)
    }
    
    @objc func clearGestureAction(sender: UITapGestureRecognizer) -> Void {
        self.text = nil
        mxDelegate?.editingChanged(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        
        self.layer.cornerRadius = 25
        self.layer.borderWidth = 2
        self.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        
        self.textColor = MXAppConfig.MXColor.title
        self.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        self.tintColor = MXAppConfig.MXColor.theme
        
        self.addTarget(self, action: #selector(editingChanged(sender:)), for: UIControl.Event.editingChanged)
        
        self.delegate = self
        
        addRightView()
        
        didEndEditing()
    }
    
    
    func addRightView() -> Void {
        let rightView = UIView()
        rightView.pin.width(46).height(50)
        let deleteLabel = UILabel()
        deleteLabel.font = UIFont.mxIconFont(ofSize: 16)
        deleteLabel.text = "\u{e71d}"
        deleteLabel.textColor = MXAppConfig.MXColor.border.level1
        rightView.addSubview(deleteLabel)
        deleteLabel.pin.right(20).vCenter().width(16).height(16)
        self.rightView = rightView
        self.rightViewMode = .whileEditing
        
        let clearGesture = UITapGestureRecognizer(target: self, action: #selector(clearGestureAction(sender:)))
        rightView.isUserInteractionEnabled = true
        rightView.addGestureRecognizer(clearGesture)
    }
    
    func didBeginEditing() -> Void {
        self.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
    }
    
    func didEndEditing() -> Void {
        self.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
    }
    
    var mxDelegate: MXColorTextFiledDelegate?
    
}


extension MXColorTextFiled: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        didBeginEditing()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        didEndEditing()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        } else {
            return true
        }
    }
    
}
