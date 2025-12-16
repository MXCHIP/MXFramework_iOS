//
//  MXProductCollectionHeader.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/23.
//

import Foundation
import UIKit

class MXProductCollectionHeader: UICollectionReusableView {
    
    public typealias DidMoreCallback = () -> ()
    public var didMoreCallback : DidMoreCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLB)
        self.titleLB.pin.top().bottom().width(60).hCenter()
        self.addSubview(self.leftLine)
        self.leftLine.pin.left(15).left(of: self.titleLB).marginRight(5).height(1).vCenter()
        self.addSubview(self.rightLine)
        self.rightLine.pin.right(15).right(of: self.titleLB).marginLeft(5).height(1).vCenter()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.sizeToFit().center()
        self.leftLine.pin.left(15).left(of: self.titleLB).marginRight(5).height(1).vCenter()
        self.rightLine.pin.right(15).right(of: self.titleLB).marginLeft(5).height(1).vCenter()
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.zero)
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .center
        _titleLB.font = UIFont.mxSystemFont(ofSize: 14)
        _titleLB.textColor = MXAppConfig.MXColor.secondaryText
        
        return _titleLB
    }()
    
    lazy public var leftLine : UIView = {
        let _leftLine = UIView(frame: CGRect.zero)
        _leftLine.backgroundColor = MXAppConfig.MXColor.border.level1
        return _leftLine
    }()
    
    lazy public var rightLine : UIView = {
        let _rightLine = UIView(frame: CGRect.zero)
        _rightLine.backgroundColor = MXAppConfig.MXColor.border.level1
        
        return _rightLine
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
