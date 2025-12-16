//
//  MXDeviceProvisionFailPage.swift
//  MXApp
//
//  Created by huafeng on 2024/1/4.
//

import Foundation
import SDWebImage
import UIKit

public class MXDeviceProvisionFailPage: MXBaseViewController {

    var currentDevice : MXProvisionDeviceInfo?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_failed_detail")
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.addSubview(self.nextBtn)
        self.nextBtn.pin.left(16).right(16).height(50).vCenter()
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.left(10).top(12).right(10).above(of: self.bottomView).marginBottom(10)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.top(32).width(48).height(48).hCenter()
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.below(of: self.iconView).marginTop(8).left(16).right(16).height(22)
        self.bgView.addSubview(self.titleLB)
        self.titleLB.pin.below(of: self.nameLB).marginTop(20).left(16).right(16).height(20)
        self.bgView.addSubview(self.detailLB)
        self.detailLB.pin.below(of: self.titleLB).marginTop(20).left(16).right(16).bottom(20)
        
        var failStepName: String?
        if let step = self.currentDevice?.provisionStepList.first(where: {$0.status == 3}) {
            failStepName = step.name
        }
        self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_ble_connect_failed")
        var detailStr = MXAppConfig.mxLocalized(key: "mx_provision_connect_fail")
        
        if failStepName == MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_ble") {  //蓝牙连接失败
            self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_ble_connect_failed")
            detailStr = MXAppConfig.mxLocalized(key: "mx_provision_connect_fail")
        } else if failStepName == MXAppConfig.mxLocalized(key:"mx_provisioning_step_config") {  //Mesh信息失败
            self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_mesh_config_failed")
            detailStr = MXAppConfig.mxLocalized(key: "mx_provision_config_fail")
        } else if failStepName == MXAppConfig.mxLocalized(key:"mx_provisioning_step_connect_wifi") { //Wi-Fi连接失败
            self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_setting_wifi_failed")
            detailStr = MXAppConfig.mxLocalized(key: "mx_provision_wifi_fail")
        } else if failStepName == MXAppConfig.mxLocalized(key:"mx_provisioning_step_bind") {
            self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_account_bind_fail")
            detailStr = MXAppConfig.mxLocalized(key: "mx_provision_bind_fail")
        } else if failStepName == MXAppConfig.mxLocalized(key:"mx_scene_sync") {
            self.titleLB.text = MXAppConfig.mxLocalized(key: "mx_sync_fail")
            detailStr = MXAppConfig.mxLocalized(key: "mx_provision_config_fail")
        }
        
        let paragraphStyle = NSMutableParagraphStyle() // 创建段落样式对象
        paragraphStyle.lineSpacing = 4 // 设置行间距为4点（根据需要调整）
        // 将段落样式应用到文本上
        let attributedText = NSAttributedString(string: detailStr, attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.font: UIFont.mxSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: MXAppConfig.MXColor.title])
        self.detailLB.attributedText = attributedText
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        
        if let info = self.currentDevice {
            self.nameLB.text = info.productInfo?.name
            if let productImage = info.productInfo?.image {
                self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
            }
        }
        
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70)
        self.nextBtn.pin.left(16).right(16).height(50).vCenter()
        self.bgView.pin.left(10).top(12).right(10).above(of: self.bottomView).marginBottom(10)
        self.iconView.pin.top(34).width(48).height(48).hCenter()
        self.nameLB.pin.below(of: self.iconView).marginTop(8).left(16).right(16).height(22)
        self.titleLB.pin.below(of: self.nameLB).marginTop(20).left(16).right(16).height(20)
        self.detailLB.pin.below(of: self.titleLB).marginTop(20).left(16).right(16).bottom(20)
    }
    
    private lazy var bgView : UIView = {
        let _bgView = UIView()
        _bgView.backgroundColor = MXAppConfig.MXWhite.level1
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    private lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
        _bottomView.backgroundColor = MXAppConfig.MXWhite.level1
        _bottomView.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
        _bottomView.layer.shadowOffset = CGSize.zero
        _bottomView.layer.shadowOpacity = 1
        _bottomView.layer.shadowRadius = 8
        return _bottomView
    }()
    
    lazy var nextBtn : MXColorButton = {
        let _nextBtn = MXColorButton(type: .custom)
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_i_know"), for: .normal)
        _nextBtn.addTarget(self, action: #selector(gotoBack), for: .touchUpInside)
        return _nextBtn
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 18, weight: .medium)
        _nameLB.textColor = MXAppConfig.MXColor.title
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.mxSystemFont(ofSize: 16);
        _titleLB.textColor = MXAppConfig.MXColor.red
        _titleLB.textAlignment = .center
        return _titleLB
    }()
    
    lazy var detailLB : UITextView = {
        let _detailLB = UITextView(frame: .zero)
        _detailLB.font = UIFont.mxSystemFont(ofSize: 14);
        _detailLB.textColor = MXAppConfig.MXColor.title
        _detailLB.textAlignment = .left
        //_detailLB.isEditable = false
        _detailLB.isUserInteractionEnabled = false
        return _detailLB
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MXDeviceProvisionFailPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceProvisionFailPage()
        controller.currentDevice = params["device"] as? MXProvisionDeviceInfo
        return controller
    }
}
