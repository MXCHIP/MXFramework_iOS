//
//  MXNavigationController.swift
//  MXApp
//
//  Created by 华峰 on 2022/2/25.
//

import Foundation
import UIKit

open class MXNavigationController : UINavigationController {
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.viewControllers.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.last?.classForCoder == viewController.classForCoder {
            return
        }
        super.pushViewController(viewController, animated: animated)
    }
}
