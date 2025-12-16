//
//  MXDeviceProvisionStepPage.swift
//  MXApp
//
//  Created by 华峰 on 2022/3/2.
//

import Foundation
import SDWebImage
import UIKit

public class MXDeviceProvisionStepPage: MXBaseViewController {

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
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB).marginTop(12).left(16).right(16).height(16)
        
        self.bgView.addSubview(self.footerView)
        self.footerView.pin.left(16).right(16).sizeToFit().bottom(16)
        
        self.bgView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.desLB).marginTop(24).left().right().above(of: self.footerView).marginTop(10)
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        
        if let info = self.currentDevice {
            self.nameLB.text = info.productInfo?.name
            if let productImage = info.productInfo?.image {
                self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
            }
        }
        //长按icon，弹出具体的Mesh失败的错误信息
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPressGes.minimumPressDuration = 5
        longPressGes.numberOfTouchesRequired = 1
        longPressGes.allowableMovement = 15
        self.iconView.isUserInteractionEnabled = true
        self.iconView.addGestureRecognizer(longPressGes)
        
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            if let errorMsg = self.currentDevice?.provisionError, errorMsg.count > 0 {
                let alert = MXAlertView(title: "", message: errorMsg, confirmButtonTitle: MXAppConfig.mxLocalized(key: "mx_confirm")) {
                    
                }
                alert.show()
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
        self.desLB.pin.below(of: self.nameLB).marginTop(12).left(16).right(16).height(16)
        self.footerView.pin.left(16).right(16).sizeToFit().bottom(16)
        self.tableView.pin.below(of: self.desLB).marginTop(24).left().right().above(of: self.footerView).marginTop(10)
    }
    
    private lazy var bgView : UIView = {
        let _bgView = UIView()
        _bgView.backgroundColor = MXAppConfig.MXWhite.level1
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    private lazy var footerView : UILabel = {
        let _desLB = UILabel(frame: CGRect(x: 0, y: 0, width: MXAppConfig.mxScreenWidth-52, height: 60))
        _desLB.backgroundColor = .clear
        _desLB.font = UIFont.mxSystemFont(ofSize: 12)
        _desLB.textColor = MXAppConfig.MXColor.secondaryText;
        _desLB.textAlignment = .left
        _desLB.numberOfLines = 0
        let str = MXAppConfig.mxLocalized(key:"mx_provision_result_tips")
        //通过富文本来设置行间距
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 4
        let attributes = [.font:UIFont.mxSystemFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.secondaryText,
                          NSAttributedString.Key.paragraphStyle: paraph]
        _desLB.attributedText = NSAttributedString(string: str, attributes: attributes)
        
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
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_i_know"), for: .normal)
        _nextBtn.addTarget(self, action: #selector(gotoBack), for: .touchUpInside)
        return _nextBtn
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.separatorStyle = .none
        
        tableView.register(MXAddDeviceStepCell.self, forCellReuseIdentifier: String(describing: MXAddDeviceStepCell.self))
        
        return tableView
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
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.mxSystemFont(ofSize: 12);
        _desLB.textColor = MXAppConfig.MXColor.secondaryText
        _desLB.text = MXAppConfig.mxLocalized(key:"mx_provision_step_detail")
        _desLB.textAlignment = .center
        return _desLB
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}


extension MXDeviceProvisionStepPage:UITableViewDataSource,UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDevice?.provisionStepList.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXAddDeviceStepCell.self)) as? MXAddDeviceStepCell
        if cell == nil{
            cell = MXAddDeviceStepCell(style: .default, reuseIdentifier: String (describing: MXAddDeviceStepCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        if let item = self.currentDevice, item.provisionStepList.count > indexPath.row {
            let stepInfo = item.provisionStepList[indexPath.row]
            cell?.updateSubViews(info: stepInfo)
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = MXProvisionStepHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.0))
        hView.backgroundColor = .clear
        return hView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let fView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.0))
        fView.backgroundColor = .clear
        return fView
    }
}

extension MXDeviceProvisionStepPage: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceProvisionStepPage()
        controller.currentDevice = params["device"] as? MXProvisionDeviceInfo
        return controller
    }
}
