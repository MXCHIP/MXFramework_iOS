//
//  UIImage+Extension.swift
//  MXApp
//
//  Created by Khazan on 2021/9/23.
//

import Foundation
import UIKit

extension UIImage {
    
    public convenience init(qrCode: String) {
        
        let data = qrCode.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 12, y: 12)

            if let output = filter.outputImage?.transformed(by: transform) {
                self.init(ciImage: output)
                return
            }
        }
        
        self.init()
    }
    
    public func resize() -> UIImage? {
        let max: CGFloat = 960
        
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if self.size.width > self.size.height {
            newWidth = max
            newHeight = max / self.size.width * self.size.height
        } else {
            newHeight = max
            newWidth = max / self.size.height * self.size.width
        }
        
        return self.imageWithNewSize(size: CGSize(width: newWidth, height: newHeight))
    }
    
    public func imageWithNewSize(size: CGSize) -> UIImage? {
    
        if self.size.height > size.height {
            
            let width = size.height / self.size.height * self.size.width
            
            let newImgSize = CGSize(width: width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
            
        } else {
            
            let newImgSize = CGSize(width: size.width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
        }
    
    }
    
}
