//
//  MXAddDeviceInitViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/27.
//

import Foundation
import SDWebImage
import UIKit


public class MXAddDeviceInitViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String!
    public var wifiSSID : String?
    public var wifiPassword : String?
    public var productInfo : MXProductInfo?
    public var deviceList = Array<MXProvisionDeviceInfo>()
    public var isReplace: Bool?
    public var replacedDevice: MXDeviceInfo?
    
    var helpImageUrl:String?
    
    var roomId: Int?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_init_device")
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.addSubview(self.nextBtn)
        self.nextBtn.pin.left(16).right(16).height(50).vCenter()
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(240).height(240).center()
        if let productImage = self.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
        
        self.bgView.addSubview(self.headerView)
        self.headerView.pin.left().top().right().above(of: self.iconView).marginBottom(10)
        self.headerView.titleLB.text = MXAppConfig.mxLocalized(key:"mx_init_device")
        self.headerView.desLB.text = MXAppConfig.mxLocalized(key:"mx_init_device_des")
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.left(24).right(24).bottom(24).height(20)
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        self.bottomView.backgroundColor = MXAppConfig.MXWhite.level3
        
        self.loadDeviceInitData()
    }
    
    func loadDeviceInitData() {
        guard let pk = self.productInfo?.product_key else {
            return
        }
        MXAPI.product.getProductGuide(productKey: pk) { data, message, code in
            if code == 0 {
                if let dict = data as? [String: Any] {
                    if let bind_guide_text = dict["bind_guide_text"] as? String, bind_guide_text.count > 0 {
                        self.headerView.desLB.text = bind_guide_text
                    }
                    if let bind_guide_image = dict["bind_guide_image"] as? String, bind_guide_image.count > 0 {
                        self.iconView.sd_setImage(with: URL(string: bind_guide_image), completed: nil)
                    }
                    if let bind_confirm_text = dict["bind_confirm_text"] as? String, bind_confirm_text.count > 0 {
                        self.nextBtn.setTitle(bind_confirm_text, for: .normal)
                    }
                    if let bind_help_text = dict["bind_help_text"] as? String, bind_help_text.count > 0 {
                        self.desLB.attributedText = NSAttributedString(string: bind_help_text, attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.theme])
                    }
                    if let bind_help_image = dict["bind_help_image"] as? String, bind_help_image.count > 0 {
                        self.helpImageUrl = bind_help_image
                    }
                }
            }
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        self.nextBtn.pin.left(16).right(16).height(50).top(10)
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        self.iconView.pin.width(240).height(240).center()
        self.headerView.pin.left().top().right().above(of: self.iconView).marginBottom(10)
        self.desLB.pin.left(24).right(24).bottom(24).height(20)
    }
    
    private lazy var bgView : UIView = {
        let _bgView = UIView()
        _bgView.backgroundColor = MXAppConfig.MXWhite.level1
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    private lazy var headerView : MXAddDeviceHeaderView = {
        let _headerView = MXAddDeviceHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 134))
        return _headerView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    private lazy var desLB : UILabel = {
        
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.mxSystemFont(ofSize: 14);
        _desLB.textColor = MXAppConfig.MXColor.title
        _desLB.textAlignment = .center
        
        let str = NSMutableAttributedString()
        let str1 = NSAttributedString(string: MXAppConfig.mxLocalized(key:"mx_provision_status_incorrect"), attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.primaryText])
        str.append(str1)
        let str2 = NSAttributedString(string: MXAppConfig.mxLocalized(key:"mx_try_to"), attributes: [.font: UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.theme])
        str.append(str2)
        _desLB.attributedText = str
        
        _desLB.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoIntroducePage))
        _desLB.addGestureRecognizer(tap)
        
        return _desLB
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
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_provision_status_correct"), for: .normal)
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
}

extension MXAddDeviceInitViewController {
    
    @objc func nextPage() {
        if let pairType = self.productInfo?.link_type_id, pairType == 2 {  //Wi-Fi一键配网
            self.gotoWifiPage()
        }  else {
            self.gotoSearchDevice()
        }
    }
    
    func gotoSearchDevice() {
        if let vc = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAutoSearchViewController.self)}) as? MXAutoSearchViewController {
            self.navigationController?.popToViewController(vc, animated: true)
            return
        }
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        params["ssid"] = self.wifiSSID
        params["password"] = self.wifiPassword
        if let isReplace = self.isReplace {
            params["isReplace"] = isReplace
        }
        if let replacedDevice = self.replacedDevice {
            params["replacedDevice"] = replacedDevice
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/autoSearch", params: params)
    }
    
    func gotoWifiPage() {
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        if let isReplace = self.isReplace {
            params["isReplace"] = isReplace
        }
        if let replacedDevice = self.replacedDevice {
            params["replacedDevice"] = replacedDevice
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/wifiPassword", params: params)
    }
    
    @objc func gotoIntroducePage() {
        if self.helpImageUrl != nil {
            var params = [String :Any]()
            params["imageUrl"] = self.helpImageUrl
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/addHelp", params: params)
        }
    }
}

extension MXAddDeviceInitViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceInitViewController()
        controller.networkKey = params["networkKey"] as? String
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.isReplace = params["isReplace"] as? Bool
        controller.replacedDevice = params["replacedDevice"] as? MXDeviceInfo
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
