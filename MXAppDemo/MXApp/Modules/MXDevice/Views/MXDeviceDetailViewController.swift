//
//  MXDeviceDetailViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/9/9.
//

import Foundation
import UIKit

public class MXDeviceDetailViewController: MXBaseViewController {
    
    var iotId : String!
    var info : MXDeviceInfo?
    var headerView: MXDeviceDetailHeaderView!
    
    var dataSources = [MXCellModel]()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    private lazy var redPointView : UIView = {
        let _redPointView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        _redPointView.backgroundColor = MXAppConfig.MXColor.red
        _redPointView.layer.cornerRadius = 3.0
        _redPointView.layer.masksToBounds = true
        return _redPointView
    }()
    
    func updateDataSources() {
        self.dataSources.removeAll()
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_device_id")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_product_key")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_mac")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_firmware_version")))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_device_detail")
        
        if let iot_id = self.info?.iotId {
            self.iotId = iot_id
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceUnbind(notif:)), name: NSNotification.Name(rawValue: "kDeviceUnbind"), object: nil)
        
        self.updateDataSources()
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top(12).bottom()
        
        self.headerView = MXDeviceDetailHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 100))
        if let info = self.info {
            self.headerView.refreshView(info: info)
        }
        self.tableView.tableHeaderView = self.headerView
        self.headerView.layer.cornerRadius = 16.0
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.tableView.backgroundColor = UIColor.clear
        self.headerView.backgroundColor = MXAppConfig.MXWhite.level3
        //self.loadRequestData()
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        
    }
    
    //设备解绑
    @objc func deviceUnbind(notif: Notification) {
        guard let iot_id = notif.object as? String else {
            return
        }
        if iot_id == self.iotId {
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: MXAppConfig.mxLocalized(key:"mx_device_unbind_des"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.show()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top(12).bottom()
        self.headerView.layer.cornerRadius = 16.0
    }
    
    func loadRequestData() {
        let group = DispatchGroup()
        group.enter()
        MXDeviceManager.shard.requestDeviceInfo(iotId: self.iotId) { (info: MXDeviceInfo?) in
            self.info = info
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.updateDataSources()
            self.headerView.refreshView(info: self.info!)
            self.tableView.reloadData()
        }
    }
}

extension MXDeviceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXLongPressMenuCell
        if cell == nil{
            cell = MXLongPressMenuCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.textLabel?.font = UIFont.mxSystemFont(ofSize: 16)
        cell?.textLabel?.textColor = MXAppConfig.MXColor.title
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.text = nil
        
        cell?.detailTextLabel?.font = UIFont.mxSystemFont(ofSize: 16)
        cell?.detailTextLabel?.textColor = MXAppConfig.MXColor.secondaryText
        cell?.detailTextLabel?.textAlignment = .right
        cell?.detailTextLabel?.numberOfLines = 1
        cell?.detailTextLabel?.text = nil
        cell?.canShowMenu = false
        cell?.actionBtn.isHidden = true
        
        cell?.clipsToBounds = true
        
        if self.dataSources.count > indexPath.row {
            let model = self.dataSources[indexPath.row]
            cell?.textLabel?.text = model.title
            switch model.title {
            case MXAppConfig.mxLocalized(key:"mx_device_id"):
                cell?.detailTextLabel?.text = self.info?.deviceName
                cell?.accessoryType = .none
                cell?.canShowMenu = true
                cell?.copyActionCallback = { [weak self] in
                    self?.copyDeviceName()
                }
                break
            case MXAppConfig.mxLocalized(key:"mx_product_key"):
                cell?.detailTextLabel?.text = self.info?.productKey
                cell?.accessoryType = .none
                cell?.canShowMenu = true
                cell?.copyActionCallback = { [weak self] in
                    self?.copyProductKey()
                }
                break
            case MXAppConfig.mxLocalized(key:"mx_mac"):
                cell?.detailTextLabel?.text = self.info?.mac
                cell?.accessoryType = .none
                cell?.canShowMenu = true
                cell?.copyActionCallback = { [weak self] in
                    self?.copyDeviceMac()
                }
                break
            case MXAppConfig.mxLocalized(key:"mx_firmware_version"):
                cell?.textLabel?.text = MXAppConfig.mxLocalized(key:"mx_firmware_version")
                cell?.detailTextLabel?.text = self.info?.firmware_version
                cell?.accessoryType = .none
                break
            default:
                break
            }
        }
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        header_view.backgroundColor = UIColor.clear
        
        return header_view
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        footer_view.backgroundColor = UIColor.clear
        
        return footer_view
    }
    
}

extension MXDeviceDetailViewController {
    
    //复制ID
    func copyDeviceName() {
        let past = UIPasteboard.general
        past.string = self.info?.deviceName
        
        MXToastHUD.showInfo(status: MXAppConfig.mxLocalized(key:"mx_copy_success"))
    }
    
    func copyProductKey() {
        let past = UIPasteboard.general
        past.string = self.info?.productKey
        
        MXToastHUD.showInfo(status: MXAppConfig.mxLocalized(key:"mx_copy_success"))
    }
    
    func copyDeviceMac() {
        let past = UIPasteboard.general
        if self.info?.productInfo?.node_type_v2 == "gateway" {
            past.string = self.info?.wifi_mac
        } else {
            past.string = self.info?.mac
        }
        
        MXToastHUD.showInfo(status: MXAppConfig.mxLocalized(key:"mx_copy_success"))
    }
}

extension MXDeviceDetailViewController: MXURLRouterDelegate {
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceDetailViewController()
        controller.iotId = (params["iotId"] as? String) ?? ""
        controller.info = params["device"] as? MXDeviceInfo
        return controller
    }
}
