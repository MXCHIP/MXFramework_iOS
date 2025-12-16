//
//  MXAddDeviceHeaderView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/25.
//

import Foundation
import UIKit

public class MXAddDeviceHeaderView: UIView {
    
    public typealias DidMoreCallback = () -> ()
    public var didMoreCallback : DidMoreCallback!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.titleLB)
        self.titleLB.pin.left(16).top(26).right(16).height(24)
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.titleLB).marginTop(16).left(16).right(16).bottom()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left(16).top(26).right(16).height(24)
        self.desLB.pin.below(of: self.titleLB).marginTop(16).left(16).right(16).bottom()
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.zero)
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .left
        _titleLB.font = UIFont.mxSystemFont(ofSize: 24, weight: .medium)
        _titleLB.textColor = MXAppConfig.MXColor.title
        _titleLB.text = MXAppConfig.mxLocalized(key:"mx_add_device_title")
        
        return _titleLB
    }()
    
    lazy public var desLB : UITextView = {
        let _desLB = UITextView(frame: .zero)
        _desLB.font = UIFont.mxSystemFont(ofSize:16);
        _desLB.textColor = MXAppConfig.MXColor.secondaryText
        _desLB.textAlignment = .left
        _desLB.text = MXAppConfig.mxLocalized(key:"mx_add_device_des")
        _desLB.isUserInteractionEnabled = false
        
        return _desLB
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
