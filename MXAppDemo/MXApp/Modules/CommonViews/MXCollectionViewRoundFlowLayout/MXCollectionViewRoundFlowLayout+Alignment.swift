//
//  MXCollectionViewRoundFlowLayout+Alignment.swift
//  MXCollectionViewRoundFlowLayout
//
//

import UIKit

extension MXCollectionViewRoundFlowLayout{
    
    /// 将相同y位置的cell集合到一个列表中(竖向)
    /// - Parameter layoutAttributesAttrs: layoutAttributesAttrs description
    func groupLayoutAttributesForElementsByYLineWithLayoutAttributesAttrs(_ layoutAttributesAttrs:Array<UICollectionViewLayoutAttributes>) -> Array<Array<UICollectionViewLayoutAttributes>> {
        
        var allDict = Dictionary<CGFloat,NSMutableArray>();
        
        for (_,attr) in layoutAttributesAttrs.enumerated() {
            
            let dictArr = allDict[attr.frame.midY]
            if dictArr != nil {
                dictArr?.add(attr.copy())
            }else{
                let arr = NSMutableArray.init(object: attr.copy());
                allDict[attr.frame.midY] = arr
            }
        }
        return (allDict as NSDictionary).allValues as! Array<Array<UICollectionViewLayoutAttributes>>;
    }
    
    /// 将相同x位置的cell集合到一个列表中(横向)
    /// - Parameter layoutAttributesAttrs: layoutAttributesAttrs description
    func groupLayoutAttributesForElementsByXLineWithLayoutAttributesAttrs(_ layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>) -> Array<Array<UICollectionViewLayoutAttributes>> {
        
        var allDict = Dictionary<CGFloat,NSMutableArray>();
        for (_,attr) in layoutAttributesAttrs.enumerated() {
            let dictArr = allDict[attr.frame.origin.x]
            if dictArr != nil {
                dictArr?.add(attr.copy())
            }else{
                let arr = NSMutableArray.init(object: attr.copy());
                allDict[attr.frame.origin.x] = arr
            }
        }
        return (allDict as NSDictionary).allValues as! Array<Array<UICollectionViewLayoutAttributes>>;
    }
    
    func evaluatedAllCellSettingFrameWithLayoutAttributesAttrs(_ layoutAttributesAttrs:Array<Array<UICollectionViewLayoutAttributes>> ,  toChangeAttributesAttrsList:inout Array<UICollectionViewLayoutAttributes> ,cellAlignmentType alignmentType : MXCollectionViewRoundFlowLayoutSwiftAlignmentType) -> Array<UICollectionViewLayoutAttributes> {

        toChangeAttributesAttrsList.removeAll()
        for calculateAttributesAttrsArr in layoutAttributesAttrs {
            switch alignmentType {
            case .Left:
                self.evaluatedCellSettingFrameByLeftWithWithMXCollectionLayout(self, layoutAttributesAttrs: calculateAttributesAttrsArr);
                break
            case .Center:
                self.evaluatedCellSettingFrameByCenterWithWithMXCollectionLayout(self,layoutAttributesAttrs:calculateAttributesAttrsArr);
                break;
            case .Right:
                var reversedArray = Array.init(calculateAttributesAttrsArr);
                reversedArray.reverse();
                self.evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(self, layoutAttributesAttrs: reversedArray);
                break;
            case .RightAndStartR:
                self.evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(self, layoutAttributesAttrs: calculateAttributesAttrsArr);
                break;
            default:
                break;
            }
            toChangeAttributesAttrsList += calculateAttributesAttrsArr;
        }
        return toChangeAttributesAttrsList;
    }
}

//MARK: - alignmentLeft
extension MXCollectionViewRoundFlowLayout{
    
    /// 计算AttributesAttrs左对齐
    /// - Parameters:
    ///   - layout: layout description
    ///   - layoutAttributesAttrs: 需计算的AttributesAttrs列表
    func evaluatedCellSettingFrameByLeftWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        //left
        var pAttr:UICollectionViewLayoutAttributes? = nil;
        for attr in layoutAttributesAttrs {
            if attr.representedElementKind != nil {
                //nil when representedElementCategory is UICollectionElementCategoryCell (空的时候为cell)
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                //竖向
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x + pAttr!.frame.size.width + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.x = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).left;
                }
            }else{
                //横向
                if pAttr != nil {
                    frame.origin.y = pAttr!.frame.origin.y + pAttr!.frame.size.height + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.y = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).top;
                }
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}

//MARK: - alignmentCenter
extension MXCollectionViewRoundFlowLayout{
    func evaluatedCellSettingFrameByCenterWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        //center
        var pAttr : UICollectionViewLayoutAttributes? = nil;
        
        var useWidth : CGFloat = 0.0;
        let theSection = layoutAttributesAttrs.first!.indexPath.section;
        for attr in layoutAttributesAttrs{
            useWidth += attr.bounds.size.width;
        }
        
        let firstLeft = (layout.collectionView!.bounds.size.width - useWidth - (MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: theSection) * CGFloat(layoutAttributesAttrs.count)))/2.0;
        
        for attr in layoutAttributesAttrs{
            if attr.representedElementKind != nil {
                //nil when representedElementCategory is UICollectionElementCategoryCell (空的时候为cell)
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                //竖向
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x + pAttr!.frame.size.width + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.x = firstLeft;
                }
            }else{
                //横向
                if pAttr != nil {
                    frame.origin.y = pAttr!.frame.origin.y + pAttr!.frame.size.height + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.y = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).top;
                }
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}


//MARK: - alignmentRight
extension MXCollectionViewRoundFlowLayout{
    
    /// 计算AttributesAttrs左对齐
    /// - Parameters:
    ///   - layout: layout description
    ///   - layoutAttributesAttrs: 需计算的AttributesAttrs列表
    func evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        //left
        var pAttr:UICollectionViewLayoutAttributes? = nil;
        for attr in layoutAttributesAttrs {
            if attr.representedElementKind != nil {
                //nil when representedElementCategory is UICollectionElementCategoryCell (空的时候为cell)
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                //竖向
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x - MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section) - frame.size.width;
                }else{
                    frame.origin.x = layout.collectionView!.bounds.size.width -  MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).right - frame.size.width;
                }
            }else{
                
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}
