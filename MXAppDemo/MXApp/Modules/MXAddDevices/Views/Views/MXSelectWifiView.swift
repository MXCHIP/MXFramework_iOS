//
//  MXSelectWifiView.swift
//  MXApp
//
//  Created by 华峰 on 2022/3/8.
//

import Foundation
import UIKit

open class MXSelectWifiView: UIView {
    
    public typealias DidSelectedItemCallback = (_ selectValue: String) -> ()
    public var didSelectedItemCallback : DidSelectedItemCallback!
    
    public var dataList = [String]() {
        didSet {
            var contentH = CGFloat(self.dataList.count) * 40.0 + 16
            if contentH > 216  {
                contentH = 216
            }
            let newFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: contentH)
            self.frame = newFrame
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = MXAppConfig.MXWhite.level4
        self.layer.cornerRadius = 16.0
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 8.0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 20
        
        self.addSubview(self.tableView)
        self.tableView.pin.left().right().top(8).bottom(8)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    @objc public func hide() {
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
    
    public func show() {
        if self.superview == nil {
            UIApplication.shared.delegate?.window?!.addSubview(self)
        }
    }
    
    public func showInView(view: UIView) {
        if self.superview != nil {
            self.hide()
        }
        view.addSubview(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.pin.left().right().top(8).bottom(8)
    }
}

extension MXSelectWifiView: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier2 = "HomeCellIdentifier2"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier2)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier2)
        }
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = .clear
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.textLabel?.font = UIFont.mxSystemFont(ofSize: 16)
        cell?.textLabel?.textColor = MXAppConfig.MXColor.title
        if self.dataList.count > indexPath.row {
            let name = self.dataList[indexPath.row]
            cell?.textLabel?.text = name
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let name = self.dataList[indexPath.row]
            self.didSelectedItemCallback?(name)
            self.hide()
        }
    }
}
