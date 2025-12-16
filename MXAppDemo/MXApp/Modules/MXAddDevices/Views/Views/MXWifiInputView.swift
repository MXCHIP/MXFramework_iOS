//
//  MXWifiInputView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/26.
//

import Foundation
import UIKit

open class MXWifiInputView: UIView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        self.layer.cornerRadius = self.frame.height/2.0
        
        self.addSubview(self.iconView)
        self.iconView.pin.left(24).width(20).height(20).vCenter()
        
        self.addSubview(self.actionBtn)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(10).left(of: self.actionBtn).marginRight(0).top().bottom()
    }
    
    public override func layoutSubviews() {
        self.iconView.pin.left(24).width(20).height(20).vCenter()
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(10).left(of: self.actionBtn).marginRight(0).top().bottom()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: .zero)
        _iconView.font = UIFont.mxIconFont(ofSize: 20);
        _iconView.textColor = MXAppConfig.MXColor.primaryText;
        _iconView.textAlignment = .center
        return _iconView
    }()
    
    public lazy var nameLB : UITextField = {
        let _nameLB = UITextField(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    public lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 20)
        _actionBtn.setTitle(nil, for: .normal)
        _actionBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        _actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        return _actionBtn
    }()
    
    @objc func didAction() {
        self.didActionCallback?()
    }
    
}
