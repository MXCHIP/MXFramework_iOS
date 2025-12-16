//
//  MXAddDeviceSelectRoomCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/30.
//

import Foundation
import UIKit

class MXAddDeviceSelectRoomCell: UICollectionViewCell {
    
    public var mxSelected: Bool = false {
        didSet {
            if self.mxSelected {
                self.bgView.layer.borderColor = MXAppConfig.MXColor.theme.cgColor
                self.nameLB.textColor = MXAppConfig.MXColor.theme
            } else {
                self.bgView.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
                self.nameLB.textColor = MXAppConfig.MXColor.primaryText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.all()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.nameLB.pin.all()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.zero)
        _bgView.backgroundColor = MXAppConfig.MXWhite.level3
        _bgView.layer.cornerRadius = 4.0
        _bgView.clipsToBounds = true
        _bgView.layer.borderWidth = 1.0
        _bgView.layer.borderColor = MXAppConfig.MXColor.border.level1.cgColor
        return _bgView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxIconFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.primaryText;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
}
