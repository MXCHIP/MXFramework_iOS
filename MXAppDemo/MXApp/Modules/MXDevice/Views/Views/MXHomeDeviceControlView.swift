//
//  MXHomeDeviceControlView.swift
//  MXApp
//
//  Created by Khazan on 2021/8/30.
//

import Foundation
import UIKit


class MXHomeDeviceControlViewCell: UICollectionViewCell {
    
    func updataSubviews(with model: MXDevicePropertyItem) -> Void {
        nameLabel.text = model.name
        
        var imageName: String!
        if let status = model.value as? Int, status == 1 {
            imageName = "switchOn"
        } else {
            imageName = "switchOff"
        }
        
        imageView.image = UIImage(named: imageName)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(nameLabel)
        nameLabel.textColor = MXAppConfig.MXColor.primaryText
        nameLabel.font = UIFont.mxSystemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        
        self.contentView.addSubview(imageView)
        imageView.image = UIImage(named: "switchOn")
        imageView.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left().right().bottom().height(16)
        imageView.pin.above(of: nameLabel, aligned: .center).marginBottom(8).width(44).height(44)
    }
    
    
    let imageView = UIImageView()
    
    let nameLabel = UILabel()
    
}

class MXHomeDeviceControlView: UIView {
    
    public typealias DidOptionCallback = () -> ()
    public var didOptionCallback : DidOptionCallback!
    public typealias DidSelectedCallback = (_ device: MXDeviceInfo, _ propertyInfo:MXDevicePropertyItem) -> ()
    public var didSelectedCallback : DidSelectedCallback!
    
    let contentViewMarginLeft: CGFloat = 10.0
    
    var itemMarginLeft: CGFloat = 75.0

    var itemMarginTop: CGFloat = 68.0

    let itemWidth: CGFloat = 65.0
    
    let itemHeight: CGFloat = 68.0

    var minimumInteritemSpacing: CGFloat = 0.0
    
    public var name: String = ""
    
    var deviceInfo: MXDeviceInfo? {
        didSet {
            if let info = self.deviceInfo, let pList = info.propertys {
                self.dataSources = pList
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func show() -> Void {
        
        NotificationCenter.default.removeObserver(self)
        //本地物属性状态变化
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromLocate"), object: nil)
        //云端物属性变化
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeRemote(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromRemote"), object: nil)

        if dataSources.count == 2 {
            itemMarginTop = 68.0
            itemMarginLeft = 61.0
            minimumInteritemSpacing = MXAppConfig.mxScreenWidth - contentViewMarginLeft * 2 - itemMarginLeft * 2 - itemWidth * 2
        } else if dataSources.count == 3 {
            itemMarginTop = 68.0
            itemMarginLeft = 44.0
            minimumInteritemSpacing = (MXAppConfig.mxScreenWidth - contentViewMarginLeft * 2 - itemMarginLeft * 2 - itemWidth * 3) / 2
        } else if dataSources.count == 4 {
            itemMarginTop = 26.0
            itemMarginLeft = 95.0
            minimumInteritemSpacing = MXAppConfig.mxScreenWidth - contentViewMarginLeft * 2 - itemMarginLeft * 2 - itemWidth * 2
        }
        
        nameLabel.text = self.name
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            if let window = UIApplication.shared.delegate?.window {
                window?.addSubview(self)
            } else {
                if #available(iOS 13.0, *) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                       if let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                          let window = sceneDelegate.window  {
                           window?.addSubview(self)
                       } else if let window = windowScene.windows.first  {
                           window.addSubview(self)
                       }
                    }
                } else {
                    if let window = UIApplication.shared.keyWindow {
                        window.addSubview(self)
                    }
                }
            }
        }
    }
    
    @objc func disappearButtonAction(sender: UIButton) {
        disappear()
    }
    
    @objc func options(sender: UIButton) -> Void {
        self.didOptionCallback?()
        disappear()
    }
    
    func disappear() -> Void {
        NotificationCenter.default.removeObserver(self)
        self.removeFromSuperview()
    }
    
    //本地物属性变化
    @objc func devicePropertyChangeLocate(notif: Notification) {
        guard let uuidStr = self.deviceInfo?.uuid, uuidStr.count > 0 else {
            return
        }
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let msgDict = dic[uuidStr] as? [String : Any]  else {
            return
        }
        guard let msg = msgDict["message"] as? String  else {
            return
        }
        let deviceParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: msg, attrMap: self.deviceInfo?.productInfo?.attrMap)
        self.dataSources.forEach { (item:MXDevicePropertyItem) in
            if let pName = item.identifier, let value = deviceParams[pName] as? Int {
                item.value = value as AnyObject
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    //云端物属性变化
    @objc func devicePropertyChangeRemote(notif: Notification) {
        
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        if let iot_id = self.deviceInfo?.iotId, let protertys = dic[iot_id] as? [String : Any]  {
            for property in self.dataSources {
                if let identifierStr = property.identifier, let valueDict = protertys[identifierStr] as? [String : Any], let newValue = valueDict["value"] as? Int  {
                    property.value = newValue as AnyObject
                    
                    if let uuidStr = self.deviceInfo?.uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected(), let deviceParams = MXMeshDeviceManager.shard.getDeviceCacheProperties(uuid: uuidStr), let locateValue = deviceParams[identifierStr] as? Int {  //本地在线，直接丢弃云端的状态
                        property.value = locateValue as AnyObject
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    init(title: String, dataList:[MXDevicePropertyItem]) {
        super.init(frame: .zero)
        self.name = title
        self.dataSources = dataList
        initSubviews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = UIColor(hex: "000000").withAlphaComponent(0.4)
        
        self.addSubview(disappearButton)
        disappearButton.addTarget(self, action: #selector(disappearButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        
        self.addSubview(contentView)
        contentView.backgroundColor = MXAppConfig.MXWhite.level4
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        nameLabel.text = "XXX-XXXX"
        nameLabel.textColor = MXAppConfig.MXColor.title
        nameLabel.font = UIFont.mxSystemFont(ofSize: 16, weight: .medium)
        nameLabel.textAlignment = .center
        
        contentView.addSubview(optionsLabel)
        optionsLabel.text = "\u{e6e0}"
        optionsLabel.font = UIFont.mxIconFont(ofSize: 20)
        optionsLabel.textColor = MXAppConfig.MXColor.disable
        let tap = UITapGestureRecognizer(target: self, action: #selector(options(sender:)))
        optionsLabel.isUserInteractionEnabled = true
        optionsLabel.addGestureRecognizer(tap)
        
        contentView.addSubview(moreLabel)
        moreLabel.text = "\u{e736}"
        moreLabel.font = UIFont.mxIconFont(ofSize: 12)
        moreLabel.textColor = MXAppConfig.MXColor.disable
                
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MXHomeDeviceControlViewCell.self, forCellWithReuseIdentifier: "CELL")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        disappearButton.pin.all()
        contentView.pin.left(contentViewMarginLeft).right(contentViewMarginLeft).bottom(contentViewMarginLeft).height(268)
        nameLabel.pin.left().right().top(16).height(20)
        optionsLabel.pin.top().right().height(50).width(50)
        collectionView.pin.below(of: nameLabel).left().right().height(204)
        moreLabel.pin.below(of: collectionView, aligned: .center).width(10).height(10)
    }
    
    let disappearButton = UIButton()

    let contentView = UIView()
    
    let nameLabel = UILabel()
    
    let optionsLabel = UILabel()
    
    let moreLabel = UILabel()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var dataSources = [MXDevicePropertyItem]()
    
    
}

extension MXHomeDeviceControlView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! MXHomeDeviceControlViewCell
        if indexPath.row < dataSources.count {
            let model = dataSources[indexPath.row]
            cell.updataSubviews(with: model)
        }
        return cell
    }

}

extension MXHomeDeviceControlView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemMarginTop, left: itemMarginLeft, bottom: 0, right: itemMarginLeft)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let info = self.deviceInfo, self.dataSources.count > indexPath.row {
            let pInfo = self.dataSources[indexPath.row]
            self.didSelectedCallback?(info, pInfo)
        }
    }
    
}
