//
//  MXBridgeWebViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/23.
//

import Foundation
import UIKit
import WebKit
import dsBridge
import ZipArchive

public class MXBridgeWebViewController: UIViewController {
    
    public var homeId : Int = 0
    public var networkKey : String = ""
    
    public var device: MXDeviceInfo?
    
    public var testUrl : String?
    
    var file_md5: String?
    var local_file_md5 : String?
    var localH5VersionKey : String!
    
    var devicePage : MXBridgeDeviceApi?
    var apiPage : MXBridgePageApi?
    var requestApi : MXBridgeRequestApi?
    
    var webview : DWKWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //订阅通知回调
        self.subscribeNotification()
        
        self.localH5VersionKey = "MX_H5Version_" + (self.device?.productKey ?? "")
        self.local_file_md5 = UserDefaults.standard.value(forKey: self.localH5VersionKey) as? String
        
        //创建wkwebview
        let _webview = DWKWebView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height),configuration: WKWebViewConfiguration())
        //_webview.allowsBackForwardNavigationGestures = true
        _webview.configuration.preferences.setValue(1, forKey: "allowFileAccessFromFileURLs")
        _webview.configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        _webview.configuration.preferences.javaScriptEnabled = true;
        _webview.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true;
        
        if #available(iOS 11, *) {
            _webview.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        }
        _webview.scrollView.showsVerticalScrollIndicator = false
        _webview.scrollView.showsHorizontalScrollIndicator = false
        _webview.scrollView.bounces = false
        _webview.dsuiDelegate = self
        _webview.navigationDelegate = self
        self.webview = _webview
        
        self.view.backgroundColor = .white
        let group = DispatchGroup()
        group.enter()
        self.webview?.evaluateJavaScript("navigator.userAgent") { [weak self] (result: Any?, error: Error?) in
            let oldUA = (result as? String) ?? ""
            let appBuildID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
            let language = MXAccountModel.shared.language
            var userInterfaceStyleString = "light"
            if #available(iOS 13, *) {
                userInterfaceStyleString = (UITraitCollection.current.userInterfaceStyle == .dark) ? "dark" : "light"
            }
            let newUA = "\(oldUA) mxchip app/\(appBuildID) lang/\(language) theme/\(userInterfaceStyleString) productType/\(self?.device?.productInfo?.product_type ?? 0))"
           mxAppLog("[MXWeb]: UA = \(newUA)")
            self?.webview?.customUserAgent = newUA
            group.leave()
        }
        self.view.addSubview(self.webview)
        self.webview.pin.all()
        
        self.view.addSubview(self.progress)
        
        if let uuid = self.device?.uuid, uuid.count > 0  {
            let device_api = MXBridgeMeshDeviceApi()
            device_api.remoteStatus = self.device?.isOnline ?? false
            device_api.networkKey = self.networkKey
            device_api.device = self.device
            self.devicePage = device_api
        } else {
            let device_api = MXBridgeDeviceApi()
            device_api.remoteStatus = self.device?.isOnline ?? false
            device_api.device = self.device
            self.devicePage = device_api
        }
        
        self.apiPage = MXBridgePageApi.init()
        self.apiPage?.device = self.device
        self.apiPage?.navigationController = self.navigationController
        self.apiPage?.navigationItem = self.navigationItem
        self.apiPage?.needRloadHomeListBlock = { [weak self] () in
            var obj = [String : Any]()
            var roomList = [Int]()
            if let roomId = self?.device?.roomId {
                roomList.append(roomId)
            }
            obj["roomId"] = roomList
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomReSourcesChange"), object: obj)
        }
        self.apiPage?.closeWebViewBlock = { [weak self] () in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.requestApi = MXBridgeRequestApi.init()
        self.requestApi?.networkKey = self.networkKey

        
        self.webview.addJavascriptObject(self.devicePage, namespace: "device")
        self.webview.addJavascriptObject(self.apiPage, namespace: "page")
        self.webview.addJavascriptObject(self.requestApi, namespace: "request")
        
        group.notify(queue: DispatchQueue.main) {
            if let url = self.testUrl, url.count > 0  {
                var htmlURLStr = "http://\(url)?"
                htmlURLStr = htmlURLStr + "iotId=\(self.device?.iotId ?? "")&homeId=\(self.homeId)&productKey=\(self.device?.productKey ?? "")&isOwner=\(self.device?.isShare ?? false ? 0 : 1)&category_id=\(self.device?.category_id ?? 0)&app=\(MXAppConfig.mxAppType)"
                if let fastIndex = self.device?.fastIndex {
                    htmlURLStr = htmlURLStr + "&fastIndex=\(fastIndex)"
                }
                htmlURLStr = htmlURLStr + "#/"
                if self.device?.fastIndex != nil {
                    htmlURLStr = htmlURLStr + "fast"
                }
                self.webview.loadUrl(htmlURLStr)
            } else {
                self.checkH5Version()
            }
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webview.pin.all()
        self.progress.pin.left().right().top(MXAppConfig.statusBarH).height(2.0)
    }
    
    public lazy var progress :UIProgressView = {
        
        let _progress = UIProgressView(frame: CGRect(x: 0, y: MXAppConfig.statusBarH, width: self.view.frame.size.width, height: 2.0))
        _progress.progressTintColor = MXAppConfig.MXColor.theme
        _progress.trackTintColor = UIColor.gray
        _progress.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        _progress.isHidden = true
        return _progress
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        let newInfo = ["type": "cycle", "data": "viewWillAppear"] as [String : Any]
        self.devicePage?.hanlder?(newInfo, false)
        //self.webview.reload()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        webview?.removeJavascriptObject("page")
        webview?.removeJavascriptObject("device")
        webview?.removeJavascriptObject("request")
        webview?.removeObserver(self, forKeyPath: "estimatedProgress")
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if keyPath == "estimatedProgress" {
                if (object as? DWKWebView) == self.webview{
                    self.progress.isHidden = false
                    self.progress.alpha = 1.0
                    let pValue = self.webview.estimatedProgress
                    self.progress.setProgress(Float(pValue), animated: true)
                    if pValue >= 1.0 {
                        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
                            self.progress.alpha = 0.0
                        } completion: { (finished: Bool) in
                            self.progress.setProgress(0.0, animated: false)
                            self.progress.isHidden = true
                        }

                    }
                    
                } else {
                    super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                }
            }
        }
    }
}

extension MXBridgeWebViewController {
    
    func checkH5Version() {
        guard let pk = self.device?.productKey else {
            self.showErrorMsg()
            return
        }
        MXToastHUD.show()
        MXAPI.product.h5PlanVersion(productKey: pk) { (data: Any, message: String, code: Int) in
            if code == 0 {
                if let dataDic = data as? [String : Any] {
                    if let H5Vetsion = dataDic["md5"] as? String {  //改成根据md5校验码验证
                        self.file_md5 = H5Vetsion
                        if let downloadUrl = dataDic["url"] as? String {
                            self.downloadHtmlData(urlStr: downloadUrl)
                            return
                        }
                    }
                }
            }
            MXToastHUD.dismiss()
            if self.local_file_md5 == nil {
                self.showErrorMsg()
            } else {
                self.loadWebView()
            }
        }
    }
    
    func showErrorMsg() {
        let alert = UIAlertController(title: nil, message: MXAppConfig.mxLocalized(key:"mx_web_load_fail"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: MXAppConfig.mxLocalized(key:"mx_exit"), style: .cancel) { (action:UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        let comfirmAction = UIAlertAction(title: MXAppConfig.mxLocalized(key:"mx_retry"), style: .default) { (action:UIAlertAction) in
            self.checkH5Version()
        }
        alert.addAction(cancelAction)
        alert.addAction(comfirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func downloadHtmlData(urlStr: String) {
        let url = URL(string: urlStr)!
        let dataPath = "mxchip_h5_" + (self.device?.productKey ?? "") + "_" + (self.file_md5 ?? "")
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let finishPath = "\(path)/zipDownload/\(dataPath)"
        let zipPath = "\(path)/\(dataPath).zip"
        let isExist = FileManager.default.fileExists(atPath: finishPath)
        if isExist {
            self.local_file_md5 = self.file_md5
            UserDefaults.standard.setValue(self.local_file_md5, forKey: self.localH5VersionKey)
            DispatchQueue.main.async {
                MXToastHUD.dismiss()
                self.loadWebView()
            }
        } else {
            DispatchQueue.global(qos: .default).async {
                
                guard let data = try? Data(contentsOf: url) else {
                    DispatchQueue.main.async {
                        MXToastHUD.dismiss()
                        self.showErrorMsg()
                    }
                    return
                }
                try? data.write(to: URL(fileURLWithPath: zipPath))
                let zip = ZipArchive()
                if  zip.unzipOpenFile(zipPath) {
                    let ret = zip.unzipFile(to: finishPath, overWrite: true)
                    zip.unzipCloseFile()
                    if ret {
                        try? FileManager.default.removeItem(atPath: zipPath)
                        if self.local_file_md5 != nil, self.local_file_md5 != self.file_md5  {
                            let oldPath = "mxchip_h5_" + (self.device?.productKey ?? "") + "_" + (self.local_file_md5 ?? "")
                            try? FileManager.default.removeItem(atPath: "\(path)/zipDownload/\(oldPath)")
                        }
                        self.local_file_md5 = self.file_md5
                        UserDefaults.standard.setValue(self.local_file_md5, forKey: self.localH5VersionKey)
                    } else {
                       mxAppLog("[MXWebBridge]: 解压失败")
                        try? FileManager.default.removeItem(atPath: finishPath)
                    }
                    DispatchQueue.main.async {
                        MXToastHUD.dismiss()
                        self.loadWebView()
                    }
                } else {
                    DispatchQueue.main.async {
                        MXToastHUD.dismiss()
                        self.loadWebView()
                    }
                }
            }
        }
    }
    
    func loadWebView() {
        DispatchQueue.main.async {
            let dataPath = "mxchip_h5_" + (self.device?.productKey ?? "") + "_" + (self.local_file_md5 ?? "")
            let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            let path = pathes.first!
            let finishPath = "\(path)/zipDownload/\(dataPath)"
            if !FileManager.default.fileExists(atPath: finishPath) { //如果文件不存在，清空沙盒存储的面板信息
                UserDefaults.standard.removeObject(forKey: self.localH5VersionKey)
                self.local_file_md5 = nil
                MXToastHUD.dismiss()
                self.showErrorMsg()
                return
            }
            let rootAppURL = URL(fileURLWithPath: path, isDirectory: true)
            var htmlURLStr = "file://\(finishPath)/dist/index.html?"
            htmlURLStr = htmlURLStr + "iotId=\(self.device?.iotId ?? "")&homeId=\(self.homeId)&productKey=\(self.device?.productKey ?? "")&isOwner=\(self.device?.isShare ?? false ? 0 : 1)&category_id=\(self.device?.category_id ?? 0)&app=\(MXAppConfig.mxAppType)"
            
            if let fastIndex = self.device?.fastIndex {
                htmlURLStr = htmlURLStr + "&fastIndex=\(fastIndex)"
            }
            
            htmlURLStr = htmlURLStr + "#/"
            if self.device?.fastIndex != nil {
                htmlURLStr = htmlURLStr + "fast"
            }
            if let htmlUrl = URL(string: htmlURLStr) {
                self.webview.loadFileURL(htmlUrl, allowingReadAccessTo: rootAppURL)
            } else {
                self.showErrorMsg()
            }
            
        }
    }
    
}

extension MXBridgeWebViewController {
    
    func subscribeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceStatusChangeRemote(notif:)), name: NSNotification.Name(rawValue: "kDeviceRemoteStatusChange"), object: nil)
        if let uuidStr = self.device?.uuid, uuidStr.count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromLocate"), object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeRemote(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromRemote"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceUnbind(notif:)), name: NSNotification.Name(rawValue: "kDeviceUnbind"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceEventRemote(notif:)), name: NSNotification.Name(rawValue: "kDeviceEventFromRemote"), object: nil)
        
        //切后台回来，需要刷新列表数据，避免mqtt数据不同步的问题
        NotificationCenter.default.addObserver(self, selector: #selector(deviceFullProperties), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    //设备事件
    @objc func deviceEventRemote(notif: Notification) {
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let iot_id = dic["iotId"] as? String, iot_id == self.device?.iotId else {
            return
        }
        let result = ["type":"event","data":dic] as [String : Any]
        self.devicePage?.hanlder?(result, false)
    }
    
    //设备解绑
    @objc func deviceUnbind(notif: Notification) {
        guard let iot_id = notif.object as? String else {
            return
        }
        if iot_id == self.device?.iotId {
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: MXAppConfig.mxLocalized(key:"mx_device_unbind_des"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                self.navigationController?.popViewController(animated: true)
            }
            alert.show()
        }
    }
    
    @objc func deviceStatusChangeRemote(notif: Notification) {
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let iot_id = self.device?.iotId, let value = dic[iot_id] as? Bool  else {
            return
        }
        self.devicePage?.remoteStatus = value
        self.devicePage?.refreshDeviceStatus()
    }
    
    //mesh连接状态变化
    @objc func meshConnectChange(notif: Notification) {
        self.devicePage?.refreshDeviceStatus()
    }
    
    //云端消息
    @objc func devicePropertyChangeRemote(notif: Notification) {
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let iotId = self.device?.iotId, let curReceiv = dic[iotId] as? [String : Any]  else {
            return
        }
        self.devicePage?.remoteDeviceProperty(result: curReceiv)
    }
    
    //本地消息
    @objc func devicePropertyChangeLocate(notif: Notification) {
        guard let uuidStr = self.device?.uuid, uuidStr.count > 0 else {
            return
        }
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let msgDict = dic[uuidStr] as? [String : Any]  else {
            return
        }
        if let deviceApi = self.devicePage as? MXBridgeMeshDeviceApi {
            deviceApi.localDeviceProperty(result: msgDict)
        }
    }
    
    //云端获取设备全属性
    @objc func deviceFullProperties() {
        guard let iot_id = self.device?.iotId, (self.device?.isOnline ?? false) else {
            return
        }
        MXAPI.device.getProperties(iotId: iot_id) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any]{
                    self.devicePage?.remoteDeviceProperty(result: dict)
                }
            }
        }
    }
}

extension MXBridgeWebViewController: WKNavigationDelegate {
    
    func clearWebViewCacheReload() {
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast) { [weak self] in
           mxAppLog("[MXWeb]: WebView Cache Cleared")
            self?.loadWebView()
        }
    }
    
    //进程终止(内存消耗过大导致白屏)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
       mxAppLog("[MXWeb]: 内存消耗过大，重新导入")
        self.clearWebViewCacheReload()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
       mxAppLog("[MXWeb]: 加载失败，重新导入")
        self.clearWebViewCacheReload()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       mxAppLog("[MXWeb]: 加载失败，重新导入")
        self.clearWebViewCacheReload()
    }
}

extension MXBridgeWebViewController: WKUIDelegate, MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXBridgeWebViewController()
        controller.homeId = params["homeId"] as? Int ?? 0
        controller.networkKey = params["networkKey"] as? String ?? ""
        controller.testUrl = params["testUrl"] as? String
        if let device = params["device"] as? MXDeviceInfo {
            controller.device = device
        }
        return controller
    }
}
