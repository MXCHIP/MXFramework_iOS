//
//  DiscoveryDeviceCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/24.
//

import Foundation
import SDWebImage
import UIKit

public class DiscoveryDeviceCell: UITableViewCell {
    public typealias MoreDeviceActionCallback = (_ item: MXProvisionDeviceInfo) -> ()
    public var moreActionCallback : MoreDeviceActionCallback!
    var deviceInfo : MXProvisionDeviceInfo!
    
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
        self.iconView.pin.left(16).top(20).width(40).height(40)
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).top(20).height(20).right(60)
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(4).height(16).right(60)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        self.actionBtn.isUserInteractionEnabled = false
        //self.actionBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        self.actionBtn.setTitle("\u{e715}", for: .normal)
        self.actionBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moreAction() {
        if self.deviceInfo.isSelected {
            self.deviceInfo.isSelected = false
        } else {
            self.deviceInfo.isSelected = true
        }
        self.refreshView(info: self.deviceInfo)
        self.moreActionCallback?(self.deviceInfo)
    }
    
    public func refreshView(info: MXProvisionDeviceInfo, isReplace: Bool? = nil) {
        self.iconView.image = nil
        self.nameLB.text = nil
        self.desLB.text = nil
        
        self.deviceInfo = info
        if let name = self.deviceInfo.productInfo?.name {
            self.nameLB.text = name
        }
        
        if let mac = self.deviceInfo.mac {
            self.desLB.text = mac
        } else if let dn = self.deviceInfo.deviceName {  //fog没有mac地址，只有DN
            self.desLB.text = dn
        }
        if let _ = isReplace {
            self.actionBtn.isHidden = true
        } else {
            self.actionBtn.isHidden = false
            if self.deviceInfo.isSelected {
                self.actionBtn.setTitle("\u{e6f3}", for: .normal)
                self.actionBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
            } else {
                self.actionBtn.setTitle("\u{e6fb}", for: .normal)
                self.actionBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
            }
        }
        if let productImage = info.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        self.iconView.pin.left(16).top(20).width(40).height(40)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).top(20).height(20).right(60)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(4).height(16).right(60)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = MXAppConfig.MXWhite.level3
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font =  UIFont.mxSystemFont(ofSize:16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        return _nameLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font =  UIFont.mxSystemFont(ofSize:12);
        _desLB.textColor = MXAppConfig.MXColor.secondaryText;
        return _desLB
    }()
    
    lazy public var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 20)
        _actionBtn.setTitle("\u{e715}", for: .normal)
        _actionBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        return _actionBtn
    }()
}
