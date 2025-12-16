//
//  UIButton+Extension.swift
//  MXApp
//
//  Created by Khazan on 2021/8/11.
//

import Foundation
import UIKit


extension UIButton {
    
    public func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
        
    }
    
}
