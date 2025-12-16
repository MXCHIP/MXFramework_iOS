//
//  MXAutoAnimationView.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/19.
//

import Foundation
import UIKit

public class MXAutoAnimationView: UIView {
    private let radarAnimation = "radarAnimation"
    private var animationLayer: CALayer?
    private var animationGroup: CAAnimationGroup?
    private var imageview : UIImageView!    //定义图片view
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        imageview = UIImageView(frame: CGRect.zero)
        imageview.contentMode = .scaleAspectFit
        self.addSubview(imageview) //把图片放到view中去
        imageview.pin.width(60).height(60).bottom(-30).hCenter()
        let imagev = makeRadarAnimation(showRect: imageview.frame)
        self.layer.insertSublayer(imagev, below: imageview.layer) //动画显示 将图片压后放后放
    }
    
    public func refreshAnimation() {
        self.animationLayer?.removeFromSuperlayer()
        self.animationLayer = makeRadarAnimation(showRect: self.imageview.frame)
        self.layer.insertSublayer(self.animationLayer!, below: imageview.layer) //动画显示 将图片压后放后放
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 动态波的方法
    private func makeRadarAnimation(showRect: CGRect) -> CALayer {
        // 1. 一个动态波
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = showRect
        // showRect 最大内切圆
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: showRect.width, height: showRect.height)).cgPath
        shapeLayer.fillColor = UIColor(hex: "33D1FF", alpha: 0.2).cgColor    //波纹颜色
        shapeLayer.opacity = 0.0    // 默认初始颜色透明度
        animationLayer = shapeLayer     //全局对象2 animationLayer
        
        // 2. 创建动画组 from -> to 透明比例过渡
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber(floatLiteral: 1.0)  // 开始透明度
        opacityAnimation.toValue = NSNumber(floatLiteral: 0)      // 结束时透明底
        
        // 3. 波纹动画 起始大小
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0))      // 缩放起始大小
        scaleAnimation.toValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 12.0, 12.0, 0))      // 缩放结束大小
        
        // 4. 定义波的运行时间
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation]  //引用opacityAnimation 和 scaleAnimation
        animationGroup.duration = 5.0       // 动画执行时间
        animationGroup.repeatCount = HUGE   // 最大重复
        animationGroup.autoreverses = false
        
        self.animationGroup = animationGroup    //全局对象3  animationGroup
        shapeLayer.add(animationGroup, forKey: radarAnimation)  //全局对象1 radarAnimation
        
        // 5. 需要重复的动态波，数量，缩放起始点 <=> 创建副本
        let replicator = CAReplicatorLayer()
        replicator.frame = shapeLayer.bounds
        replicator.instanceCount = 6
        replicator.instanceDelay = 1.0
        replicator.addSublayer(shapeLayer)
        
        return replicator
    }
}
