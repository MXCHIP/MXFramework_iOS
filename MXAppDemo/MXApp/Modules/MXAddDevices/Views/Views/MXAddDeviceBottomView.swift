//
//  MXAddDeviceFooterView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/26.
//

import Foundation
import UIKit


open class MXAddDeviceBottomView: UIView {
    
    public typealias DidActionCallback = (_ index: Int) -> ()
    public var didActionCallback : DidActionCallback!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(self.leftBtn)
        self.leftBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.addSubview(self.rightBtn)
        self.rightBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        
        self.leftBtn.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        self.rightBtn.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
    }
    
    @objc func leftAction() {
        self.didActionCallback?(0)
    }
    
    @objc func rightAction() {
        self.didActionCallback?(1)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.leftBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.rightBtn.pin.width(136).height(44).bottom(24).hCenter(74)
    }
    
    public lazy var leftBtn : UIButton = {
        let _leftBtn = UIButton(type: .custom)
        _leftBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        _leftBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_resume_add"), for: .normal)
        _leftBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        _leftBtn.backgroundColor = .white
        _leftBtn.layer.borderWidth = 1
        _leftBtn.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
        _leftBtn.layer.cornerRadius = 22
        return _leftBtn
    }()
    
    public lazy var rightBtn : UIButton = {
        let _rightBtn = UIButton(type: .custom)
        _rightBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        _rightBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_next"), for: .normal)
        _rightBtn.setTitleColor(.white, for: .normal)
        _rightBtn.backgroundColor = MXAppConfig.MXColor.theme
        _rightBtn.layer.cornerRadius = 22
        return _rightBtn
    }()
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
