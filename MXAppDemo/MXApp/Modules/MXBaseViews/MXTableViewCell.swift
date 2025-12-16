//
//  MXTableViewCell.swift
//  MXApp
//
//  Created by Khazan on 2021/8/27.
//

import Foundation
import PinLayout
import UIKit

class MXCellModel: NSObject {
    
    var leftImage: String?
    var title: String?
    var des: String?
    var value: String?
    var go = true
    
    init(leftImage: String? = nil, title: String?, des: String? = nil, value: String? = nil, go: Bool = true) {
        self.leftImage = leftImage
        self.title = title
        self.des = des
        self.value = value
        self.go = go
    }
}

open class MXTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.textLabel?.font = UIFont.mxSystemFont(ofSize:16)
        self.textLabel?.textColor = MXAppConfig.MXColor.title
        
        self.detailTextLabel?.font = UIFont.mxSystemFont(ofSize: 16)
        self.detailTextLabel?.textColor = MXAppConfig.MXColor.secondaryText
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSubviews(with data: [String: Any]) -> Void {
        
    }
    
}

