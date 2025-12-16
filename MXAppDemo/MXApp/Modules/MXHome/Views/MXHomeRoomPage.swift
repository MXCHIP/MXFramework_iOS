//
//  MXRoomViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/7/19.
//

import Foundation
import UIKit

public class MXHomeRoomPage: MXBaseViewController {
    
    public var mxHeardView: MXHomeTitleView = MXHomeTitleView()
    
    var vcArray = Array<MXRoomDevicesPage>()
    var pageHeadView:MXPageHeadView?
    var pagevc:MXPageContentView?
    var currentVCIndex = 0
    var roomTitles = Array<String>()
    var currentRoomId: Int = 0
    
    let headerView = UIView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideBackItem()
        self.mxNavigationBar.backgroundColor = .clear
        self.mxNavigationBar.addSubview(self.mxHeardView)
        
        //刷新页面数据
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDataSource(notif:)), name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
        
        self.view.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.hidesBottomBarWhenPushed = false
        self.title = nil
        
        self.headerView.backgroundColor = .clear
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left().right().top(16).height(44)
        
        self.loadPageView()
        self.setupRoomData()
        self.loadDataSources()
        
        self.addGradientBackground()
    }
    
    func addGradientBackground() {
        let bgImg = UIImageView(frame: CGRect(x: 0, y: 0, width: MXAppConfig.mxScreenWidth, height: 480 * (MXAppConfig.mxScreenWidth/375)))
        bgImg.backgroundColor = .clear
        bgImg.image = UIImage(named: "mx_home_bg_image")
        bgImg.contentMode = .scaleAspectFill
        self.view.insertSubview(bgImg, at: 0)
    }
    
    public func loadDataSources() {
        MXHomeManager.shard.requestHomeList(pageNo: 1, pageSize: 199) { list in
            
        }
    }
    
    public func setupRoomData() {
        
        var pageList = [MXRoomDevicesPage]()
        var pageTitles = [String]()
        for info in MXRoomManager.shard.currentRoomList {
            if let vc = self.vcArray.first(where: {$0.roomId == info.roomId}) {
                pageTitles.append(info.name ?? "")
                pageList.append(vc)
            } else {
                pageTitles.append(info.name ?? "")
                let vc = MXRoomDevicesPage()
                vc.roomId = info.roomId
                vc.roomName = info.name
                vc.hideMXNavigationBar = true
                pageList.append(vc)
            }
        }
        
        self.roomTitles = pageTitles
        self.pageHeadView?._titles = self.roomTitles
        
        let oldId = self.vcArray.map { vc in
            return vc.roomId ?? 0
        }
        
        let newId = pageList.map { vc in
            return vc.roomId ?? 0
        }
        
        if oldId == newId {
            return
        }
        self.vcArray = pageList
        self.pagevc?.childsVCs = self.vcArray
        self.pagevc?.collectionView.reloadData()
        
        if self.vcArray.count <= 0 {
            return
        }
        
        let index = self.vcArray.firstIndex(where: {$0.roomId == self.currentRoomId}) ?? 0
        self.currentVCIndex = index
        self.pageHeadView?.scrollToItemAtIndex(index)
        self.pagevc?.scrollToPageAtIndex(index)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.setupRoomData()
        
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
        self.mxHeardView.pin.all()
        self.headerView.pin.left().right().top(16).height(44)
        self.pagevc?.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
    
    @objc func refreshDataSource(notif: Notification) {
        DispatchQueue.main.async {
            self.setupRoomData()
        }
    }
    
    // 析构函数.类似于OC的 dealloc
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadPageView()  {
        
        for v in self.headerView.subviews {
            v.removeFromSuperview()
        }
        self.pageHeadView?.removeFromSuperview()
        self.pagevc?.removeFromSuperview()
        
        var attri = MXPageHeadTextAttribute()
        attri.needBottomLine = true
        attri.defaultFontSize = 20
        attri.defaultTextColor = MXAppConfig.MXColor.secondaryText
        attri.selectedFontSize = 20
        attri.selectedTextColor = MXAppConfig.MXColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = MXAppConfig.MXColor.title
        //创建headView
        pageHeadView = MXPageHeadView (frame: CGRect (x: 0, y: 0, width: self.view.frame.size.width, height: 44), titles: roomTitles, delegate: self ,textAttributes:attri)
        pageHeadView?.backgroundColor = UIColor.clear
        self.headerView.addSubview(pageHeadView!)
        
        let frame = CGRect (x: 0, y: self.headerView.frame.size.height, width: self.view.frame.width, height: self.view.frame.size.height - pageHeadView!.frame.size.height)
        pagevc = MXPageContentView.init(frame: frame, childViewControllers: vcArray, parentViewController: self, delegate: self)
        self.contentView.addSubview(pagevc!)
        self.pagevc?.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
}

extension MXHomeRoomPage:MXPageHeadViewDelegate,MXPageViewControllerDelegate {
    
    public func mx_pageHeadViewSelectedAt(_ index: Int) {
        
        pagevc?.scrollToPageAtIndex(index)
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
            self.currentRoomId = currentVC.roomId ?? 0
            currentVC.beginAppearanceTransition(true, animated: false)
        }
        pageHeadView?.scrollToItemAtIndex(index)
    }
}
