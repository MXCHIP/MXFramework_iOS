//
//  MXManualViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/18.
//

import Foundation
import UIKit

public class MXManualViewController: MXBaseViewController {
    
    public var networkKey : String?
    var list = Array<MXCategoryInfo>()
    var selectedIndex: Int = 0
    var collectionSectionIndex: Int = 0
    var subCategoryList = Array<MXCategoryInfo>()
    var isScroll = false
    var roomId: Int?
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left().top().bottom().width(100)
        
        self.collectionView.headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 16))
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.right(of: self.tableView).marginLeft(0).top().right().bottom()
        
        self.tableView.backgroundColor = UIColor(with: "FBFBFD", lightModeAlpha: 1, darkModeHex: "121212", darkModeAlpha: 1)
        self.collectionView.backgroundColor = MXAppConfig.MXWhite.level1
        
        MXProductManager.loadCategoryListRequest(handler: { [weak self] (list: Array<MXCategoryInfo>) in
            self?.list.removeAll()
            self?.subCategoryList.removeAll()
            for info in list {
                if let categoryDict = MXCategoryInfo.mx_keyValue(info),
                   let newInfo = MXCategoryInfo.mx_Decode(categoryDict) {
                    var noData = true
                    if let subList = newInfo.categorys {
                        for subInfo in subList {
                            subInfo.products?.removeAll(where: {$0.hide})
                            if (subInfo.products?.count ?? 0) > 0 {
                                noData = false
                                self?.subCategoryList.append(subInfo)
                            }
                        }
                    }
                    if !noData {
                        self?.list.append(newInfo)
                    }
                }
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
            }
        })
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left().top().bottom().width(100)
        self.collectionView.pin.right(of: self.tableView).marginLeft(0).top().right().bottom()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 16))
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        
        tableView.register(MXCategoryCell.self, forCellReuseIdentifier: String(describing: MXCategoryCell.self))
        
        return tableView
    }()
    
    lazy var collectionView: MXCollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.itemSize = CGSize.init(width: (self.view.frame.size.width - 120)/3.0, height: 120)
        _layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10.0, bottom: 0, right: 10.0)
        _layout.minimumInteritemSpacing = 0.0
        _layout.minimumLineSpacing = 0.0
        _layout.scrollDirection = .vertical
        //_layout.sectionHeadersPinToVisibleBounds = true
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXProductCell.self, forCellWithReuseIdentifier: String (describing: MXProductCell.self))
        _collectionview.register(MXProductCollectionHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXProductCollectionHeader.self))
        _collectionview.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: String (describing: UICollectionReusableView.self))
        _collectionview.backgroundColor  = MXAppConfig.MXWhite.level1
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = true
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _collectionview.contentInsetAdjustmentBehavior = .never
        return _collectionview
    }()
    
    func fetchCollectionSectionIndex() {
        var scrollIndex = 0
        for i in 0 ..< self.selectedIndex {
            if self.list.count > i {
                let info = self.list[i]
                scrollIndex += info.categorys?.count ?? 0
            } else {
                break
            }
            
        }
        collectionSectionIndex = scrollIndex
        
        let path = IndexPath.init(row:0, section:self.collectionSectionIndex)
        let attributes = self.collectionView.layoutAttributesForItem(at: path)
        var offset_y = attributes?.frame.origin.y ?? 0
        offset_y -= 50
        if offset_y < 0 {
            offset_y = 0
        } else if offset_y > self.collectionView.contentSize.height - self.collectionView.frame.height {
            offset_y = self.collectionView.contentSize.height - self.collectionView.frame.height
        }
        self.collectionView.setContentOffset(CGPoint(x: 0, y: offset_y), animated: true)
    }
    
    func fetchTableViewSelectedIndex() {
        var scrollIndex = 0
        for i in 0 ..< self.list.count {
            let info = self.list[i]
            scrollIndex += info.categorys?.count ?? 0
            if scrollIndex > self.collectionSectionIndex {
                self.selectedIndex = i
                break
            }
            
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.selectedIndex), at: .top, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension MXManualViewController:UITableViewDataSource,UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXCategoryCell.self)) as? MXCategoryCell
        if cell == nil{
            cell = MXCategoryCell(style: .default, reuseIdentifier: String (describing: MXCategoryCell.self))
        }
        if list.count > indexPath.section {
            let categoryInfo = list[indexPath.section]
            if let name = categoryInfo.name {
                cell?.nameLB.text = name
                cell?.mxSelected = (indexPath.section == self.selectedIndex)
            }
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if list.count > indexPath.section {
            self.selectedIndex = indexPath.section
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.fetchCollectionSectionIndex()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16.0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 16))
        view.backgroundColor = .clear
        return view
    }
}

extension MXManualViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.subCategoryList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.subCategoryList.count > section {
            let subInfo = self.subCategoryList[section]
            return subInfo.products?.count ?? 0
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXProductCell.self), for: indexPath) as! MXProductCell
        cell.backgroundColor = UIColor.clear
        cell.setupViews()
        if self.subCategoryList.count > indexPath.section {
            let subInfo = self.subCategoryList[indexPath.section]
            if let productList = subInfo.products {
                if productList.count > indexPath.row {
                    let productInfo = productList[indexPath.row]
                    cell.refreshView(info: productInfo)
                }
            }
        }
        
        return cell
    }
    
    // 返回HeadView的宽高
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: self.view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 16)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXProductCollectionHeader.self), for: indexPath as IndexPath) as! MXProductCollectionHeader
            if self.subCategoryList.count > indexPath.section {
                let subInfo = self.subCategoryList[indexPath.section]
                reusableview.titleLB.text = subInfo.name
                reusableview.layoutSubviews()
            }
            return reusableview
        } else if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: UICollectionReusableView.self), for: indexPath as IndexPath)
            reusableview.backgroundColor = UIColor.clear
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.subCategoryList.count > indexPath.section {
            let subInfo = self.subCategoryList[indexPath.section]
            if let productList = subInfo.products {
                if productList.count > indexPath.row {
                    let productInfo = productList[indexPath.row]
                    var params = [String :Any]()
                    params["networkKey"] = self.networkKey
                    params["productInfo"] = productInfo
                    params["roomId"] = self.roomId
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
                }
            }
        }
    }
}

extension MXManualViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView, self.isScroll {
            let items = self.collectionView.indexPathsForVisibleItems
            let sortedIndexPaths = items.sorted()
            if let sectionIndex = sortedIndexPaths.first {
                if self.collectionSectionIndex != sectionIndex.section {
                    self.collectionSectionIndex = sectionIndex.section
                    self.fetchTableViewSelectedIndex()
                }
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView, !self.isScroll {
            self.isScroll = true
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView, self.isScroll {
            self.isScroll = false
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.collectionView, !decelerate, self.isScroll {
            self.isScroll = false
        }
    }
}

extension MXManualViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXManualViewController()
        controller.networkKey = params["networkKey"] as? String ?? MXHomeManager.shard.currentHome?.networkKey
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
