//
//  MXCollectionViewRoundConfigModel.swift
//  MXCollectionViewRoundFlowLayout
//
//

import UIKit

@objcMembers
open class MXCollectionViewRoundConfigModel: NSObject {
    open var borderWidth : CGFloat = 0;
    open var borderColor : UIColor?
    
    open var backgroundColor : UIColor?
    open var shadowColor : UIColor?
    open var shadowOffset : CGSize?
    open var shadowOpacity : Float = 0;
    open var shadowRadius : CGFloat = 0;
    open var cornerRadius : CGFloat = 0;
    
}
