//
//  MXSelectedRoomHeaderView.swift
//  MXApp
//
//  Created by 华峰 on 2023/3/24.
//

import Foundation
import UIKit

class MXSelectedRoomHeaderView: UIView {
    
    public typealias DidSelectedItemCallback = (_ selectValue: MXRoomInfo) -> ()
    public var didSelectedItemCallback : DidSelectedItemCallback?
    public typealias DataSourceChangeCallback = () -> ()
    public var addNewDataCallBack: DataSourceChangeCallback?
    
    var roomList = Array<MXRoomInfo>() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var roomId: Int?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = MXAppConfig.MXWhite.level4
        self.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 16)
        
        self.addSubview(self.nameLab)
        self.nameLab.pin.left(20).right(20).top(12).height(18)
        self.addSubview(self.collectionView)
        self.collectionView.pin.left(20).right(20).below(of: self.nameLab).marginTop(0).height(60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLab.pin.left(20).right(20).top(12).height(18)
        self.collectionView.pin.left(20).right(20).below(of: self.nameLab).marginTop(0).height(60)
    }
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxSystemFont(ofSize: 14, weight: .medium)
        //_nameLab.textColor = MXAppConfiguration.MXTitleColor.title;
        _nameLab.textColor = .black
        _nameLab.textAlignment = .left
        _nameLab.text = MXAppConfig.mxLocalized(key:"mx_add_room_all")
        return _nameLab
    }()
    
    lazy var collectionView: MXCollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 16.0, left: 0.0, bottom: 12.0, right: 0.0)
        _layout.minimumInteritemSpacing = 16.0
        _layout.minimumLineSpacing = 12.0
        _layout.scrollDirection = .horizontal
        
        let _collectionview = MXCollectionView (frame: self.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXAddDeviceSelectRoomCell.self, forCellWithReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self))
        _collectionview.backgroundColor  = .clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = false
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _collectionview.contentInsetAdjustmentBehavior = .never
        return _collectionview
    }()
}

extension MXSelectedRoomHeaderView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.roomList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self), for: indexPath) as! MXAddDeviceSelectRoomCell
        cell.backgroundColor = UIColor.clear
        
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            cell.nameLB.text = roomInfo.name
            if let room_id = self.roomId {
                cell.mxSelected = (roomInfo.roomId == room_id)
            } else {
                cell.mxSelected = roomInfo.is_default
            }
            cell.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        } else {
            cell.mxSelected = false
            cell.nameLB.text = "\u{e701}"
            cell.nameLB.textColor = MXAppConfig.MXColor.primaryText
            cell.bgView.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            if let nameStr = roomInfo.name {
                let titleSize = nameStr.size(withAttributes: [.font: UIFont.mxSystemFont(ofSize: 16)])
                let itemSize = CGSize(width: titleSize.width+40, height: 32)
                return itemSize
            }
        }
        
        return CGSize(width: 80, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            self.roomId = roomInfo.roomId
            self.didSelectedItemCallback?(roomInfo)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            self.addNewDataCallBack?()
        }
    }
}
