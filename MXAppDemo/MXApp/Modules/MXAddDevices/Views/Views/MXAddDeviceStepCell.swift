//
//  MXAddDeviceStepCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/25.
//

import Foundation
import UIKit


public class MXAddDeviceStepCell: UITableViewCell {
    
    public var nameLeftOffSet: CGFloat = 72
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func updateSubViews(info:MXProvisionStepInfo) {
        self.nameLB.text = info.name
        self.statusLB.textColor = MXAppConfig.MXColor.theme
        self.statusLB.text = nil
        switch info.status {
        case 0:
            self.nameLB.textColor = MXAppConfig.MXColor.disable
            //self.statusLB.text = nil
            break
        case 1:
            self.nameLB.textColor = MXAppConfig.MXColor.theme
            //self.statusLB.text = "\u{e70e}"
            break
        case 2:
            self.nameLB.textColor = MXAppConfig.MXColor.theme
            //self.statusLB.text = "\u{e6f4}"
            break
        case 3:
            self.nameLB.textColor = MXAppConfig.MXColor.red
            self.statusLB.textColor = MXAppConfig.MXColor.red
            //self.statusLB.text = "\u{e721}"
            break
        default:
            self.nameLB.textColor = MXAppConfig.MXColor.disable
            self.statusLB.text = nil
            break
        }
        /*
        self.statusLB.layer.removeAllAnimations()
        if info.status == 1 {
            let animatiion = CABasicAnimation(keyPath: "transform.rotation.z")
            animatiion.fromValue = 0.0
            animatiion.toValue = 2*Double.pi
            animatiion.repeatCount = 0
            animatiion.duration = 1
            animatiion.isRemovedOnCompletion = false
            self.statusLB.layer.add(animatiion, forKey: "LoadingAnimation")
        }
         */
        self.layoutSubviews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        
//        self.contentView.addSubview(self.statusLB)
//        self.statusLB.pin.right(of: self.nameLB).marginLeft(8).top().height(18).width(14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        //self.nameLB.pin.sizeToFit().left(self.nameLeftOffSet).top().height(18)
        //self.statusLB.pin.right(of: self.nameLB).marginLeft(8).top().height(18).width(14)
    }
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.backgroundColor = .clear
        _nameLB.font = UIFont.mxSystemFont(ofSize: 14);
        _nameLB.textColor = MXAppConfig.MXColor.disable;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    public lazy var statusLB : UILabel = {
        let _statusLB = UILabel(frame: .zero)
        _statusLB.backgroundColor = .clear
        _statusLB.font = UIFont.mxIconFont(ofSize: 14)
        _statusLB.textColor = MXAppConfig.MXColor.theme;
        _statusLB.textAlignment = .center
        return _statusLB
    }()
}
