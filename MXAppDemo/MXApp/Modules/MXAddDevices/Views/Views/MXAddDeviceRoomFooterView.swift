//
//  MXAddDeviceRoomFooterView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/30.
//

import Foundation
import UIKit

public typealias MXDeviceInfoChangeCallback = (_ info: MXDeviceInfo) -> ()

class MXAddDeviceRoomFooterView: UICollectionReusableView {
    
    var infoChangeCallback : MXDeviceInfoChangeCallback?
    
    var info : MXDeviceInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.left(20).right(70).height(20).vCenter(-4)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter(-4)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .valueChanged)
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.info = info
        let btnStr = (self.info?.isFavorite ?? false) ? "\u{e693}" : "\u{e695}"
        self.actionBtn.setTitle(btnStr, for: .normal)
    }
    
    @objc func didAction(sender: UIButton) {
        var isFavorite: Bool = true
        if sender.title(for: .normal) == "\u{e693}" {
            isFavorite = false
            sender.setTitle("\u{e695}", for: .normal)
        } else {
            isFavorite = true
            sender.setTitle("\u{e693}", for: .normal)
        }
        self.info?.isFavorite = isFavorite
        if let newInfo = self.info {
            self.infoChangeCallback?(newInfo)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.nameLab.pin.left(20).right(70).height(20).vCenter(-4)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter(-4)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height-10))
        _bgView.backgroundColor = .clear;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLab.textColor = MXAppConfig.MXColor.title;
        _nameLab.textAlignment = .left
        _nameLab.text = MXAppConfig.mxLocalized(key:"mx_set_favorite")
        return _nameLab
    }()
    
    public lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        _actionBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 20)
        _actionBtn.setTitle("\u{e693}", for: .normal)
        _actionBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        _actionBtn.backgroundColor = .clear
        _actionBtn.addTarget(self, action: #selector(didAction(sender:)), for: .touchUpInside)
        return _actionBtn
    }()
}
