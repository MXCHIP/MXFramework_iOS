//
//  File.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/18.
//

import Foundation
import UIKit
import SDWebImage
import PinLayout

class MXDeviceItemCell: UICollectionViewCell {
    
    public typealias MoreDeviceActionCallback = (_ item: MXDeviceInfo, _ testUrl: String? ) -> ()
    public var moreActionCallback : MoreDeviceActionCallback?
    var deviceInfo = MXDeviceInfo()
    
    var inAnimating = false
    var isOpen : Bool = false
    
    public var isEdit = false {
        didSet {
            //self.bleStatusLabel.isHidden = self.isEdit
            self.moreBtn.isHidden = self.isEdit
            self.selectBtn.isHidden = !self.isEdit
        }
    }
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.setTitle("\u{e6f3}", for: .normal)
                self.selectBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
            } else {
                self.selectBtn.setTitle("\u{e6fb}", for: .normal)
                self.selectBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
            }
        }
    }
    
    func showSelectedAnimation() -> Void {
        inAnimating = true
        
        UIView.animate(withDuration: 0.2) {
            self.deviceNameLab.textColor = .white
            self.roomNamelabel.textColor = .white
            self.moreBtn.setTitleColor(.white, for: .normal)
            self.bgView.backgroundColor = UIColor(hex: "52C41A")
            self.bgView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { status in
            if !self.inAnimating {
                return
            }
            UIView.animate(withDuration: 0.1) {
                self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { status in
                if !self.inAnimating {
                    return
                }
                UIView.animate(withDuration: 0.2) {
                    self.deviceNameLab.textColor = MXAppConfig.MXColor.title
                    self.roomNamelabel.attributedText = self.createStatusShowString()
                    self.moreBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
                    self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
                }
            }
        }
        
    }
    
    func removeAllAnimation() -> Void {
        inAnimating = false
        self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.deviceNameLab.textColor = MXAppConfig.MXColor.title
        self.moreBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        
        allSubViews(view: self)
    }
    
    func allSubViews(view: UIView) -> Void {
        view.layer.removeAllAnimations()
        
        view.subviews.forEach { (sv: UIView) in
            allSubViews(view: sv)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPressGes.minimumPressDuration = 5
        longPressGes.numberOfTouchesRequired = 1
        longPressGes.allowableMovement = 15
        self.addGestureRecognizer(longPressGes)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let alert = MXAlertView(title: "", placeholder: "请输入测试地址", text: nil, leftButtonTitle: MXAppConfig.mxLocalized(key: "mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key: "mx_confirm")) { (textField: UITextField, alert: MXAlertView) in
                alert.disappear()
                self.moreActionCallback?(self.deviceInfo, nil)
            } rightButtonCallBack: { (textField: UITextField, alert: MXAlertView) in
                alert.disappear()
                self.moreActionCallback?(self.deviceInfo, textField.text)
            }
            alert.show()
            return
        }
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.layer.cornerRadius = 20
        self.bgView.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
        self.bgView.layer.shadowOffset = CGSize.zero
        self.bgView.layer.shadowOpacity = 1;
        self.bgView.layer.shadowRadius = 8.0;
        
        self.bgView.addSubview(self.deviceImageView)
        self.deviceImageView.pin.left(15).top(10).width(48).height(48)
        
        self.bgView.addSubview(self.deviceNameLab)
        self.deviceNameLab.pin.below(of: self.deviceImageView, aligned: .left).marginTop(8).right(15).height(18)
        
        self.bgView.addSubview(self.roomNamelabel)
        self.roomNamelabel.pin.below(of: self.deviceNameLab, aligned: .left).marginTop(4).right(15).height(16)
        
        self.bgView.addSubview(self.moreBtn)
        self.moreBtn.pin.right(5).top(5).width(50).height(52)
        self.moreBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        self.bgView.addSubview(self.bleStatusLabel)
        self.bleStatusLabel.pin.width(24).height(24).right().bottom()
        self.bleStatusLabel.isHidden = true
        
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(20).top(20).width(24).height(24)
        self.selectBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        if self.mxSelected {
            self.selectBtn.setTitle("\u{e6f3}", for: .normal)
            self.selectBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        } else {
            self.selectBtn.setTitle("\u{e6fb}", for: .normal)
            self.selectBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        }
        
        self.moreBtn.isHidden = self.isEdit
        self.selectBtn.isHidden = !self.isEdit
        
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moreAction() {
        if self.mxSelected {
            self.mxSelected = false
        } else {
            self.mxSelected = true
        }
        self.moreActionCallback?(self.deviceInfo, nil)
    }
    
    public func refreshView(info: MXDeviceInfo, isManager: Bool = false) {
        if self.deviceInfo.iotId != info.iotId {
            self.removeAllAnimation()
        }
        self.deviceImageView.image = nil
        self.deviceNameLab.text = nil
        self.roomNamelabel.text = nil
        
        self.deviceInfo = info
        self.deviceNameLab.text = info.showName
        
        self.roomNamelabel.attributedText = self.createStatusShowString(isManager: isManager)
        self.roomNamelabel.lineBreakMode = .byTruncatingMiddle
        
        if let productImage = info.showImage {
            self.deviceImageView.sd_setImage(with: URL(string: productImage)) { (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                //self.deviceImageView.image = image?.mx_imageByTintColor(color: MXAppConfiguration.MXColor.theme)
                self.deviceImageView.image = image
            }
        }
        
        self.bleStatusLabel.isHidden = true
        /*
        if let product_info = ProductManager.shard.getProductInfo(pk: info.productKey),
               !product_info.not_receive_message,
        product_info.node_type_v2 == "gateway-sub",
        !info.isShare,
        MeshSDK.sharedInstance.isConnected(),
        !self.isEdit {
            self.bleStatusLabel.isHidden = false
        }
         */
    }
    
    func createStatusShowString(isManager: Bool = false) -> NSAttributedString {
        let str = NSMutableAttributedString()
        if isManager {
            if !self.deviceInfo.isFavorite {
                let nameStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_hide"), attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                str.append(nameStr)
            }
//        } else {
//            if let roomName = self.deviceInfo.roomName, roomName.count > 0 {
//                let nameStr = NSAttributedString(string: roomName, attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfiguration.MXColor.secondaryText])
//                str.append(nameStr)
//            }
        }
        
        guard let product_info = MXProductManager.shard.getProductInfo(pk: self.deviceInfo.productKey) else {
            return str
        }
        if product_info.not_receive_message {  //低功耗设备，不显示离线
            return str
        }
        if product_info.node_type_v2 == "gateway-sub", !self.deviceInfo.isShare { //蓝牙子设备
            if !self.deviceInfo.isOnline, !MeshSDK.sharedInstance.isConnected() { //蓝牙未连接，且云端离线
                if str.length > 0 {
                    let separatorStr = NSAttributedString(string: " | ", attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(separatorStr)
                }
                
                let statusStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_offline"), attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.yellow])
                str.append(statusStr)
                return str
            }
            guard let params = self.deviceInfo.propertys,
                  params.count == 1,
                  let pInfo = params.first,
                  let pName = pInfo.identifier else {  //有且仅有一个物模
                return str
            }
            var valueStr: NSAttributedString?
            var value: Int?
            if let uuidStr = self.deviceInfo.uuid,
               uuidStr.count > 0,
               let resultParams = MXMeshDeviceManager.shard.getDeviceCacheProperties(uuid: uuidStr),
               let newValue = resultParams[pName] as? Int { //存在缓存
                value = newValue
            } else if self.deviceInfo.isOnline, let oldValue = pInfo.value as? Int {
                value = oldValue
            }
            if let pValue = value { //开关的值
                if pValue == 1 {
                    valueStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_opened"), attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:UIColor(hex: "52C41A")])
                } else {
                    valueStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_closed"), attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:MXAppConfig.MXColor.secondaryText])
                }
            }
            if let statusStr = valueStr {
                if str.length > 0 {
                    let separatorStr = NSAttributedString(string: " | ", attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(separatorStr)
                }
                str.append(statusStr)
            }
            return str
        } else {  //wifi设备
            if self.deviceInfo.isOnline {  //云端在线
                if let params = self.deviceInfo.propertys, params.count == 1, let pInfo = params.first, let value
                    = pInfo.value as? Int, let _ = pInfo.identifier { //云端的状态值
                    var statusStr = NSAttributedString()
                    let isOpen = (value == 1)
                    if isOpen {
                        statusStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_opened"), attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:UIColor(hex: "52C41A")])
                    } else {
                        statusStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_closed"), attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    }
                    
                    if str.length > 0 {
                        let separatorStr = NSAttributedString(string: " | ", attributes: [.font: UIFont.mxIconFont(ofSize: 12) as Any,.foregroundColor:MXAppConfig.MXColor.secondaryText])
                        str.append(separatorStr)
                    }
                    str.append(statusStr)
                }
                
            } else {
                if str.length > 0 {
                    let separatorStr = NSAttributedString(string: " | ", attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                    str.append(separatorStr)
                }
                
                let statusStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_offline"), attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.yellow])
                str.append(statusStr)
            }
            return str
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.deviceImageView.pin.left(15).top(10).width(48).height(48)
        self.deviceNameLab.pin.below(of: self.deviceImageView, aligned: .left).marginTop(8).right(15).height(18)
        self.roomNamelabel.pin.below(of: self.deviceNameLab, aligned: .left).marginTop(4).right(15).height(16)
        self.bleStatusLabel.pin.width(24).height(24).right().bottom()
        self.moreBtn.pin.right(5).top(5).width(50).height(52)
        self.selectBtn.pin.right(20).top(20).width(24).height(24)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = MXAppConfig.MXWhite.level3
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var deviceImageView : UIImageView = {
        let _deviceImageView = UIImageView()
        _deviceImageView.backgroundColor = UIColor.clear
        _deviceImageView.contentMode = .scaleAspectFit
        return _deviceImageView
    }()
    
    lazy var deviceNameLab : UILabel = {
        let _deviceNameLab = UILabel(frame: .zero)
        _deviceNameLab.font = UIFont.mxSystemFont(ofSize: 14, weight: .medium);
        _deviceNameLab.textColor = MXAppConfig.MXColor.title;
        return _deviceNameLab
    }()
    
    lazy var roomNamelabel : UILabel = {
        let _roomNamelabel = UILabel(frame: .zero)
        _roomNamelabel.font = UIFont.mxSystemFont(ofSize: 12);
        _roomNamelabel.textColor = MXAppConfig.MXColor.secondaryText;
        return _roomNamelabel
    }()
    
    lazy var moreBtn : UIButton = {
        let _moreBtn = UIButton(type: .custom)
        _moreBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 16)
        _moreBtn.setTitle("\u{e6e0}", for: .normal)
        _moreBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        return _moreBtn
    }()
    
    lazy var bleStatusLabel : UILabel = {
        let _bleStatusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        _bleStatusLabel.font = UIFont.mxIconFont(ofSize: 10);
        _bleStatusLabel.textColor = UIColor(hex: "52C41A")
        _bleStatusLabel.textAlignment = .center
        _bleStatusLabel.backgroundColor = UIColor(hex: UIColor(hex: "52C41A").toHexString, alpha: 0.25);
        _bleStatusLabel.text = "\u{e76a}"
        _bleStatusLabel.corner(byRoundingCorners: [.topLeft], radii: 8.0)
        return _bleStatusLabel
    }()
    
    lazy public var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.mxIconFont(ofSize: 24)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(MXAppConfig.MXColor.disable, for: .normal)
        return _selectBtn
    }()
}
