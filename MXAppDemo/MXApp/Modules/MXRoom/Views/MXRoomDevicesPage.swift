//
//  MXRoomDetailViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/7/14.
//

import Foundation
import MJRefresh
import UIKit

public class MXRoomDevicesPage: MXBaseViewController {
    
    public var roomId : Int?
    public var roomName: String?
    // 数据源
    lazy var collectionView: MXCollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: 10, bottom: 0.0, right: 10)
        _layout.itemSize = CGSize(width: (self.view.frame.size.width - 30.1) / 2.0, height: 124)
        _layout.minimumInteritemSpacing = 10
        _layout.minimumLineSpacing = 10
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.backgroundColor  = UIColor.clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = true
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _collectionview.register(MXDeviceItemCell.self, forCellWithReuseIdentifier: "MXDeviceItemCell")
        _collectionview.contentInsetAdjustmentBehavior = .never
        return _collectionview
    }()
    
    var devices = [MXDeviceInfo]()
    
    var isShowDevices: Bool = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //mesh网络连接状态
        NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        //本地物属性状态变化
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromLocate"), object: nil)
        //本地物模型缓存失效
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyCacheInvalid(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyCacheInvalidFromLocate"), object: nil)
        //云端物属性变化
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeRemote(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromRemote"), object: nil)
        //云端在离线状态改变
        NotificationCenter.default.addObserver(self, selector: #selector(deviceStatusChangeRemote(notif:)), name: NSNotification.Name(rawValue: "kDeviceRemoteStatusChange"), object: nil)
        
        //刷新页面数据
        NotificationCenter.default.addObserver(self, selector: #selector(roomDeviceSourceChange(notif:)), name: NSNotification.Name(rawValue: "kDeviceDataSourceChange"), object: nil)
        
        self.view.backgroundColor = UIColor.clear
        
        //self.collectionView.bounces = false
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.all()
        let mxEmptyView = MXActionEmptyView(frame: CGRect(x: 0, y: 0, width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height))
        //mxEmptyView.firstReloadHidden = true
        mxEmptyView.didClickActionCallback = {
            if !MXHomeManager.shard.operationAuthorityCheck() {
                return
            }
            var params = [String :Any]()
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/search", params: params)
        }
        mxEmptyView.actionBtn.isHidden = !MXHomeManager.shard.operationAuthorityCheck()
        self.collectionView.emptyView = mxEmptyView
        
//        let header = MJRefreshNormalHeader()
//        header.setRefreshingTarget(self, refreshingAction: #selector(refreshDeviceData))
//        self.collectionView.mj_header = header
        
        collectionView.register(MXDeviceItemCell.self, forCellWithReuseIdentifier: "MXDeviceItemCell")
        
        if let room_id = self.roomId, let room = MXHomeManager.shard.currentHome?.rooms?.first(where: {$0.roomId == room_id}) {
            self.devices = room.devices
            self.collectionView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshDeviceData()
        
        //切后台回来，需要刷新列表数据，避免mqtt数据不同步的问题
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDeviceData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public override func appLanguageChange() {
        self.fetchData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func refreshDeviceData() {
        
        if MXHomeManager.shard.currentHome?.homeId == nil {  //还没有获取到当前家庭不需要请求
            return
        }
        
        MXSystemAuth.authNetwork { [weak self] isSuccess in
            if isSuccess {
                DispatchQueue.main.async {
                    self?.fetchData()
                }
            }
        }
    }
    
    public func scrollToTop() {
        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.pin.left().right().top(16).bottom()
        self.collectionView.mj_header?.layoutSubviews()
        self.collectionView.mj_footer?.layoutSubviews()
    }
    //mesh连接状态变化
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    //本地物属性变化
    @objc func devicePropertyChangeLocate(notif: Notification) {
        
        if let result = notif.object as? [String : Any], let uuidStr = result.keys.first(where: {$0.count > 30}) {
            self.refreshTableViewCell(uuidStr: uuidStr)
        }
    }
    //本地缓存失效
    @objc func devicePropertyCacheInvalid(notif: Notification) {
        if let uuid = notif.object as? String {
            self.refreshTableViewCell(uuidStr: uuid)
        }
    }
    //云端物属性变化
    @objc func devicePropertyChangeRemote(notif: Notification) {
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        
        updatePropertys(with: dic)
    }
    //云端设备状态
    @objc func deviceStatusChangeRemote(notif: Notification) {
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        
        self.updateDeviceStatue(with: dic)
    }
    
    @objc func roomReSourceChange(notif: Notification) {
        guard let params = notif.object as? [String : Any],
              let idList = params["roomId"] as? [Int], idList.contains(self.roomId ?? 0) else {
            return
        }
        self.refreshDeviceData()
    }
    
    @objc func roomDeviceSourceChange(notif: Notification) {
        guard let params = notif.object as? [String : Any],
              let idList = params["roomId"] as? [Int], idList.contains(self.roomId ?? 0) else {
            return
        }
        guard let homeID = MXHomeManager.shard.currentHome?.homeId else { return }
        MXDeviceManager.requestAllDevices(homeId: homeID, roomId: self.roomId, favorite: true) { list, isSuccess in
            if isSuccess {
                self.devices = list
            }
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 2))
            }
        }
    }
    
    @objc func refreshDeviceInfo(notif: Notification) {
        guard let info = notif.object as? MXDeviceInfo else { return }
        
        updateDevice(with: info)
    }
    
}

// MARK: 请求数据
extension MXRoomDevicesPage {
    
    func fetchData() -> Void {
        guard let homeID = MXHomeManager.shard.currentHome?.homeId else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        MXDeviceManager.requestAllDevices(homeId: homeID, roomId: self.roomId, favorite: true) { list, isSuccess in
            if isSuccess {
                self.devices = list
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if let room_id = self.roomId, let room = MXHomeManager.shard.currentHome?.rooms?.first(where: {$0.roomId == room_id}) {
                room.devices = self.devices
                mxAppLog("家庭房间数据更新")
                MXHomeManager.shard.updateCache()
            }
            self.collectionView.reloadData()
        }
    }
    
}

// 操作item
extension MXRoomDevicesPage {
    
    //刷新某个cell
    func refreshTableViewCell(uuidStr:String) {
        self.devices.enumerated().forEach { (itemIndex, dev) in
            if let uuid = dev.uuid,
               uuid.count > 0,
               uuidStr == uuid {
                let indexPath = IndexPath(row: itemIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? MXDeviceItemCell {
                    cell.refreshView(info: dev)
                }
                return
            }
        }
    }
    
    // 属性变更
    func updatePropertys(with info: [String: Any]) -> Void {
        self.devices.enumerated().forEach { (itemIndex, dev) in
            if let iotId = dev.iotId,
               let propertys = dev.propertys,
               let new = info[iotId] as? [String: Any] {
                dev.isOnline = true
                propertys.forEach { item in
                    if let identifier = item.identifier,
                    let valueInfo = new[identifier] as? [String : Any],
                    let value = valueInfo["value"] as? Int {
                        item.value = value as AnyObject
                    }
                }
                let indexPath = IndexPath(row: itemIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? MXDeviceItemCell {
                    cell.refreshView(info: dev)
                }
                return
            }
        }
    }
    
    
    func updateDeviceStatue(with info: [String: Any]) -> Void {
        self.devices.enumerated().forEach { (itemIndex, dev) in
            if let iotId = dev.iotId,
               let status = info[iotId] as? Bool {
                dev.isOnline = status
                let indexPath = IndexPath(row: itemIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? MXDeviceItemCell {
                    cell.refreshView(info: dev)
                }
                return
            }
        }
    }
    
    func updateDevice(with info: MXDeviceInfo) -> Void {
        self.devices.enumerated().forEach { (itemIndex, dev) in
            if let iotId = dev.iotId,
               let infoIotId = info.iotId,
                iotId == infoIotId {
                dev.nickName = info.showName
                let indexPath = IndexPath(row: itemIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? MXDeviceItemCell {
                    cell.refreshView(info: dev)
                }
                return
            }
        }
    }
    
}

extension MXRoomDevicesPage: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isShowDevices ? self.devices.count : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MXDeviceItemCell", for: indexPath) as? MXDeviceItemCell
        if self.devices.count > indexPath.row {
            let data = self.devices[indexPath.row]
            cell?.refreshView(info: data)
            cell?.moreActionCallback = { info, url in
                if let testUrl = url, testUrl.count > 0 {
                    MXDeviceManager.shard.gotoControlPanel(with: info, testUrl: testUrl)
                } else {
                    MXDeviceManager.shard.showPanel(with: info)
                }
            }
        }
        return cell ?? UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.devices.count > indexPath.row {
            let item = self.devices[indexPath.row]
            if item.propertys?.count == 1, let pInfo = item.propertys?.first {  //只有1个开关
                if let cell = collectionView.cellForItem(at: indexPath) as? MXDeviceItemCell {
                    cell.showSelectedAnimation()
                }
                MXDeviceManager.shard.setProperty(with: item, pInfo: pInfo)
            } else if (item.propertys?.count ?? 0) > 1 {  //多开关
                MXDeviceManager.shard.showLaconic(with: item)
            } else {
                MXDeviceManager.shard.showPanel(with: item)
            }
        }
    }
}

extension MXRoomDevicesPage: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 10.0 * 2 - 10.1) / 2.0
        return CGSize(width: width, height: 124)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension MXRoomDevicesPage: MXURLRouterDelegate {
    public static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXRoomDevicesPage()
        vc.roomId = params["roomId"] as? Int
        return vc
    }
}
