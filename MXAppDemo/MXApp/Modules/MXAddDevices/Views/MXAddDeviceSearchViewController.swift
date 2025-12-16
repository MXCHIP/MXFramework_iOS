//
//  MXAddDeviceSearchViewController.swift
//  MXApp
//
//  Created by khazan on 2022/3/7.
//

import Foundation
import UIKit

public class MXAddDeviceSearchViewController: MXBaseViewController {
    
    @objc func cancelButtonAction(sender: UIButton) -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clearTapAction(sender: UITapGestureRecognizer) -> Void {
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key: "mx_tips"), message: MXAppConfig.mxLocalized(key: "mx_search_history_clear"), leftButtonTitle: MXAppConfig.mxLocalized(key: "mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key: "mx_confirm")) {
            
        } rightButtonCallBack: {
            
            self.clearHistory()
            self.historySource.removeAll()
            
            self.editingChanged(sender: self.searchTextField)
        }

        alert.show()
    }
    
    @objc func editingChanged(sender: UITextField) -> Void {
        guard let text = sender.text else { return }
        
        var title = ""
        var titleIsHidden = true
        
        if text.count == 0 {
            self.dataSource = self.historySource
            title = MXAppConfig.mxLocalized(key: "mx_search_history")
            titleIsHidden = dataSource.count == 0
        } else {
            self.matchSource = self.productSource.filter { (productInfo: MXProductInfo) in
                if let name = productInfo.name {
                    if name.contains(text) {
                        return true
                    }
                }
                return false
            }
            self.dataSource = self.matchSource
            title = MXAppConfig.mxLocalized(key: "mx_search_result")
            titleIsHidden = false
        }
        self.historyView.isHidden = titleIsHidden
        self.historyLabel.text = title
        self.historyLabel.sizeToFit()
        self.historyIcon.isHidden = text.count != 0
        self.tableView.reloadData()
        
        if text.count > 0 {
            if self.matchSource.count > 0 {
                self.tableView.hideEmptyView()
            } else {
                self.tableView.showEmptyView()
            }
        } else {
            self.tableView.hideEmptyView()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavViews()
        self.productSource = self.products()
        if let historySource = searchHistoryModel() {
            self.historySource = historySource
        }
        initSubViews()
        self.editingChanged(sender: self.searchTextField)
        self.searchTextField.becomeFirstResponder()
    }
    
    func initNavViews() -> Void {
        self.mxNavigationBar.addSubview(searchTextField)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        leftView.addSubview(searchIcon)
        searchIcon.text = "\u{e727}"
        searchIcon.font = UIFont.mxIconFont(ofSize: 17)
        searchIcon.textColor = MXAppConfig.MXColor.disable
        searchTextField.placeholder = MXAppConfig.mxLocalized(key: "mx_search_input_hint")
        searchTextField.backgroundColor = MXAppConfig.MXBackgroundColor.level4
        searchTextField.textColor = MXAppConfig.MXColor.title
        searchTextField.font = UIFont.mxSystemFont(ofSize:14)
        searchTextField.layer.cornerRadius = 20
        searchTextField.addTarget(self, action: #selector(editingChanged(sender:)), for: UIControl.Event.editingChanged)
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .whileEditing
        
        self.mxNavigationBar.rightItem.setTitle(MXAppConfig.mxLocalized(key: "mx_cancel"), for: .normal)
        self.mxNavigationBar.rightItem.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(self.mxNavigationBar.rightItem)
        self.mxNavigationBar.layoutSubviews()
        
        self.hideBackItem()
    }
    
    func initSubViews() -> Void {
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.contentView.addSubview(historyView)
        historyView.backgroundColor = UIColor.clear
        historyView.addSubview(historyLabel)
        historyLabel.text = MXAppConfig.mxLocalized(key: "mx_search_history")
        historyLabel.font = UIFont.mxSystemFont(ofSize:14)
        historyLabel.textColor = MXAppConfig.MXColor.secondaryText
        historyView.addSubview(historyIcon)
        historyIcon.text = "\u{e759}"
        historyIcon.font = UIFont.mxIconFont(ofSize: 17)
        historyIcon.textColor = MXAppConfig.MXColor.disable
        let clearTap = UITapGestureRecognizer(target: self, action: #selector(clearTapAction(sender:)))
        historyIcon.isUserInteractionEnabled = true
        historyIcon.addGestureRecognizer(clearTap)
        self.contentView.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MXAddDeviceSearchTableViewCell.self, forCellReuseIdentifier: "MXAddDeviceSearchTableViewCell")
        tableView.separatorStyle = .none
        let mxEmptyView = MXTitleEmptyView(frame: .zero)
        mxEmptyView.centerAlignment = false
        mxEmptyView.titleLB.text = MXAppConfig.mxLocalized(key:"mx_search_no_result")
        self.tableView.emptyView = mxEmptyView
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        searchTextField.pin.left(16).bottom(2).height(40).right(80)
        leftView.pin.width(48).height(40)
        searchIcon.pin.width(17).height(17).vCenter().right(9)
        historyView.pin.left().right().height(50)
        historyLabel.pin.left(16).vCenter().sizeToFit()
        historyIcon.pin.right(23).width(18).height(18).vCenter()
        tableView.pin.below(of: historyView).all(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        if let emptyView = tableView.emptyView {
            emptyView.pin.left().right().top(64).height(112)
        }
    }
    
    func products() -> [MXProductInfo] {
        var products = [MXProductInfo]()
        
        MXProductManager.shard.categoryList.forEach { (categoryLeve1: MXCategoryInfo) in
            categoryLeve1.categorys?.forEach({ categoryLeve2 in
                categoryLeve2.products?.forEach({ productInfo in
                    products.append(productInfo)
                })
            })
        }
        
        return products
    }
    
    func searchHistory() -> [[String: Any]]? {
        if let history = UserDefaults.standard.value(forKey: "MXUserDefaultsSearchHistory") as? [[String: Any]] {
            return history
        }
        return nil
    }
    
    func searchHistoryModel() -> [MXProductInfo]? {
        if let history = searchHistory() {
            let models = history.map { (element: [String : Any]) -> MXProductInfo in
                return MXProductInfo.mx_Decode(element) ?? MXProductInfo()
            }
            return models
        }
        
        return nil
    }
    
    func clearHistory() -> Void {
        UserDefaults.standard.removeObject(forKey: "MXUserDefaultsSearchHistory")
    }
    
    func updateSearchHistory(with product: MXProductInfo) -> Void {
        guard let pk = product.product_key else { return }
        
        var newHistory = [[String: Any]]()
        
        let productInfo: [String : Any] = ["category_id": product.category_id,
                                           "panel_type_id": product.panel_type_id,
                                           "product_key": pk,
                                           "product_type": product.product_type,
                                           "share_type": product.share_type,
                                           "sharing_mode": product.sharing_mode,
                                           "product_id": product.product_id ?? "",
                                           "name": product.name ?? "",
                                           "image": product.image ?? "",
                                           "link_type_id": product.link_type_id,
                                           "cloud_platform": product.cloud_platform]
        
        if let history = searchHistory() {
            newHistory = history.filter { (element: [String : Any]) in
                if let element_id = element["product_key"] as? String {
                    if element_id == pk {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            }
        }
        
        newHistory.append(productInfo)
        
        UserDefaults.standard.set(newHistory, forKey: "MXUserDefaultsSearchHistory")
    }
    
    
    let searchTextField: UITextField = UITextField()
    let leftView = UIView()
    let searchIcon = UILabel()
    let historyView = UIView()
    let historyLabel = UILabel()
    let historyIcon = UILabel()
    let tableView = MXBaseTableView()
    
    var productSource = [MXProductInfo]()
    var historySource = [MXProductInfo]()
    var matchSource = [MXProductInfo]()
    var dataSource = [MXProductInfo]()
    
    var roomId: Int?
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
}

extension MXAddDeviceSearchViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAddDeviceSearchViewController()
        vc.roomId = params["roomId"] as? Int
        return vc
    }
    
}

extension MXAddDeviceSearchViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}


extension MXAddDeviceSearchViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXAddDeviceSearchTableViewCell", for: indexPath) as! MXAddDeviceSearchTableViewCell
        if self.dataSource.count > indexPath.row {
            let product = self.dataSource[indexPath.row]
            cell.updateSubviews(with: ["image": product.image ?? "", "name": product.name ?? ""])
        }
        let count = self.dataSource.count
        if count == 1 {
            cell.round(with: .both, radius: 16)
        } else {
            if indexPath.row == 0 {
                cell.round(with: .top, radius: 16)
            } else if indexPath.row == count - 1{
                cell.round(with: .bottom, radius: 16)
            } else {
                cell.removeRound()
            }
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTextField.endEditing(true)
        
        if self.dataSource.count > indexPath.row {
            let product = self.dataSource[indexPath.row]
            updateSearchHistory(with: product)
            if let historySource = searchHistoryModel() {
                self.historySource = historySource
            }
            nextPage(with: product)
        }
    }
    
    func nextPage(with productInfo: MXProductInfo) -> Void {
        guard let networkKey = MXHomeManager.shard.currentHome?.networkKey else { return }
        
        var params = [String :Any]()
        params["networkKey"] = networkKey
        params["productInfo"] = productInfo
        params["roomId"] = self.roomId
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
    }
    
}

extension MXAddDeviceSearchViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
}

public class MXAddDeviceSearchTableViewCell: MXTableViewCell {
    
    public override func updateSubviews(with data: [String : Any]) {
        guard let image = data["image"] as? String,
              let name = data["name"] as? String else { return }
        
        self.productImageView.sd_setImage(with: URL(string: image), completed: nil)
        self.titleLabel.text = name
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    public func initSubViews() -> Void {
        self.contentView.backgroundColor = MXAppConfig.MXWhite.level3
        self.contentView.addSubview(productImageView)
        productImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.mxSystemFont(ofSize:16)
        titleLabel.textColor = MXAppConfig.MXColor.title
        self.contentView.addSubview(arrowLabel)
        arrowLabel.text = "\u{e6df}"
        arrowLabel.font = UIFont.mxIconFont(ofSize: 20)
        arrowLabel.textColor = MXAppConfig.MXColor.disable
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        productImageView.pin.left(16).width(40).height(40).vCenter()
        titleLabel.pin.after(of: productImageView, aligned: .center).marginLeft(16).width(200).height(20)
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
    }
    
    let productImageView = UIImageView()
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    
}
