//
//  MXCategoryCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/23.
//

import Foundation
import UIKit

class MXCategoryCell: UITableViewCell {
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.lineView.isHidden = false
                self.bgView.backgroundColor = MXAppConfig.MXWhite.level1
                self.nameLB.textColor = MXAppConfig.MXColor.theme
            } else {
                self.lineView.isHidden = true
                self.bgView.backgroundColor = .clear
                self.nameLB.textColor = MXAppConfig.MXColor.primaryText
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.lineView)
        
        self.bgView.addSubview(self.nameLB)
        
        self.lineView.isHidden = !self.mxSelected
        if self.mxSelected {
            self.bgView.backgroundColor = MXAppConfig.MXWhite.level1
            self.nameLB.textColor = MXAppConfig.MXColor.theme
        } else {
            self.bgView.backgroundColor = .clear
            self.nameLB.textColor = MXAppConfig.MXColor.primaryText
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.lineView.pin.left(4).top(4).bottom(4).width(2)
        self.nameLB.pin.left(8).right(8).top(8).bottom(8)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = UIColor.clear;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 14);
        _nameLB.textColor = MXAppConfig.MXColor.primaryText;
        _nameLB.textAlignment = .center
        _nameLB.numberOfLines = 0
        _nameLB.adjustsFontSizeToFitWidth = true
        _nameLB.minimumScaleFactor = 0.5
        return _nameLB
    }()
    
    lazy var lineView : UIView = {
        let _view = UIView(frame: .zero)
        _view.backgroundColor = MXAppConfig.MXColor.theme
        return _view
    }()
}
