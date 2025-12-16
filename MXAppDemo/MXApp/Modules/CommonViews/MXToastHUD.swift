//
//  MXToastHUD.swift
//  MXApp
//
//  Created by 华峰 on 2021/9/9.
//

import Foundation
import PinLayout
import UIKit
import Lottie

open class MXToastHUD: NSObject {
    static public func show() {
        DispatchQueue.main.async {
            MXProgressHUD.shard.show()
        }
    }
    
    static public func dismiss(time: TimeInterval = 0) {
        DispatchQueue.main.async {
            if time == 0 {
                MXProgressHUD.shard.dismiss()
            } else {
                MXProgressHUD.shard.delayDissmiss(time: time)
            }
        }
    }
    
    static public func showInfo(status: String?, time: TimeInterval = 2) {
        MXProgressHUD.shard.showInfo(status: status, time: time)
    }
    
    static public func showError(status: String?) {
        MXProgressHUD.shard.showInfo(status: status)
    }
}

open class MXProgressHUD: UIView {
    public static var shard = MXProgressHUD(frame: CGRect(x: 0, y: 0, width: MXAppConfig.mxScreenWidth, height: MXAppConfig.mxScreenHeight))
    public var mxAnimation : LottieAnimationView?
    let hudView: UIView = UIView(frame:.zero)
    let statusLabel: UILabel = UILabel(frame: .zero)
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.mxAnimation = LottieAnimationView(name: "loading_Light")
        self.mxAnimation?.contentMode = .scaleAspectFit
        self.mxAnimation?.isUserInteractionEnabled = false
        self.mxAnimation?.loopMode = .loop
        self.addSubview(self.mxAnimation!)
        self.mxAnimation?.pin.width(240).height(240).center()
        self.mxAnimation?.isHidden = true
        
        self.hudView.backgroundColor = UIColor(with: "000000", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 1)
        self.hudView.layer.masksToBounds = true
        self.hudView.layer.cornerRadius = 12
        self.addSubview(self.hudView)
        self.hudView.pin.width(224).height(324).center()
        
        self.statusLabel.font = UIFont.mxSystemFont(ofSize: 12)
        self.statusLabel.textColor = UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "8C8C8C", darkModeAlpha: 1)
        self.statusLabel.backgroundColor = .clear
        self.statusLabel.textAlignment = .center;
        self.statusLabel.numberOfLines = 0;
        self.hudView.addSubview(self.statusLabel)
        self.statusLabel.pin.width(200).height(300).center()
        self.hudView.isHidden = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateAnimation() {
        self.mxAnimation?.stop()
        var newName = "loading_Light"
        if #available(iOS 13, *), UITraitCollection.current.userInterfaceStyle == .dark {
            newName = "loading_Dark"
        }
        self.mxAnimation?.animation = LottieAnimation.named(newName, bundle: Bundle.main, subdirectory: nil, animationCache: LottieAnimationCache.shared)
        self.mxAnimation?.play()
    }
    
    func show() {
        self.localWorkItem?.cancel()
        self.localWorkItem = nil
        self.hudView.isHidden = true
        self.mxAnimation?.isHidden = false
        self.mxAnimation?.play()
        if self.superview == nil {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }
    }
    
    func dismiss() {
        if self.localWorkItem != nil {
            return
        }
        self.mxAnimation?.stop()
        self.mxAnimation?.isHidden = true
        self.hudView.isHidden = true
        self.removeFromSuperview()
    }
    
    func showInfo(status: String?, time: TimeInterval = 2) {
        guard let msg = status, msg.count > 0 else {
            self.dismiss()
            return
        }
        self.localWorkItem?.cancel()
        self.localWorkItem = nil
        self.mxAnimation?.stop()
        self.mxAnimation?.isHidden = true
        self.hudView.isHidden = false
        self.statusLabel.text = msg
        let msgSize = msg.getStringSize(font: UIFont.mxSystemFont(ofSize: 12), viewSize: CGSize(width: 200, height: 300))
        self.statusLabel.pin.width(msgSize.width).height(msgSize.height)
        self.hudView.pin.wrapContent(padding: PEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)).center()
        if self.superview == nil {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }
        self.delayDissmiss(time: time)
        
    }
    
    // 初始化延时任务
    var localWorkItem : DispatchWorkItem?

    func delayDissmiss(time: TimeInterval = 2) {
        //取消延时任务
        self.localWorkItem?.cancel()
        self.localWorkItem = nil
        self.localWorkItem = DispatchWorkItem { [weak self] in
            self?.localWorkItem?.cancel()
            self?.localWorkItem = nil
            self?.dismiss()
        }
        // 添加延时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: self.localWorkItem!)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateAnimation()
    }
}

class MXUploadHUD: UIView {
    public static var shard = MXUploadHUD(frame: CGRect(x: 0, y: 0, width: MXAppConfig.mxScreenWidth, height: MXAppConfig.mxScreenHeight))
    let hudView: UIView = UIView(frame:.zero)
    let statusLabel: UILabel = UILabel(frame: .zero)
    let infoLabel: UILabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.4)
        
        self.hudView.backgroundColor = MXAppConfig.MXWhite.level4
        self.hudView.layer.masksToBounds = true
        self.hudView.layer.cornerRadius = 12
        self.addSubview(self.hudView)
        self.hudView.pin.width(120).height(120).center()
        
        self.statusLabel.font = UIFont.mxIconFont(ofSize: 32)
        self.statusLabel.textColor = MXAppConfig.MXColor.theme
        self.statusLabel.backgroundColor = .clear
        self.statusLabel.textAlignment = .center;
        self.hudView.addSubview(self.statusLabel)
        self.statusLabel.pin.width(32).height(32).top(25).hCenter()
        
        self.infoLabel.font = UIFont.mxSystemFont(ofSize: 16)
        self.infoLabel.textColor = MXAppConfig.MXColor.primaryText
        self.infoLabel.backgroundColor = .clear
        self.infoLabel.textAlignment = .center;
        self.infoLabel.numberOfLines = 0;
        self.hudView.addSubview(self.infoLabel)
        self.infoLabel.pin.left().right().below(of: self.statusLabel).marginTop(16).height(20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(info: String, isLoading: Bool = true) {
        self.statusLabel.layer.removeAllAnimations()
        self.statusLabel.text = isLoading ? "\u{e70d}" : "\u{e6f4}"
        self.infoLabel.text = info
        if isLoading {
            let animatiion = CABasicAnimation(keyPath: "transform.rotation.z")
            animatiion.fromValue = 0.0
            animatiion.toValue = 2*Double.pi
            animatiion.repeatCount = 9999
            animatiion.duration = 1
            animatiion.isRemovedOnCompletion = false
            self.statusLabel.layer.add(animatiion, forKey: "LoadingAnimation")
        }
        if self.superview == nil {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }
    }
    
    func dismiss() {
        self.statusLabel.layer.removeAllAnimations()
        self.removeFromSuperview()
    }
}
