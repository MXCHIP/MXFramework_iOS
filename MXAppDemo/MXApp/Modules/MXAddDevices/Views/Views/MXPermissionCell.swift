//
//  MXPermissionCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/20.
//

import Foundation
import UIKit


public class MXPermissionCell: UITableViewCell {
    
    public var deviceInfo : [String : Any]!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        
        self.bgView.layer.cornerRadius = 16
//        self.bgView.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
//        self.bgView.layer.shadowOffset = CGSize.zero
//        self.bgView.layer.shadowOpacity = 1;
//        self.bgView.layer.shadowRadius = 8.0;
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(20).height(20).vCenter()
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).right(60).vCenter()
        
        self.bgView.addSubview(self.actionView)
        self.actionView.pin.right(20).width(20).height(20).vCenter()
        
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: [String : Any]) {
        self.iconView.text = nil
        self.nameLB.text = nil
        
        self.deviceInfo = info
        
        if let icon = deviceInfo["icon"] as? String {
            self.iconView.text = icon
        }
        
        if let name = deviceInfo["name"] as? String {
            self.nameLB.text = name
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        self.iconView.pin.left(20).width(20).height(20).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).right(60).vCenter()
        self.actionView.pin.right(20).width(20).height(20).vCenter()
    }
    
    public lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = UIColor.white;
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    public lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: .zero)
        _iconView.font = UIFont.mxIconFont(ofSize: 20)
        _iconView.textColor = MXAppConfig.MXColor.title;
        _iconView.textAlignment = .center
        return _iconView
    }()
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        return _nameLB
    }()
    
    public lazy var actionView : UILabel = {
        let _actionView = UILabel(frame: .zero)
        _actionView.font = UIFont.mxIconFont(ofSize: 20);
        _actionView.textColor = MXAppConfig.MXColor.disable;
        _actionView.textAlignment = .center
        _actionView.text = "\u{e6df}"
        return _actionView
    }()
}
