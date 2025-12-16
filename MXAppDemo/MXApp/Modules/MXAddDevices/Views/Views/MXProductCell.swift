//
//  MXProductCell.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/23.
//

import Foundation
import SDWebImage
import UIKit

class MXProductCell: UICollectionViewCell {
    
    var info : MXProductInfo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.iconView)
        self.iconView.pin.top(8).width(60).height(60).hCenter()
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.below(of: self.iconView).marginTop(4).left(4).right(4).bottom(8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: MXProductInfo) {
        self.iconView.image = nil
        self.nameLB.text = nil
        
        self.info = info
        if let nickName = info.name {
            self.nameLB.text = nickName
        }
        
        if let productImage = info.image {
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.top(8).width(60).height(60).hCenter()
        self.nameLB.pin.below(of: self.iconView).marginTop(4).left(4).right(4).bottom(8)
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 10);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .center
        _nameLB.numberOfLines = 3
        _nameLB.adjustsFontSizeToFitWidth = true
        _nameLB.minimumScaleFactor = 0.5
        return _nameLB
    }()
}
