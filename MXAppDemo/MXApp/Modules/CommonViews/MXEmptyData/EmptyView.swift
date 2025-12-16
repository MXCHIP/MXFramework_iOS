//
//  MXEmptyDataView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/5.
//

import Foundation
import UIKit

open class EmptyView: UIView {
    
    public var firstReloadHidden = false
    public var centerAlignment: Bool  = true
}

open class MXActionEmptyView: EmptyView {
    
    public typealias DidClickActionCallback = () -> ()
    public var didClickActionCallback : DidClickActionCallback?
    
    public var imageView : UIImageView!
    public var actionBtn : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.imageView = UIImageView(image: UIImage(named: "mx_view_no_device"))
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        self.imageView.pin.width(164).height(160).vCenter(-40).hCenter()
        
        self.actionBtn = UIButton.init(type: .custom)
        self.actionBtn.backgroundColor = MXAppConfig.MXColor.theme
        self.actionBtn.titleLabel?.font =  UIFont.mxSystemFont(ofSize:17)
        self.actionBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_add_device"), for: .normal)
        self.actionBtn.setTitleColor(UIColor.white, for: .normal)
        self.actionBtn.layer.cornerRadius = 24.0
        self.actionBtn.layer.masksToBounds = true
        self.addSubview(self.actionBtn)
        self.actionBtn.pin.below(of: self.imageView, aligned: .center).marginTop(32).width(116).height(48)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.actionBtn.isHidden {
            self.imageView.pin.width(164).height(160).center()
        } else {
            self.imageView.pin.width(164).height(160).vCenter(-40).hCenter()
        }
        self.actionBtn.pin.below(of: self.imageView, aligned: .center).marginTop(32).height(48).minWidth(116).maxWidth(200).hCenter().sizeToFit(.height)
    }
    
    @objc func didAction() {
        self.didClickActionCallback?()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class MXTitleEmptyView: EmptyView {
    
    public var imageView : UIImageView!
    public var titleLB : UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.imageView = UIImageView(image: UIImage(named: "emptyBG"))
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
        
        self.titleLB = UILabel(frame: CGRect(x: 40, y: 0, width: self.frame.size.width-80, height: 20))
        self.titleLB.backgroundColor = .clear
        self.titleLB.numberOfLines = 0
        self.titleLB.font =  UIFont.mxSystemFont(ofSize:16)
        self.titleLB.textAlignment = .center
        self.titleLB.textColor = MXAppConfig.MXColor.secondaryText
        self.titleLB.text = MXAppConfig.mxLocalized(key:"mx_no_data")
        self.addSubview(self.titleLB)
        self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).height(20)
        
        
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.titleLB.isHidden {
            self.imageView.pin.width(68).height(68).center()
        } else {
            self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
        }
        self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).minHeight(20).maxHeight(60).sizeToFit(.width)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class MXEmptyView: EmptyView {
    
    public var imageView : UIImageView!
    public var titleLB : UILabel!
    public var actionBtn : UIButton!
    public typealias DidClickActionCallback = () -> ()
    public var didClickActionCallback : DidClickActionCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.imageView = UIImageView(image: UIImage(named: "emptyBG"))
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.contentMode = .scaleAspectFit
        self.addSubview(self.imageView)
        self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
        
        self.titleLB = UILabel(frame: CGRect(x: 40, y: 0, width: self.frame.size.width-80, height: 20))
        self.titleLB.backgroundColor = .clear
        self.titleLB.numberOfLines = 0
        self.titleLB.font =  UIFont.mxSystemFont(ofSize:16)
        self.titleLB.textAlignment = .center
        self.titleLB.textColor = MXAppConfig.MXColor.secondaryText
        self.titleLB.text = MXAppConfig.mxLocalized(key:"mx_no_data")
        self.addSubview(self.titleLB)
        self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).height(20)
        
        self.actionBtn = UIButton.init(type: .custom)
        self.actionBtn.backgroundColor = MXAppConfig.MXColor.theme
        self.actionBtn.titleLabel?.font =  UIFont.mxSystemFont(ofSize:17)
        self.actionBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_add_device"), for: .normal)
        self.actionBtn.setTitleColor(UIColor.white, for: .normal)
        self.actionBtn.layer.cornerRadius = 24.0
        self.actionBtn.layer.masksToBounds = true
        self.addSubview(self.actionBtn)
        self.actionBtn.pin.below(of: self.titleLB, aligned: .center).marginTop(24).width(116).height(48)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.titleLB.isHidden {
            self.imageView.pin.width(68).height(68).center()
            self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).minHeight(20).maxHeight(60).sizeToFit(.width)
            self.actionBtn.pin.below(of: self.imageView, aligned: .center).marginTop(24).height(48).minWidth(116).maxWidth(200).hCenter().sizeToFit(.height)
        } else {
            self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
            self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).minHeight(20).maxHeight(60).sizeToFit(.width)
            self.actionBtn.pin.below(of: self.titleLB, aligned: .center).marginTop(24).height(48).minWidth(116).maxWidth(200).hCenter().sizeToFit(.height)
        }
    }
    
    @objc func didAction() {
        self.didClickActionCallback?()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
