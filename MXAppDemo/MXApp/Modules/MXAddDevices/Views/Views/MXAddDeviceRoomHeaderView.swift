//
//  MXAddDeviceRoomHeaderView.swift
//  MXApp
//
//  Created by 华峰 on 2022/3/3.
//

import Foundation
import SDWebImage
import UIKit

class MXAddDeviceRoomHeaderView: UICollectionReusableView {
    
    var info : MXDeviceInfo?
    var infoChangeCallback : MXDeviceInfoChangeCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //本地物属性变化
    @objc func devicePropertyChangeLocate(notif: Notification) {
        guard let uuidStr = self.info?.uuid, uuidStr.count > 0 else {
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
        let deviceParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: msg, attrMap: self.info?.productInfo?.attrMap)
        if let value = deviceParams["LightSwitch"] as? Int {
            self.actionBtn.isSelected = (value == 1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        
        self.addSubview(self.bgView)
        
        self.bgView.addSubview(self.iconView)
        
        self.bgView.addSubview(self.nameLB)
        
        self.bgView.addSubview(self.eidtBtn)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.isHidden = true
    }
    
    @objc func eidtAction() {
        guard let newInfo = self.info else { return }
        
        let alertView = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_device_name"), placeholder: MXAppConfig.mxLocalized(key:"mx_input_name"), text:self.info?.showName, maxLength: MXAppConfig.mxNameMaxLength, leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) { (textField: UITextField, alert: MXAlertView) in
            
            alert.disappear()

        } rightButtonCallBack: { [weak self] (textField: UITextField, alert: MXAlertView) in
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                MXToastHUD.showInfo(status: MXAppConfig.mxLocalized(key: "mx_no_input"))
                return }
            if let msg = text.toastMessageIfIsInValidRoomName() {
                MXToastHUD.showInfo(status: msg)
                return
            }
            
            alert.disappear()

            self?.info?.nickName = text
            self?.nameLB.text = text
            self?.infoChangeCallback?(newInfo)
        }
        alertView.show()
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.info = info
        self.nameLB.text = info.showName
        self.actionBtn.isHidden = true
        
        if let imageStr = info.showImage, imageStr.count > 0 {
            self.iconView.sd_setImage(with: URL(string: imageStr), completed: nil)
        }
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left().right().top(10).bottom()
        self.iconView.pin.left(16).top(24).width(48).height(48)
        self.actionBtn.pin.right(16).top(28).width(40).height(40)
        if self.actionBtn.isHidden {
            self.nameLB.pin.right(of: self.iconView).marginLeft(8).height(20).top(38).maxWidth(self.frame.size.width - 120).sizeToFit(.height)
        } else {
            self.nameLB.pin.right(of: self.iconView).marginLeft(8).height(20).top(38).maxWidth(self.frame.size.width - 160).sizeToFit(.height)
        }
        self.eidtBtn.pin.right(of: self.nameLB).marginLeft(0).top(30).width(32).height(36)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = .clear
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 48, height: 48))
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        _iconView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(iconTapAction))
        _iconView.addGestureRecognizer(tap)
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var eidtBtn : UIButton = {
        let _btn = UIButton(type: .custom)
        _btn.titleLabel?.font = UIFont.mxIconFont(ofSize: 16)
        _btn.setTitleColor(MXAppConfig.MXColor.secondaryText, for: .normal)
        _btn.setTitle("\u{e71e}", for: .normal)
        _btn.addTarget(self, action: #selector(eidtAction), for: .touchUpInside)
        return _btn
    }()
    
    lazy var actionBtn : UIButton = {
        let _btn = UIButton(type: .custom)
        _btn.titleLabel?.font = UIFont.mxIconFont(ofSize: 16)
        _btn.setTitle("\u{e749}", for: .normal)
        _btn.setTitleColor(MXAppConfig.MXColor.secondaryText, for: .normal)
        _btn.setTitleColor(MXAppConfig.MXColor.theme, for: .selected)
        _btn.addTarget(self, action: #selector(iconTapAction), for: .touchUpInside)
        _btn.isSelected = true
        return _btn
    }()
    
    @objc func iconTapAction() {
        if let uuidStr = info?.uuid, uuidStr.count > 0 {  //mesh设备
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: "000102", callback: nil)
        }
    }
}
