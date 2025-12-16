//
//  MXMenuAlertView.swift
//  MXApp
//
//  Created by 华峰 on 2021/9/8.
//

import Foundation
import UIKit
public class MXMenuAlertView: UIView {
    var contentView : UIView!
    public var dataList = [MXMenuInfo]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(contentFrame:CGRect, menuList:[MXMenuInfo]) {
        self.init(frame:UIScreen.main.bounds)
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        self.dataList = menuList
        var contentH = CGFloat(self.dataList.count) * 60.0
        if contentH > 240  {
            contentH = 240
        }
        let contentW: CGFloat = contentFrame.size.width
        self.contentView = UIView(frame: CGRect.init(x: MXAppConfig.mxScreenWidth - contentW - 10, y: contentFrame.origin.y, width: contentW, height: contentH))
        self.contentView.backgroundColor = MXAppConfig.MXWhite.level4
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.layer.masksToBounds = true
        self.addSubview(self.contentView)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.all()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        //tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func hide() {
        self.removeFromSuperview()
    }
    
    public func show() {
        self.frame = UIScreen.main.bounds
        UIApplication.shared.delegate?.window?!.addSubview(self)
    }
}

extension MXMenuAlertView: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier2 = "HomeCellIdentifier2"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier2) as? MXMenuAlertCell
        if cell == nil{
            cell = MXMenuAlertCell(style: .default, reuseIdentifier: cellIdentifier2)
        }
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = .clear
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.hintLB.isHidden = true
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell?.nameLB.text = info.name
            cell?.iconLb.text = info.icon
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if let jump_url = info.jumpUrl {
                if info.isAuthorityCheck, !MXHomeManager.shard.operationAuthorityCheck() {
                    self.hide()
                    return
                }
                MXURLRouter.open(url: jump_url, params: info.params)
            } else {
                info.actionCallback?()
            }
            self.hide()
        }
    }
}

extension MXMenuAlertView : UIGestureRecognizerDelegate {
    //MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         
         let touchClass = NSStringFromClass((touch.view?.classForCoder)!)
        if let superCoder = touch.view?.superview!.superview?.classForCoder  {
            let supClass = NSStringFromClass(superCoder)
            if touchClass.hasPrefix("UITableView") || touchClass.hasPrefix("UICollectionView") ||
                supClass.hasPrefix("UITableView") || supClass.hasPrefix("UICollectionView") {
                return false
            }
        }
         return true
    }


}

class MXMenuAlertCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.iconLb)
        self.iconLb.pin.right(15).width(20).height(20).vCenter()
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.left(15).top().bottom().left(of: self.iconLb).marginRight(8)
        self.contentView.addSubview(self.hintLB)
        self.hintLB.pin.right(16).width(6).height(6).vCenter()
        self.hintLB.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconLb.pin.right(15).width(20).height(20).vCenter()
        if self.iconLb.text == nil {
            self.nameLB.pin.left(15).top().bottom().right(15).marginRight(8)
        } else {
            self.nameLB.pin.left(15).top().bottom().left(of: self.iconLb).marginRight(8)
        }
        self.hintLB.pin.right(15).width(6).height(6).vCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 16);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .left
        _nameLB.minimumScaleFactor = 0.5
        _nameLB.adjustsFontSizeToFitWidth = true
        return _nameLB
    }()
    
    lazy var iconLb : UILabel = {
        let _iconLb = UILabel(frame: .zero)
        _iconLb.font = UIFont.mxIconFont(ofSize: 20);
        _iconLb.textColor = MXAppConfig.MXColor.title;
        _iconLb.textAlignment = .right
        return _iconLb
    }()
    
    lazy var hintLB : UILabel = {
        let _hintLB = UILabel(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        _hintLB.backgroundColor = .red
        _hintLB.layer.cornerRadius = 3.0
        _hintLB.layer.masksToBounds = true
        return _hintLB
    }()
}

public class MXMenuInfo: NSObject {
    
    public typealias MXMenuActionCallBack = () -> ()
    public var actionCallback: MXMenuActionCallBack?
    
    public var name: String?
    public var icon: String?
    public var jumpUrl: String?
    public var params: [String:Any]?
    public var isAuthorityCheck: Bool = false
    
    public override init() {
        super.init()
    }
}
