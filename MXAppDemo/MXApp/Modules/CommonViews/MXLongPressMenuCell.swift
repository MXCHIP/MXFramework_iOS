//
//  MXLongPressMenuCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/9/27.
//

import Foundation
import UIKit

open class MXLongPressMenuCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ isOn: Bool) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    public typealias CopyActionCallback = () -> ()
    public var copyActionCallback : CopyActionCallback!
    
    public var canShowMenu :Bool = false
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        // 长按手势最小触发时间
        longPressGes.minimumPressDuration = 1
        // 需要点击的次数
        //        longPressGes.numberOfTapsRequired = 1
        // 长按手势需要的同时敲击触碰数（手指数）
        longPressGes.numberOfTouchesRequired = 1
        // 长按有效移动范围（从点击开始，长按移动的允许范围 单位 px
        longPressGes.allowableMovement = 15

        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longPressGes)
        
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(16).width(40).height(40).vCenter()
        
        self.backgroundColor = MXAppConfig.MXWhite.level3
        self.contentView.backgroundColor = .clear
    }
    
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
    
    @objc func didAction(sender: UIButton) {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        var isFavorite: Bool = true
        if sender.title(for: .normal) == "\u{e693}" {
            isFavorite = false
            sender.setTitle("\u{e695}", for: .normal)
        } else {
            isFavorite = true
            sender.setTitle("\u{e693}", for: .normal)
        }
        self.didActionCallback?(isFavorite)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.actionBtn.pin.right(16).width(40).height(40).vCenter()
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if !self.canShowMenu {
            return
        }
        
        if sender.state == .began {
            self.copyActionCallback?()
        }
        
//        guard sender.state == .began, let senderView = sender.view, let superView = sender.view?.superview else {
//            return
//        }
//        senderView.becomeFirstResponder()
//        let menuController = UIMenuController.shared
//        let item1 = UIMenuItem(title: MXAppConfiguration.mxLocalized(key:"mx_copy"), action: #selector(nameCopy))
//        menuController.menuItems = [item1]
//        if #available(iOS 13.0, *) {
//            menuController.isMenuVisible = true
//            menuController.showMenu(from: superView, rect: senderView.frame)
//        } else {
//            menuController.setTargetRect(senderView.frame, in: superView)
//            menuController.setMenuVisible(true, animated: true)
//        }
    }
    
    @objc func nameCopy() {
        self.copyActionCallback?()
        
        let menuController = UIMenuController.shared
        menuController.isMenuVisible = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func becomeFirstResponder() -> Bool {
        return true
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(nameCopy) {
            return true
        }
        return false
    }
}

class MXSwitchCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ isOn: Bool) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        
        self.backgroundColor = MXAppConfig.MXWhite.level3
        self.contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var actionBtn : UISwitch = {
        let _actionBtn = UISwitch(frame: CGRect(x: 0, y: 0, width: 44, height: 26))
        _actionBtn.onTintColor = MXAppConfig.MXColor.theme
        _actionBtn.tintColor = MXAppConfig.MXColor.disable
        _actionBtn.addTarget(self, action: #selector(didAction), for: .valueChanged)
        return _actionBtn
    }()
    
    @objc func didAction() {
        self.didActionCallback?(self.actionBtn.isOn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
}
