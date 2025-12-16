//
//  MXColorButton.swift
//  MXApp
//
//  Created by Khazan on 2021/9/13.
//

import Foundation
import UIKit

public class MXColorButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
                
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        self.titleLabel?.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        self.setTitleColor(.white, for: .normal)
        self.setBackgroundColor(color: MXAppConfig.MXColor.theme, forState: UIControl.State.normal)
        self.setBackgroundColor(color: MXAppConfig.MXColor.theme.withAlphaComponent(0.5), forState: UIControl.State.disabled)
        
    }
    
}
