//
//  UIViewController+MXCHIP.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/23.
//

import Foundation
import UIKit
@_exported import MXURLRouter

open class MXBaseViewController: UIViewController {
    
    public typealias MXPageCallback = (_ info : [String : Any]) -> ()
    public var pageCallback : MXPageCallback?
    
    lazy public var mxNavigationBar:MXNavigationBar = {
        let bar = MXNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: MXAppConfig.statusBarH + MXAppConfig.navBarH))
        return bar
    }()
    
    public var contentView : UIView = UIView()
    public var hideMXNavigationBar : Bool = false {
        didSet {
            if self.hideMXNavigationBar {
                self.mxNavigationBar.isHidden = true
                self.contentView.pin.all()
            } else {
                self.mxNavigationBar.isHidden = false
                self.contentView.pin.left().top(mxNavHight()).right().bottom()
            }
        }
    }
    
    public func mxNavHight() -> CGFloat {
        if self.mxNavigationBar.navStyle == .swiftUI {
            return MXAppConfig.statusBarH + 72
        }
        return MXAppConfig.statusBarH + MXAppConfig.navBarH
    }
    
    public override var title: String? {
        didSet {
            self.mxNavigationBar.titleLB.text = title
        }
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        //语言改变
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageChange), name: Notification.Name("MXNotificationAppLanguageChange"), object: nil)
        
        self.mxNavigationBar.setupViews()
        
        self.mxNavigationBar.backItem.addTarget(self, action: #selector(gotoBack), for: .touchUpInside)
        self.mxNavigationBar.leftView.addSubview(self.mxNavigationBar.backItem)
        self.mxNavigationBar.backItem.pin.left().top(0).width(44).height(44)
        
        self.contentView.backgroundColor = UIColor.clear
        self.view.addSubview(self.contentView)
        
        if self.hideMXNavigationBar {
            self.contentView.pin.all()
        } else {
            self.contentView.pin.left().top(mxNavHight()).right().bottom()
        }
        
        self.view.addSubview(self.mxNavigationBar)
        self.mxNavigationBar.isHidden = self.hideMXNavigationBar
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewWillLayoutSubviews() {
        self.mxNavigationBar.pin.left().right().top().height(mxNavHight())
        if !self.hideMXNavigationBar {
            self.mxNavigationBar.layoutSubviews()
            self.contentView.pin.left().top(mxNavHight()).right().bottom()
        } else {
            self.contentView.pin.all()
        }
    }
    
    open func hideBackItem() {
        for v in self.mxNavigationBar.leftView.subviews {
            v.removeFromSuperview()
        }
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    //返回
    @objc open func gotoBack() {
        self.navigationController?.popViewController(animated: true)
    }
    //语言改变
    @objc open func appLanguageChange() {
        
    }
}

public enum MXNavStyle {
    case swiftUI
    case normal
}

open class MXNavigationBar : UIView {
    public var navStyle: MXNavStyle = .normal {
        didSet {
            if self.navStyle == .swiftUI {
                self.titleLB.font = UIFont.mxSystemFont(ofSize: 24, weight: .medium)
                self.titleLB.textAlignment = .left
                //self.layer.shadowColor = UIColor.clear.cgColor
            } else {
                self.titleLB.font = UIFont.mxSystemFont(ofSize: 18, weight: .medium)
                self.titleLB.textAlignment = .center
                
                //self.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
            }
            self.layoutSubviews()
        }
    }
    
    lazy public var itemView : UIView = {
        let _itemView = UIView(frame: CGRect.zero)
        _itemView.backgroundColor = UIColor.clear
        return _itemView
    }()
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.zero)
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.font = UIFont.mxSystemFont(ofSize: 18, weight: .medium)
        _titleLB.textAlignment = .center
        _titleLB.textColor = MXAppConfig.MXColor.title
        _titleLB.isUserInteractionEnabled = true
        return _titleLB
    }()
    
    lazy public var leftView : UIView = {
        let _leftView = UIView(frame: CGRect.zero)
        _leftView.backgroundColor = UIColor.clear
        return _leftView
    }()
    
    lazy public var rightView : UIView = {
        let _rightView = UIView(frame: CGRect.zero)
        _rightView.backgroundColor = UIColor.clear
        return _rightView
    }()
    
    lazy public var backItem: UIButton = {
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        leftBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 16)
        leftBtn.titleLabel?.textAlignment = .left
        leftBtn.setTitleColor(MXAppConfig.MXColor.title, for: .normal)
        leftBtn.setTitle("\u{e6de}", for: .normal)
        return leftBtn
    }()
    
    lazy public var rightItem: UIButton = {
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        rightBtn.titleLabel?.textAlignment = .right
        rightBtn.setTitleColor(MXAppConfig.MXColor.primaryText, for: .normal)
        return rightBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.itemView)
        self.itemView.pin.left().top(MXAppConfig.statusBarH).right().bottom()
        
        self.itemView.addSubview(self.leftView)
        self.leftView.pin.top().bottom().left(10).width(50)
        
        self.itemView.addSubview(self.rightView)
        self.rightView.pin.top().bottom().right(10).width(50)
        
        self.itemView.addSubview(self.titleLB)
        self.titleLB.pin.top().bottom().right(60).left(60)
        
//        self.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
//        self.layer.shadowOffset = CGSize.zero
//        self.layer.shadowOpacity = 1
//        self.layer.shadowRadius = 8
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.itemView.pin.left().top(MXAppConfig.statusBarH).right().bottom()
        var left_x: CGFloat = 0
        for v in self.leftView.subviews {
            v.pin.left(left_x).maxWidth(80).height(MXAppConfig.navBarH).sizeToFit(.height)
            left_x = left_x + v.frame.size.width + 10
        }
        self.leftView.pin.wrapContent(.horizontally, padding: 20).left()
        var right_x: CGFloat = 0
        for v in self.rightView.subviews {
            v.pin.right(right_x).maxWidth(180).height(MXAppConfig.navBarH).sizeToFit(.height)
            right_x = right_x + v.frame.size.width + 10
        }
        self.rightView.pin.wrapContent(.horizontally, padding: 20).right()
        var  offset_x = max(self.leftView.frame.size.width, self.rightView.frame.size.width)
        if offset_x < 60 {
            offset_x = 60
        }
        if self.navStyle == .swiftUI {
            self.itemView.pin.left().top(MXAppConfig.statusBarH + 14).right().bottom(14)
            self.titleLB.pin.top().bottom().right(right_x + 10).left(left_x + 10)
        } else {
            self.titleLB.pin.top().bottom().right(offset_x).left(offset_x)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.titleLB.text = nil
        for v in self.titleLB.subviews {
            v.removeFromSuperview()
        }
        for v in self.leftView.subviews {
            v.removeFromSuperview()
        }
        self.leftView.pin.top().bottom().left(10).width(50)
        for v in self.rightView.subviews {
            v.removeFromSuperview()
        }
        self.rightView.pin.top().bottom().right(10).width(50)
        
        self.layoutSubviews()
    }
}
