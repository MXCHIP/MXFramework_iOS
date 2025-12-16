//
//  UIFont+mxExtension.swift
//  MXApp
//
//  Created by huafeng on 2024/9/11.
//

import Foundation
import UIKit

extension UIFont {
    public class func mxIconFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "mx-iconfont", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    public class func mxSystemFont(ofSize fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: weight)
    }
    
}
