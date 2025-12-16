//
//  MXPageViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/8.
//

import Foundation
import UIKit

@objc public protocol MXPageViewControllerDelegate {
    func mx_pageControllerSelectedAt(_ index:Int)
}

open class MXPageContentView: UIView {
    
    
    public var childsVCs :[UIViewController]!
    weak var parentVC: UIViewController?
    
    var currentIndex: Int = 0//current selected index
    
    weak var delegate:MXPageViewControllerDelegate?
    
    public init(frame: CGRect, childViewControllers:[UIViewController], parentViewController: UIViewController? = nil, delegate:MXPageViewControllerDelegate? = nil) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.childsVCs = childViewControllers
        self.parentVC = parentViewController
        self.delegate = delegate
        
        for vc in self.childsVCs {
            self.parentVC?.addChild(vc)
        }
        
        self.addSubview(self.collectionView)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.pin.all()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var collectionView: UICollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.minimumInteritemSpacing = 0
        _layout.minimumLineSpacing = 0
        _layout.scrollDirection = .horizontal
        
        let _collectionView = UICollectionView (frame: self.bounds, collectionViewLayout: _layout)
        _collectionView.delegate  = self
        _collectionView.dataSource = self
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String (describing: UICollectionViewCell.self))
        _collectionView.backgroundColor  = UIColor.clear
        _collectionView.isPagingEnabled = true
        _collectionView.bounces = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.contentInsetAdjustmentBehavior = .never
        return _collectionView
    }()
   
    //Public Method
   public func scrollToPageAtIndex(_ index:Int) {
       if self.childsVCs.count > index {
           self.collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .right, animated: false)
       }
    }
    
}





extension MXPageContentView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.childsVCs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: UICollectionViewCell.self), for: indexPath)
        if self.childsVCs.count > indexPath.row {
            let v = self.childsVCs[indexPath.row]
            for _v in cell.contentView.subviews{
                _v.removeFromSuperview();
            }
            v.removeFromParent()
            v.view.frame =  cell.contentView.bounds
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.contentView.addSubview(v.view)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _scroll(scrollView);
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _scroll(scrollView);
    }
    
    func _scroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.width
        let i = lrintf(Float(index))
        guard i != currentIndex else{ return }
        currentIndex = i
        self.delegate?.mx_pageControllerSelectedAt(i)
    }
    
}
