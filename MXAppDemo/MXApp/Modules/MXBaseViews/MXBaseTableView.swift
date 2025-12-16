//
//  MXBaseTableView.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/23.
//

import Foundation
import UIKit

open class MXBaseTableView: UITableView {
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.clear
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        self.estimatedSectionHeaderHeight = 0
        self.estimatedSectionFooterHeight = 0
        
        self.layoutMargins.left = 0.01
        self.layoutMargins.right = 0.01
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let align = self.emptyView?.centerAlignment, align {
            self.emptyView?.pin.all()
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

open class MXCollectionView: UICollectionView {
    
    public var emptyHeight: CGFloat = 0
    var _headerView : UIView?
    public var headerView: UIView? {
        get {
            return _headerView
        }
        set {
            _headerView?.removeFromSuperview()
            _headerView = newValue
            if _headerView != nil {
                self.addSubview(_headerView!)
            }
            let headerView_h = _headerView?.frame.height ?? 0
            let footerView_h = _footerView?.frame.height ?? 0
            //设置滚动范围偏移
            self.scrollIndicatorInsets = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            //设置内容范围偏移
            self.contentInset = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            self.layoutSubviews()
        }
    }
    
    var _footerView: UIView?
    public var footerView: UIView? {
        get {
            return _footerView
        }
        set {
            _footerView?.removeFromSuperview()
            _footerView = newValue
            if _footerView != nil {
                self.addSubview(_footerView!)
            }
            let headerView_h = _headerView?.frame.height ?? 0
            let footerView_h = _footerView?.frame.height ?? 0
            //设置滚动范围偏移
            self.scrollIndicatorInsets = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            //设置内容范围偏移
            self.contentInset = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            self.layoutSubviews()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let h = self.frame.size.height
        let content_h = self.contentSize.height
        let headerView_h = _headerView?.frame.height ?? 0
        let footerView_h = _footerView?.frame.height ?? 0
        //设置滚动范围偏移
        //self.scrollIndicatorInsets = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
        //设置内容范围偏移
        //self.contentInset = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
        _headerView?.pin.left().right().top(-headerView_h).height(headerView_h)
        _footerView?.pin.left().right().bottom(-(content_h-h+footerView_h)).height(footerView_h)
        self.emptyView?.pin.left().right().top().height(self.frame.size.height-headerView_h-footerView_h)
        if self.emptyHeight > 0 {
            self.emptyView?.pin.left().right().top().height(self.emptyHeight)
        }
        if let empty_view = self.emptyView, content_h == 0 {
            _footerView?.pin.left().right().height(footerView_h).below(of: empty_view).marginTop(0)
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

//自定义的具有粘性分组头的Collection View布局类
class MXHeadersFlowLayout: UICollectionViewFlowLayout {
    
    //边界发生变化时是否重新布局（视图滚动的时候也会调用）
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    //所有元素的位置属性
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
        //从父类得到默认的所有元素属性
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect)
            else { return nil }
        
        //用于存储元素新的布局属性,最后会返回这个
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
        //存储每个layout attributes对应的是哪个section
        let sectionsToAdd = NSMutableIndexSet()
        
        //循环老的元素布局属性
        for layoutAttributesSet in layoutAttributes {
            //如果元素师cell
            if layoutAttributesSet.representedElementCategory == .cell {
                //将布局添加到newLayoutAttributes中
                newLayoutAttributes.append(layoutAttributesSet)
            } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                //将对应的section储存到sectionsToAdd中
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            }
        }
        
        //遍历sectionsToAdd，补充视图使用正确的布局属性
        for section in sectionsToAdd {
            let indexPath = IndexPath(item: 0, section: section)
            
            //添加头部布局属性
            if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                                                                                    UICollectionView.elementKindSectionHeader, at: indexPath) {
                newLayoutAttributes.append(headerAttributes)
            }
            
            //添加尾部布局属性
            if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                                                                                    UICollectionView.elementKindSectionFooter, at: indexPath) {
                newLayoutAttributes.append(footerAttributes)
            }
        }
        
        return newLayoutAttributes
    }
    
    //补充视图的布局属性(这里处理实现粘性分组头,让分组头始终处于分组可视区域的顶部)
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //先从父类获取补充视图的布局属性
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind:
            elementKind, at: indexPath) else { return nil }
        
        //如果不是头部视图则直接返回
        if elementKind != UICollectionView.elementKindSectionHeader {
            return layoutAttributes
        }
        
        //根据section索引，获取对应的边界范围
        guard let boundaries = boundaries(forSection: indexPath.section)
            else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        //保存视图内入垂直方向的偏移量
        let contentOffsetY = collectionView.contentOffset.y
        //补充视图的frame
        var frameForSupplementaryView = layoutAttributes.frame
        
        //计算分组头垂直方向的最大最小值
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        //如果内容区域的垂直偏移量小于分组头最小的位置，则将分组头置于其最小位置
        if contentOffsetY < minimum {
            frameForSupplementaryView.origin.y = minimum
        }
        //如果内容区域的垂直偏移量大于分组头最小的位置，则将分组头置于其最大位置
        else if contentOffsetY > maximum {
            frameForSupplementaryView.origin.y = maximum
        }
        //如果都不满足，则说明内容区域的垂直便宜量落在分组头的边界范围内。
        //将分组头设置为内容偏移量，从而让分组头固定在集合视图的顶部
        else {
            frameForSupplementaryView.origin.y = contentOffsetY
        }
        
        //更新布局属性并返回
        layoutAttributes.frame = frameForSupplementaryView
        return layoutAttributes
    }
    
    //根据section索引，获取对应的边界范围（返回一个元组）
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        //保存返回结果
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        //如果collectionView属性为nil，则直接fanhui
        guard let collectionView = collectionView else { return result }
        
        //获取该分区中的项目数
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        //如果项目数位0，则直接返回
        guard numberOfItems > 0 else { return result }
        
        //从流布局属性中获取第一个、以及最后一个项的布局属性
        let first = IndexPath(item: 0, section: section)
        let last = IndexPath(item: (numberOfItems - 1), section: section)
        if let firstItem = layoutAttributesForItem(at: first),
            let lastItem = layoutAttributesForItem(at: last) {
            //分别获区边界的最小值和最大值
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            //将分区都的高度考虑进去，并调整
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            //将分区的内边距考虑进去，并调整
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        //返回最终的边界值
        return result
    }
}

class MaxCellSpacingLayout: UICollectionViewFlowLayout {
    
    
/// 最大cell水平间距
    public var maximumInteritemSpacing: CGFloat = 0.0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        if attributes?.count == 0 {
            return attributes
        }
        
        let firstCellOriginX = attributes?.first?.frame.origin.x
        
        if let count = attributes?.count {
            
            for i in 1..<count {
                let currentLayoutAttributes = attributes![i]
                let previousLayoutAttributes = attributes![i-1]
                
                if currentLayoutAttributes.frame.origin.x == firstCellOriginX {
                    continue
                }
                
                let previousOriginMaxX = previousLayoutAttributes.frame.maxX
                if currentLayoutAttributes.frame.origin.x - previousOriginMaxX > maximumInteritemSpacing {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = previousOriginMaxX + maximumInteritemSpacing
                    currentLayoutAttributes.frame = frame
                }
            }
            
        }
        
        return attributes
        
    }
    
}


extension UICollectionView {
    
    public class func initializeMethod(){
        let originalSelector = #selector(UICollectionView.reloadData)
        let swizzledSelector = #selector(UICollectionView.mx_reloadData)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func mx_reloadData() {
        DispatchQueue.main.async {
            self.mx_reloadData()
        }
    }
}

extension UITableView {
    
    public class func initializeMethod(){
        let originalSelector = #selector(UITableView.reloadData)
        let swizzledSelector = #selector(UITableView.mx_reloadData)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func mx_reloadData() {
        DispatchQueue.main.async {
            self.mx_reloadData()
        }
    }
}
