//
//  MXAddDeviceViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/18.
//

import Foundation
import UIKit

public class MXAddDeviceViewController: MXBaseViewController {
    
    @objc func searchDevices(sender: UITapGestureRecognizer) -> Void {
        var params = [String :Any]()
        params["roomId"] = self.roomId
        let url = "com.mxchip.bta/page/device/search/search"
        
        MXURLRouter.open(url: url, params: params)
    }
    
    var vcArray = Array<UIViewController>()
    var pageHeadView:MXPageHeadView!
    var pagevc:MXPageContentView!
    var currentVCIndex = 0
    var roomId: Int?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var attri = MXPageHeadTextAttribute()
        attri.needBottomLine = true
        attri.defaultFontSize = 18
        attri.defaultTextColor = MXAppConfig.MXColor.secondaryText
        attri.selectedFontSize = 18
        attri.selectedTextColor = MXAppConfig.MXColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = MXAppConfig.MXColor.title
        attri.itemSpacing = 10
        attri.itemOffset = 0
        attri.itemWidth = 80
        
        //创建headView
        let titles = [MXAppConfig.mxLocalized(key:"mx_provision_auto"), MXAppConfig.mxLocalized(key:"mx_provision_manual")]
        pageHeadView = MXPageHeadView (frame: CGRect (x: 0, y: 2, width: 200, height: 40), titles: titles, delegate: self ,textAttributes:attri)
        let headWidth = min(200, pageHeadView.contentWidth)
        pageHeadView.backgroundColor = UIColor.clear
        self.mxNavigationBar.titleLB.addSubview(pageHeadView)
        pageHeadView.pin.width(headWidth).height(MXAppConfig.navBarH).hCenter()
        
        let searchLabel = UILabel(frame: .zero)
        self.mxNavigationBar.rightView.addSubview(searchLabel)
        searchLabel.textColor = MXAppConfig.MXColor.title
        searchLabel.font = UIFont.mxIconFont(ofSize: 24)
        searchLabel.text = "\u{e727}"
        searchLabel.pin.width(25).height(MXAppConfig.navBarH).center()
        searchLabel.isUserInteractionEnabled = true
        let tapSearch = UITapGestureRecognizer(target: self, action: #selector(searchDevices(sender:)))
        searchLabel.addGestureRecognizer(tapSearch)
        self.mxNavigationBar.layoutSubviews()
        
        let searchVC = MXAutoSearchViewController()
        searchVC.networkKey = MXHomeManager.shard.currentHome?.networkKey
        searchVC.hideMXNavigationBar = true
        searchVC.roomId = self.roomId
        vcArray.append(searchVC)
        let manualVC = MXManualViewController()
        manualVC.networkKey = MXHomeManager.shard.currentHome?.networkKey
        manualVC.hideMXNavigationBar = true
        manualVC.roomId = self.roomId
        vcArray.append(manualVC)
        
        let frame = CGRect (x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        pagevc = MXPageContentView.init(frame: frame, childViewControllers: vcArray, parentViewController: self, delegate: self)
        self.contentView.addSubview(pagevc)
        pagevc.pin.all()
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        pageHeadView.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pagevc.pin.all()
        self.pageHeadView.pin.width(200).height(40).center()
    }
    
    @objc func scanCode() {
        
    }
}

extension MXAddDeviceViewController:MXPageHeadViewDelegate,MXPageViewControllerDelegate {
    
    public func mx_pageHeadViewSelectedAt(_ index: Int) {
        
        pagevc.scrollToPageAtIndex(index)
    }
    
    public func mx_pageControllerSelectedAt(_ index: Int) {
        
        guard index != self.currentVCIndex else{ return }
        
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.beginAppearanceTransition(false, animated: false)
        }
        self.currentVCIndex = index
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.beginAppearanceTransition(true, animated: false)
        }
        pageHeadView.scrollToItemAtIndex(index)
    }
}

extension MXAddDeviceViewController: MXURLRouterDelegate {
    public static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAddDeviceViewController()
        vc.roomId = params["roomId"] as? Int
        return vc
    }
}
