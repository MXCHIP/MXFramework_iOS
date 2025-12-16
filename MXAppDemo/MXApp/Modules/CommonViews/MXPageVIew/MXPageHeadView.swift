//
//  MXPageHeadView.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/8.
//

import Foundation
import UIKit

@objc public protocol MXPageHeadViewDelegate {
    ///MXPageHeadView选中后方法回调
    func mx_pageHeadViewSelectedAt(_ index:Int);
}

public struct MXPageHeadTextAttribute {
    ///默认字体颜色
    public var defaultTextColor:UIColor = UIColor.darkGray
    ///默认字体大小
    public var defaultFontSize:CGFloat = 15
    //默认背景颜色
    public var defaultBGColor:UIColor = .clear
    
    ///选中字体颜色
    public var selectedTextColor:UIColor = UIColor.black
    ///选中字体大小
    public var selectedFontSize:CGFloat = 16
    //选中背景颜色
    public var selectedBGColor:UIColor = .clear
    
    ///是否需要背景
    public var needBackground: Bool = false
    
    ///是否需要下划线(默认显示)
    public var needBottomLine: Bool = true
    ///下划线颜色
    public var bottomLineColor:UIColor = UIColor.orange
    ///下划线宽度
    public var bottomLineWidth:CGFloat = 0
    ///下划线高度
    public var bottomLineHeight:CGFloat = 4

    ///itemSize宽度(默认50)
    public var itemWidth:CGFloat = 50
    //item间隙
    public var itemSpacing:CGFloat = 0
    public var itemOffset: CGFloat = 10
    ///Required
    public init() {}
}


open class MXPageHeadView: UIView {
    ///TTHeadView属性
    var textAttribute:MXPageHeadTextAttribute!
    
    public var _titles :[String]! {
        didSet {
            self.itemSizes.removeAll()
            self.contentWidth = 0
            for t in _titles {
                let titleSize =  t.size(withAttributes: [.font: UIFont.mxSystemFont(ofSize: textAttribute.selectedFontSize)])
                let itemSize = CGSize(width: max(textAttribute.itemWidth, titleSize.width+24), height: frame.height)
                self.itemSizes.append(itemSize)
                self.contentWidth += itemSize.width
            }
            self.scrollToItemAtIndex(_currentIndex)
        }
    }
    fileprivate var _currentIndex: Int = 0//current selected
    fileprivate weak var _delegate:MXPageHeadViewDelegate?
    
    fileprivate var _collectionView:UICollectionView!
    fileprivate var _bottomLineWidth:CGFloat = 0
    fileprivate var _bottomLine:UILabel!
    
    var itemSizes = [CGSize]()
    public var contentWidth: CGFloat = 0
    
    //MARK: - Init
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _collectionView = mxCollectionView(CGRect (x: 0, y: 0, width: frame.width, height: frame.height))
        _collectionView.backgroundColor = UIColor.clear
        self.addSubview(_collectionView)
    }
    
   /// 初始化TTHeadView
   public init(frame:CGRect,
               titles:[String],
               delegate:MXPageHeadViewDelegate? = nil,
               textAttributes:MXPageHeadTextAttribute = MXPageHeadTextAttribute())
   {
        super.init(frame:frame)
    
        _titles = titles
        _delegate = delegate
        textAttribute = textAttributes
    
        itemSizes.removeAll()
       self.contentWidth = 0
        for t in titles {
            let titleSize =  t.size(withAttributes: [.font: UIFont.mxSystemFont(ofSize: textAttribute.defaultFontSize)])
            let itemSize = CGSize(width: max(textAttribute.itemWidth, titleSize.width+24), height: frame.height)
            itemSizes.append(itemSize)
            self.contentWidth += itemSize.width
        }
    
        _collectionView = mxCollectionView(CGRect (x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(_collectionView)
        
        //bottomLine
        if textAttributes.needBottomLine {
            var itemW = textAttribute.itemWidth
            if self.itemSizes.count > 0 {
                let item_size = self.itemSizes[0]
                itemW = item_size.width
            }
            
            if textAttributes.bottomLineWidth > 0 {
                _bottomLineWidth = textAttributes.bottomLineWidth
            }else{
                _bottomLineWidth = itemW * 0.5
            }
            
            let offset = itemW * 0.5 +  _collectionView.contentInset.left + (_collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left - _bottomLineWidth/2.0
            _bottomLine = UILabel (frame: CGRect (x: offset, y: _collectionView.frame.height - textAttributes.bottomLineHeight, width: _bottomLineWidth, height: textAttributes.bottomLineHeight))
            _bottomLine.backgroundColor = textAttribute.bottomLineColor
            
            _bottomLine.layer.cornerRadius = textAttributes.bottomLineHeight/2
            _bottomLine.layer.masksToBounds = true
            _collectionView.addSubview(_bottomLine)
        }

    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _collectionView.pin.all()
    }
    
    //MARK:
    /// 滑动到指定索引(供外部调用)
    public func scrollToItemAtIndex(_ index:Int) {
        _currentIndex = index
        DispatchQueue.main.async {
            self._collectionView.reloadData()
        }
        
        var item_width = textAttribute.itemWidth
        if self.itemSizes.count > index {
            let itemSize = self.itemSizes[index]
            item_width = itemSize.width
        }
        
        var item_offset = _collectionView.contentInset.left + (_collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left
        for i in 0 ..< index {
            if self.itemSizes.count > index {
                let item_size = self.itemSizes[i]
                item_offset += item_size.width + (_collectionView.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
            }
        }
        item_offset += item_width/2.0
        
        var offset = item_offset - _collectionView.frame.width/2
        var max = _collectionView.contentSize.width - _collectionView.frame.width + _collectionView.contentInset.left
        if max < 0 {
            max = 0
        }
        
        if offset < 0 { offset = -_collectionView.contentInset.left;}
        if offset > 0 && max >= 0 && offset > max { offset = max;}
        
        let _x = item_offset
        
        if textAttribute.needBottomLine {
            UIView.animate(withDuration: 0.2) {[unowned self] in
                self._bottomLine.center = CGPoint (x: _x, y: self._bottomLine.center.y);
            }
        }
        
        _collectionView.setContentOffset(CGPoint (x: offset, y: 0), animated: true)
    }
    
    ///Private
    fileprivate func mxCollectionView(_ frame:CGRect) -> UICollectionView {
        let _layout = UICollectionViewFlowLayout()
        _layout.itemSize = CGSize (width: textAttribute.itemWidth, height: frame.height)
        _layout.minimumInteritemSpacing = textAttribute.itemSpacing
        _layout.minimumLineSpacing = textAttribute.itemSpacing
        _layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: textAttribute.itemOffset, bottom: 0.0, right: textAttribute.itemOffset)
        _layout.scrollDirection = .horizontal
        
        let collectionview = UICollectionView (frame: frame, collectionViewLayout: _layout)
        collectionview.delegate  = self
        collectionview.dataSource = self
        collectionview.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String (describing: UICollectionViewCell.self))
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundView = nil
        collectionview.backgroundColor = UIColor.clear
        return collectionview
    }
    
}

//MARK: - UICollectionViewDataSource
extension MXPageHeadView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: UICollectionViewCell.self), for: indexPath)
        let v = _titles[indexPath.row]
        
        for _v in cell.contentView.subviews{
            _v.removeFromSuperview();
        }
        var itemW = textAttribute.itemWidth
        if self.itemSizes.count > indexPath.row {
            let item_size = self.itemSizes[indexPath.row]
            itemW = item_size.width
        }
        let l = UILabel.init(frame: CGRect (x: 0, y: 0, width: itemW, height: self.frame.height))
        l.backgroundColor = textAttribute.needBackground ? (_currentIndex == indexPath.row ? textAttribute.selectedBGColor : textAttribute.defaultBGColor) : UIColor.clear
        if textAttribute.needBackground {
            l.layer.masksToBounds = true
            l.layer.cornerRadius = self.frame.height/2.0
        }
        l.font = UIFont.mxSystemFont(ofSize: _currentIndex == indexPath.row ? textAttribute.selectedFontSize:textAttribute.defaultFontSize, weight: _currentIndex == indexPath.row ? UIFont.Weight.medium:UIFont.Weight.regular)
        l.textAlignment = .center
        l.text = v
        l.textColor = _currentIndex == indexPath.row ? textAttribute.selectedTextColor:textAttribute.defaultTextColor
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.addSubview(l)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard _titles.count > indexPath.row else { return }
        let index = indexPath.row
        guard index != _currentIndex else{ return }
        _currentIndex = index
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
        
        scrollToItemAtIndex(index)
        
        _delegate?.mx_pageHeadViewSelectedAt(index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.itemSizes.count > indexPath.row {
            return self.itemSizes[indexPath.row]
        }
        return CGSize (width: textAttribute.itemWidth, height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0.0, left: textAttribute.itemOffset, bottom: 0.0, right: textAttribute.itemOffset)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return textAttribute.itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return textAttribute.itemSpacing
    }
    
}
