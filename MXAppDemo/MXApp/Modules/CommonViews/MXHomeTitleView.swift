//
//  HomeTitleView.swift
//  MXApp
//
//  Created by 华峰 on 2021/7/13.
//

import Foundation
import PinLayout
import UIKit

public class MXHomeTitleView: UIView {

    var homeButton = UIButton()
    var addButton = MXHintButton()
    var remindButton = MXHintButton()
    
    @objc func remindButtonAction(sender: UIButton) -> Void {
        MXURLRouter.open(url: "https://com.mxchip.bta/page/mine/messageCenter", params: nil)
    }
    
    @objc func addButtonAction(sender: UIButton) -> Void {
        var menu_list = [MXMenuInfo]()
        if MXHomeManager.shard.operationAuthorityCheck() {
            let menuInfo = MXMenuInfo()
            menuInfo.name = MXAppConfig.mxLocalized(key:"mx_add_device")
            menuInfo.icon = "\u{e857}"
            menuInfo.jumpUrl = "https://com.mxchip.bta/page/device/search"
            menuInfo.isAuthorityCheck = true
            menu_list.append(menuInfo)
        }
        let contentW: CGFloat = 180
        let menuAlertView = MXMenuAlertView(contentFrame: CGRect(x: UIScreen.main.bounds.width - contentW - 10, y: 88, width: contentW, height: 120), menuList: menu_list)
        menuAlertView.show()
    }
    
    @objc func homeNameChange() {
        DispatchQueue.main.async {
            var homeName = MXAppConfig.mxLocalized(key: "mx_my_family")
            if let currentName = MXHomeManager.shard.currentHome?.name  {
                homeName = currentName
            }
            let titleStr = NSMutableAttributedString()
            let nameStr = NSAttributedString(string: homeName, attributes: [.font: UIFont.mxSystemFont(ofSize: 18, weight: .medium),.foregroundColor:MXAppConfig.MXColor.title])
            titleStr.append(nameStr)
            let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.mxIconFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.primaryText,.baselineOffset:2])
            titleStr.append(iconStr)
            self.homeButton.setAttributedTitle(titleStr, for: .normal)
            let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
            self.homeButton.pin.left(16).width(homeNameWidth).height(44).top(MXAppConfig.statusBarH)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //家庭切换了
        NotificationCenter.default.addObserver(self, selector: #selector(homeNameChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        self.initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = UIColor.clear
        
        homeButton = UIButton(frame: CGRect(x: 20, y: MXAppConfig.statusBarH, width: 80, height: 44))
        let titleStr = NSMutableAttributedString()
        let nameStr = NSAttributedString(string: MXAppConfig.mxLocalized(key: "mx_my_family"), attributes: [.font: UIFont.mxSystemFont(ofSize: 18, weight: .medium),.foregroundColor:MXAppConfig.MXColor.title])
        titleStr.append(nameStr)
        let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.mxIconFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.primaryText,.baselineOffset:2])
        titleStr.append(iconStr)
        homeButton.setAttributedTitle(titleStr, for: .normal)
        let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
        self.addSubview(homeButton)
        self.homeButton.pin.left(16).width(homeNameWidth).height(44).top(MXAppConfig.statusBarH)
        
        addButton.titleLabel?.font = UIFont.mxIconFont(ofSize: 24)
        addButton.setTitle("\u{e6db}", for: .normal)
        addButton.setTitleColor(MXAppConfig.MXColor.title, for: .normal)
        self.addSubview(addButton)
        addButton.pin.right(10).top(MXAppConfig.statusBarH).bottom().width(28)
        addButton.addTarget(self, action: #selector(addButtonAction(sender:)), for: .touchUpInside)
        self.addButton.isHidden = false
        
        remindButton.titleLabel?.font = UIFont.mxIconFont(ofSize: 24)
        remindButton.setTitle("\u{e6dc}", for: .normal)
        remindButton.setTitleColor(MXAppConfig.MXColor.title, for: .normal)
        self.addSubview(remindButton)
        remindButton.pin.left(of: addButton).marginRight(4).top(MXAppConfig.statusBarH).bottom().width(28)
        remindButton.addTarget(self, action: #selector(remindButtonAction(sender:)), for: .touchUpInside)
        self.remindButton.isHidden = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.addButton.pin.right(10).top(MXAppConfig.statusBarH).bottom().width(44)
        self.remindButton.pin.left(of: addButton).marginRight(4).top(MXAppConfig.statusBarH).bottom().width(44)
        
        var homeName = MXAppConfig.mxLocalized(key: "mx_my_family")
        if let currentName = MXHomeManager.shard.currentHome?.name  {
            homeName = currentName
        }
        let titleStr = NSMutableAttributedString()
        let nameStr = NSAttributedString(string: homeName, attributes: [.font: UIFont.mxSystemFont(ofSize: 18, weight: .medium),.foregroundColor:MXAppConfig.MXColor.title])
        titleStr.append(nameStr)
        let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.mxIconFont(ofSize: 12),.foregroundColor:MXAppConfig.MXColor.primaryText,.baselineOffset:2])
        titleStr.append(iconStr)
        self.homeButton.setAttributedTitle(titleStr, for: .normal)
        let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
        self.homeButton.pin.left(16).width(homeNameWidth).height(44).top(MXAppConfig.statusBarH)
    }
    
}

open class MXHintButton: UIButton {
    
    var hintLB = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.hintLB.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        self.hintLB.backgroundColor = .red
        self.hintLB.layer.cornerRadius = 3.0
        self.hintLB.layer.masksToBounds = true
        self.addSubview(self.hintLB)
        self.hintLB.pin.top(8).right(0).width(6).height(6)
        self.hintLB.isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.hintLB.pin.top(8).right(0).width(6).height(6)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
