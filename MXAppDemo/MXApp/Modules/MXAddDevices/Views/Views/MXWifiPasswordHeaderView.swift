//
//  MXWifiPasswordHeaderView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/26.
//

import Foundation
import UIKit

open class MXWifiPasswordHeaderView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.left(24).right(24).top(24).height(24)
        
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(24).height(20)
    }
    
    open override func layoutSubviews() {
        self.nameLB.pin.left(24).right(24).top(24).height(24)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(24).height(20)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 24, weight: .medium)
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .left
        _nameLB.text = MXAppConfig.mxLocalized(key:"mx_connect_wifi")
        return _nameLB
    }()
    
    public lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.mxSystemFont(ofSize: 16);
        _desLB.textColor = MXAppConfig.MXColor.secondaryText;
        _desLB.textAlignment = .left
        
        let valueStr = NSMutableAttributedString()
        let iconStr = NSAttributedString(string: "\u{e70c}", attributes: [.font: UIFont.mxIconFont(ofSize: 16),.foregroundColor:MXAppConfig.MXColor.secondaryText])
        valueStr.append(iconStr)
        let desStr = NSAttributedString(string: MXAppConfig.mxLocalized(key:"mx_provision_wifi_limit_tips"), attributes: [.font: UIFont.mxSystemFont(ofSize: 16),.foregroundColor:MXAppConfig.MXColor.secondaryText])
        valueStr.append(desStr)
        _desLB.attributedText = valueStr
        return _desLB
    }()
    
}
