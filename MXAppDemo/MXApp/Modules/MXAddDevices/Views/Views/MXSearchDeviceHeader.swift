//
//  MXSearchDeviceHeader.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/24.
//

import Foundation
import UIKit

public class MXSearchDeviceHeader: UIView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.left(20).right(20).top(30).height(20)
        
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).height(16).width(200).hCenter()
    }
    
    override public func layoutSubviews() {
        self.nameLB.pin.left(20).right(20).top(30).height(20)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).height(16).sizeToFit(.height).hCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    public lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.mxIconFont(ofSize: 12)
        _desLB.textColor = MXAppConfig.MXColor.theme;
        _desLB.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionTap))
        _desLB.addGestureRecognizer(tap)
        
        return _desLB
    }()
    
    @objc func actionTap() {
        self.didActionCallback?()
    }
    
}
