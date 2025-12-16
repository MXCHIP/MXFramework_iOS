//
//  MXAddDeviceHelpPage.swift
//  MXApp
//
//  Created by 华峰 on 2022/7/21.
//

import Foundation
import SDWebImage
import UIKit

public class MXAddDeviceHelpPage: MXBaseViewController {
    var stepList = Array<String>()
    
    public var imageUrl : String?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_help")
        
        self.contentView.addSubview(self.mxScrollView)
        self.mxScrollView.pin.all()
        
        self.mxScrollView.addSubview(self.imageView)
        self.imageView.pin.all()
        if let imgUrl = self.imageUrl {
            self.imageView.sd_setImage(with: URL(string: imgUrl)) { (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                if let newImage = image {
                    self.imageView.frame = CGRect(x: 0, y: 0, width: self.mxScrollView.frame.size.width, height: newImage.size.height*(self.mxScrollView.frame.size.width/newImage.size.width))
                    self.mxScrollView.contentSize = self.imageView.frame.size
                    self.imageView.image = image
                }
            }
        }
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mxScrollView.pin.all()
    }
    
    lazy var mxScrollView : UIScrollView = {
        let _mxScrollView = UIScrollView()
        _mxScrollView.showsVerticalScrollIndicator = false
        _mxScrollView.showsHorizontalScrollIndicator = false
        _mxScrollView.backgroundColor = .clear
        return _mxScrollView
    }()
    
    lazy var imageView : UIImageView = {
        let _imageView = UIImageView()
        _imageView.backgroundColor = .clear
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
}

extension MXAddDeviceHelpPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceHelpPage()
        controller.imageUrl = params["imageUrl"] as? String
        return controller
    }
}
