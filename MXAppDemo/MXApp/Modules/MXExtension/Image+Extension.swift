//
//  Image+Extension.swift
//  MXApp
//
//  Created by 华峰 on 2021/7/12.
//

import Foundation
import UIKit

extension UIImage {
    public func mx_imageByTintColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        color.set()
        UIRectFill(rect)
        self.draw(at: CGPoint.init(x: 0, y: 0), blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
 
            return rotatedImage ?? self
        }
 
        return self
    }
}

extension UIImage {
    
    public var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        return inputImage.averageColor
    }
    
    public static func edgeAverageColors(inputImage: CIImage, num: Int = 50) -> [[UInt8]]? {
        let imageW: CGFloat = (inputImage.extent.size.height + inputImage.extent.size.width)*2/CGFloat(num)
        let imageH: CGFloat = inputImage.extent.size.height/3
        var colors = [[UInt8]]()
        
        for i in stride(from: 0, to: inputImage.extent.size.height ,by: imageW) {
            guard inputImage.extent.size.height - i > imageW/2.0  else {
                break
            }
            let extentVector = CIVector(cgRect: CGRect(x: 0, y: i, width: imageH, height: imageW))
            if let color = UIImage.averageColor(inputImage: inputImage, extentVector: extentVector) {
                colors.append(color)
            }
        }
        
        for i in stride(from: 0, to: inputImage.extent.size.width ,by: imageW) {
            guard inputImage.extent.size.width - i > imageW/2.0  else {
                break
            }
            let extentVector = CIVector(cgRect: CGRect(x: i, y: inputImage.extent.size.height - imageH, width: imageW, height: imageH))
            if let color = UIImage.averageColor(inputImage: inputImage, extentVector: extentVector) {
                colors.append(color)
            }
        }
        
        for i in stride(from: inputImage.extent.size.height - imageW, to: -imageW/2.0 ,by: -imageW) {
            let extentVector = CIVector(cgRect: CGRect(x: inputImage.extent.size.width-imageH, y: i, width: imageH, height: imageW))
            if let color = UIImage.averageColor(inputImage: inputImage, extentVector: extentVector) {
                colors.append(color)
            }
        }
        
        for i in stride(from: inputImage.extent.size.width - imageW, to: -imageW/2.0 ,by: -imageW) {
            let extentVector = CIVector(cgRect: CGRect(x: i, y: 0, width: imageW, height: imageH))
            if let color = UIImage.averageColor(inputImage: inputImage, extentVector: extentVector) {
                colors.append(color)
            }
        }
        
        return colors
    }
    
    public static func averageColor(inputImage: CIImage, extentVector:CIVector) -> [UInt8]? {
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return bitmap
    }
}

extension CGImage {
    
    public subscript (x: Int, y: Int) -> UIColor? {
        if x < 0 || x > self.width || y < 0 || y > self.height {
            return nil
        }
        if let providerData = self.dataProvider?.data, let data = CFDataGetBytePtr(providerData) {
            let numberOfComponents = 4
            let pixelData = ((self.width * y) + x) * numberOfComponents
             
            let r = CGFloat(data[pixelData]) / 255.0
            let g = CGFloat(data[pixelData + 1]) / 255.0
            let b = CGFloat(data[pixelData + 2]) / 255.0
            let a = CGFloat(data[pixelData + 3]) / 255.0
             
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        return nil
    }
}

extension CIImage {
    public var averageColor: UIColor? {
        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    public var maxColor: UIColor? {
        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaMaximum", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    public var minColor: UIColor? {
        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaMinimum", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
