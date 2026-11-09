//
//  MXDeviceOTAViewController.swift
//  MXApp
//
//  Created by 华峰 on 2021/9/13.
//

import Foundation
import SDWebImage
import UIKit
import PinLayout

public class MXDeviceOTAViewController: MXBaseViewController {
    var iotId: String!
    var deviceInfo: MXDeviceInfo?
    var otaInfo: MXOTAInfo?
    
    var device_mac : String?
    
    var otaFileName : String? = nil
    var otaFilePath : String? = nil
    
    var otaManager: MXMeshOTAHandle?
    
    var status: Int = 0 //0未开始  1进行中   2成功  3失败
    
    var stepList : [MXProvisionStepInfo] = [MXProvisionStepInfo]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_OTA")
        
        let step1 = MXProvisionStepInfo()
        step1.name = "1." + MXAppConfig.mxLocalized(key:"mx_ota_step_download")
        stepList.append(step1)
        let step2 = MXProvisionStepInfo()
        step2.name = "2." + MXAppConfig.mxLocalized(key:"mx_ota_step_connect")
        stepList.append(step2)
        let step3 = MXProvisionStepInfo()
        step3.name = "3." + MXAppConfig.mxLocalized(key:"mx_ota_step_trans")
        stepList.append(step3)
        let step4 = MXProvisionStepInfo()
        step4.name = "4." + MXAppConfig.mxLocalized(key:"mx_ota_step_upgrad")
        stepList.append(step4)
        let step5 = MXProvisionStepInfo()
        step5.name = "5." + MXAppConfig.mxLocalized(key:"mx_ota_step_finish")
        stepList.append(step5)
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        
        self.bottomView.addSubview(self.nextBtnBGView)
        self.nextBtnBGView.pin.left(16).right(16).height(50).top(10)
        nextBtnBGView.layer.cornerRadius = 25
        nextBtnBGView.layer.masksToBounds = true
        
        self.nextBtnBGView.addSubview(self.nextBtn)
        self.nextBtn.pin.all()

        buttonLoadingView.backgroundColor = MXAppConfig.MXColor.theme
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextPage))
        buttonLoadingView.isUserInteractionEnabled = true
        buttonLoadingView.addGestureRecognizer(tap)
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(78).height(78).top(50).hCenter()
        if let productImage = self.deviceInfo?.showImage {
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.below(of: self.iconView).marginTop(16).left(20).right(20).height(18)
        self.nameLB.text = self.deviceInfo?.showName
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).left(20).right(20).height(18)
        self.desLB.text = MXAppConfig.mxLocalized(key:"mx_new_version") + ": V" + (self.otaInfo?.version ?? "")
        
        self.bgView.addSubview(self.contentTitle)
        self.contentTitle.pin.below(of: self.desLB).marginTop(43).left(20).right(20).height(18)
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_version_log")
        
        self.bgView.addSubview(self.contentLB)
        self.contentLB.pin.below(of: self.contentTitle).marginTop(8).left(20).right(20).bottom(20)
        self.contentLB.text = self.otaInfo?.remark
        
        self.bgView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.contentTitle).marginTop(8).left(20).right(20).bottom(20)
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.bottomView.backgroundColor = MXAppConfig.MXWhite.level3
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        self.tableView.backgroundColor = UIColor.clear
        self.contentLB.backgroundColor = UIColor.clear
        
        self.refreshContentView()
        
        self.loadRequestData()
        
        self.downloadPackageData()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.otaManager?.OTAUpgradeFinish()
        self.otaManager = nil
        MeshSDK.sharedInstance.connect()
    }
    
    public override func gotoBack() {
        if self.status == 1 {
            let msgStr = MXAppConfig.mxLocalized(key:"mx_ota_cancel_des")
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: msgStr, leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            } rightButtonCallBack: {
                self.otaManager?.OTAUpgradeFinish()
                self.otaManager = nil
                self.endAnimation()
                self.navigationController?.popViewController(animated: true)
            }
            alert.show()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var timer: Timer!
    let timeInterval: Double = 0.001
    let limiteTime: Double = 120
    var sumTime: Double = 0
    var percentage: Double = 100

    func startAnimation() -> Void {
        if let _ = timer {
            invalidateTimer()
        }
        runTimer()
        nextBtn.isEnabled = false
        nextBtnBGView.insertSubview(self.buttonLoadingView, at: 0)
        self.sumTime = 0
        self.percentage = 100
    }

    func endAnimation() -> Void {
        invalidateTimer()
        nextBtn.isEnabled = true
        self.buttonLoadingView.removeFromSuperview()
    }
    
    func runTimer() -> Void {
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerAction(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @objc func timerAction(sender: Timer) -> Void {
        self.sumTime += timeInterval
        self.percentage = (1 - sumTime / self.limiteTime) * 100
        if sumTime > limiteTime {
            timeOut()
        }
        self.buttonLoadingView.pin.left().top().bottom().right(percentage%)
    }
    
    func timeOut() -> Void {
        endAnimation()
    }
    
    func invalidateTimer() -> Void {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        otaManager?.OTAUpgradeFinish()
        otaManager = nil
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        self.nextBtnBGView.pin.left(16).right(16).height(50).top(10)
        self.nextBtn.pin.all()
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        self.iconView.pin.width(78).height(78).top(50).hCenter()
        self.nameLB.pin.below(of: self.iconView).marginTop(16).left(20).right(20).height(18)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).left(20).right(20).height(18)
        self.contentTitle.pin.below(of: self.desLB).marginTop(43).left(20).right(20).height(18)
        self.contentLB.pin.below(of: self.contentTitle).marginTop(8).left(20).right(20).bottom(20)
        self.tableView.pin.below(of: self.contentTitle).marginTop(8).left(20).right(20).bottom(20)
        self.buttonLoadingView.pin.left().top().bottom().right(percentage%)
    }
    
    private lazy var bgView : UIView = {
        let _bgView = UIView()
        _bgView.backgroundColor = MXAppConfig.MXWhite.level1
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxSystemFont(ofSize: 14);
        _nameLB.textColor = MXAppConfig.MXColor.title;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    private lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.mxSystemFont(ofSize: 14);
        _desLB.textColor = MXAppConfig.MXColor.secondaryText
        _desLB.textAlignment = .center
        return _desLB
    }()
    
    lazy var contentTitle : UILabel = {
        let _contentTitle = UILabel(frame: .zero)
        _contentTitle.font = UIFont.mxSystemFont(ofSize: 14);
        _contentTitle.textColor = MXAppConfig.MXColor.secondaryText;
        _contentTitle.textAlignment = .left
        return _contentTitle
    }()
    
    lazy var contentLB : UITextView = {
        let _contentLB = UITextView(frame: .zero)
        _contentLB.font = UIFont.mxSystemFont(ofSize: 14);
        _contentLB.textColor = MXAppConfig.MXColor.secondaryText;
        _contentLB.textAlignment = .left
        _contentLB.isUserInteractionEnabled = false
        return _contentLB
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
    
    let nextBtnBGView = UIView(frame: .zero)
    
    lazy var nextBtn : MXColorButton = {
        let _nextBtn = MXColorButton(type: .custom)
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_next"), for: .normal)
        _nextBtn.setBackgroundColor(color: MXAppConfig.MXColor.theme.withAlphaComponent(0.1), forState: .disabled)
        _nextBtn.setBackgroundColor(color: MXAppConfig.MXColor.theme, forState: .normal)
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
    
    let buttonLoadingView = UIView(frame: .zero)
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
        
        tableView.register(MXAddDeviceStepCell.self, forCellReuseIdentifier: String(describing: MXAddDeviceStepCell.self))
        
        return tableView
    }()
}

extension MXDeviceOTAViewController {
    
    func loadRequestData() {
        MXDeviceManager.shard.requestDeviceInfo(iotId: self.iotId) { (info: MXDeviceInfo?) in
            if let device = info {
                self.deviceInfo = device
                if let uuidStr = self.deviceInfo?.uuid, uuidStr.count > 0 {
                    self.device_mac = MXMeshTool.getDeviceMacAddress(uuid: uuidStr)
                }
                DispatchQueue.main.async {
                    self.nameLB.text = device.showName
                    self.refreshContentView()
                }
            }
        }
    }
    
    func disMeshConnectAndScanDevice() {
        MeshSDK.sharedInstance.disconnect()
        self.downloadPackageData()
    }
    
    @objc func meshConnected() {
        DispatchQueue.main.async {
            self.disMeshConnectAndScanDevice()
        }
    }
    
    @objc func nextPage() {
        if self.status == 0 {
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_note"), message: MXAppConfig.mxLocalized(key: "mx_note_des"), leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            } rightButtonCallBack: {
                self.status = 1
                self.refreshContentView()
                self.disMeshConnectAndScanDevice()
                self.startAnimation()
            }
            alert.show()
            
        } else if self.status == 1 {
            let msgStr = MXAppConfig.mxLocalized(key:"mx_ota_cancel_des")
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_tips"), message: msgStr, leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            } rightButtonCallBack: {
                self.otaManager?.OTAUpgradeFinish()
                self.otaManager = nil
                self.status = 3
                self.refreshContentView()
                self.endAnimation()
            }
            alert.show()
        } else if self.status == 2 {
            self.navigationController?.popViewController(animated: true)
            self.endAnimation()
        } else if self.status == 3 {
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_note"), message: MXAppConfig.mxLocalized(key:"mx_note_des"), leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_confirm")) {
                
            } rightButtonCallBack: {
                self.status = 1
                self.refreshContentView()
                self.disMeshConnectAndScanDevice()
                self.endAnimation()
            }
            alert.show()
        }
    }
    
    
    func refreshContentView()  {
        if self.status == 1 {
            self.contentLB.isHidden = true
            self.tableView.isHidden = false
            self.contentTitle.textColor = MXAppConfig.MXColor.title
            self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_ota_progress")
            self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_upgrading"), for: .normal)
            self.nextBtn.isEnabled = false
        } else if self.status == 2 {
            self.contentLB.isHidden = true
            self.tableView.isHidden = false
            self.contentTitle.textColor = MXAppConfig.MXColor.title
            self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_ota_progress")
            self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_done"), for: .normal)
            self.nextBtn.isEnabled = true
            self.endAnimation()
        } else if self.status == 3 {
            self.contentLB.isHidden = true
            self.tableView.isHidden = false
            self.contentTitle.textColor = MXAppConfig.MXColor.title
            self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_ota_progress")
            self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_retry"), for: .normal)
            self.nextBtn.isEnabled = true
            self.endAnimation()
        } else {
            self.contentLB.isHidden = false
            self.tableView.isHidden = true
            self.contentTitle.textColor = MXAppConfig.MXColor.secondaryText
            self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_version_log")
            self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_next"), for: .normal)
            self.nextBtn.isEnabled = true
        }
    }
    
    func refreshStep(step: Int) {
        for i in 0..<self.stepList.count {
            let info = self.stepList[i]
            if i < step {
                info.status = 2
            } else if i == step {
                info.status = 1
            } else {
                info.status = 0
            }
        }
        if step >= self.stepList.count {  //升级成功
            self.status = 2
            self.refreshContentView()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func stepFail() {
        if let info = self.stepList.first(where: { $0.status == 1 }) {
            info.status = 3
        }
        self.status = 3
        DispatchQueue.main.async {
            self.refreshContentView()
            self.tableView.reloadData()
        }
    }
}

extension MXDeviceOTAViewController {
    
    func startOTA() {
        if let file_path = self.otaFilePath, let macStr = self.device_mac {
            self.otaManager = MXMeshOTAHandle(filePath: file_path, deviceMAC: macStr)
            self.otaManager?.resultCallback = { [weak self] (isSuccess: Bool) in
                if isSuccess {
                    self?.updateDeviceVersion()
                } else {
                    self?.OTAUpgradeFailer()
                }
            }
            self.otaManager?.stepCallback = { [weak self] (step: Int) in
                self?.refreshStep(step: step)
            }
        } else {
            self.OTADownloadFailer()
        }
    }
    
    func updateDeviceVersion() {
        guard let version = self.otaInfo?.version else {
            return
        }
        MXDeviceManager.shard.updateDeviceVersion(iotId: self.iotId, version: version) {
            self.refreshStep(step: 5)
        }
    }
    
    
    func downloadPackageData() {
        
        if  self.status == 1 {
            self.refreshStep(step: 0)
        }
        
        if let dataUrl = self.otaInfo?.oss_url, let ota_hash = self.otaInfo?.mxHash {
            let file_name = "\(ota_hash).bin"
            let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            let path = pathes.first!
            let localDirectory = "\(path)/firmwares/\(dataUrl.sha256())"
            let localPath = "\(localDirectory)/\(file_name)"
            let isExist = FileManager.default.fileExists(atPath: localPath)
            if !isExist {
                //下载
                try? FileManager.default.removeItem(atPath: localDirectory)
                
                guard let downloadUrl = URL(string: dataUrl) else {
                    if self.status == 1 {
                       mxAppLog("[MXOTA]: 资源文件URL格式不正确")
                        self.OTADownloadFailer()
                    }
                    return
                }
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: localDirectory), withIntermediateDirectories: true, attributes: nil)
                let request = URLRequest(url: downloadUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
                let session = URLSession.shared
                let downloadTask = session.downloadTask(with: request) { (location: URL?, response: URLResponse?, error: Error? ) in
                    if error == nil, let pathUrl = location {
                        let packageData = try? Data(contentsOf: pathUrl)
                        let isSuccess = FileManager.default.createFile(atPath: localPath, contents: packageData, attributes: nil)
                        if isSuccess {
                            self.otaFileName = file_name
                            self.otaFilePath = localPath
                            if self.status == 1 {  //OTA过程中
                                self.startOTA()
                            }
                            return
                        }
                    }
                    if self.status == 1 {
                       mxAppLog("[MXOTA]: 资源文件下载失败")
                        self.OTADownloadFailer()
                    }
                }
                downloadTask.resume()
            } else {
                self.otaFileName = file_name
                self.otaFilePath = localPath
                if self.status == 1 {  //OTA过程中
                    self.startOTA()
                }
            }
        } else {
           mxAppLog("[MXOTA]: 资源文件不存在或则缺失hash值")
            if self.status == 1 {
                self.OTADownloadFailer()
            }
        }
    }
    
    func OTAUpgradeFailer() {
        self.stepFail()
//        if let index = self.stepList.firstIndex(where: {$0.status == 3}), index == 0 {
//            self.connectFailer()
//            return
//        }
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_upgrade_failed"), message: MXAppConfig.mxLocalized(key:"mx_note_des"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_i_know")) {
            var params = [String : Any]()
            params["iotId"] = self.iotId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
        }
        alert.show()
    }
    
    func OTADownloadFailer() {
        self.OTAUpgradeFailer()
//        self.stepFail()
//        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_upgrade_failed"), message: MXAppConfig.mxLocalized(key:"mx_ota_download_fail"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_i_know")) {
//            var params = [String : Any]()
//            params["iotId"] = self.iotId
//            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
//        }
//        alert.show()
    }
}

extension MXDeviceOTAViewController:UITableViewDataSource,UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stepList.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXDeviceOTAStepCell.self)) as? MXDeviceOTAStepCell
        if cell == nil{
            cell = MXDeviceOTAStepCell(style: .default, reuseIdentifier: String (describing: MXAddDeviceStepCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        cell?.nameLeftOffSet = 0
        if self.stepList.count > indexPath.row {
            let stepInfo = self.stepList[indexPath.row]
            cell?.updateSubViews(info: stepInfo)
        }
        
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func connectFailer() {
        self.stepFail()
        let msgStr = MXAppConfig.mxLocalized(key:"mx_connect_failed_des")
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_connect_failed_title"), message: msgStr, leftButtonTitle: MXAppConfig.mxLocalized(key:"mx_cancel"), rightButtonTitle: MXAppConfig.mxLocalized(key:"mx_retry")) {
            
        } rightButtonCallBack: {
            self.disMeshConnectAndScanDevice()
        }
        alert.show()
    }
    
}

extension MXDeviceOTAViewController: MXURLRouterDelegate {
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceOTAViewController()
        controller.iotId = (params["iotId"] as? String) ?? ""
        controller.otaInfo  = params["info"] as? MXOTAInfo
        if let info = params["device"] as? MXDeviceInfo {
            controller.deviceInfo = info
        }
        return controller
    }
}

public class MXDeviceOTAStepCell: UITableViewCell {
    
    public var nameLeftOffSet: CGFloat = 72
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func updateSubViews(info:MXProvisionStepInfo) {
        self.nameLB.text = info.name
        self.statusLB.textColor = MXAppConfig.MXColor.theme
        self.statusLB.text = nil
        switch info.status {
        case 0:
            self.nameLB.textColor = MXAppConfig.MXColor.disable
            self.statusLB.text = nil
            break
        case 1:
            self.nameLB.textColor = MXAppConfig.MXColor.theme
            self.statusLB.text = "\u{e70e}"
            break
        case 2:
            self.nameLB.textColor = MXAppConfig.MXColor.theme
            self.statusLB.text = "\u{e6f4}"
            break
        case 3:
            self.nameLB.textColor = MXAppConfig.MXColor.red
            self.statusLB.textColor = MXAppConfig.MXColor.red
            self.statusLB.text = "\u{e721}"
            break
        default:
            self.nameLB.textColor = MXAppConfig.MXColor.disable
            self.statusLB.text = nil
            break
        }
        
        self.statusLB.layer.removeAllAnimations()
        if info.status == 1 {
            let animatiion = CABasicAnimation(keyPath: "transform.rotation.z")
            animatiion.fromValue = 0.0
            animatiion.toValue = 2*Double.pi
            animatiion.repeatCount = 0
            animatiion.duration = 1
            animatiion.isRemovedOnCompletion = false
            self.statusLB.layer.add(animatiion, forKey: "LoadingAnimation")
        }
        self.layoutSubviews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        
        self.contentView.addSubview(self.statusLB)
        self.statusLB.pin.right(of: self.nameLB).marginLeft(8).top().height(18).width(14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        self.nameLB.pin.sizeToFit().left(self.nameLeftOffSet).top().height(18)
        self.statusLB.pin.right(of: self.nameLB).marginLeft(8).top().height(18).width(14)
    }
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.backgroundColor = .clear
        _nameLB.font = UIFont.mxSystemFont(ofSize: 14);
        _nameLB.textColor = MXAppConfig.MXColor.disable;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    public lazy var statusLB : UILabel = {
        let _statusLB = UILabel(frame: .zero)
        _statusLB.backgroundColor = .clear
        _statusLB.font = UIFont.mxIconFont(ofSize: 14)
        _statusLB.textColor = MXAppConfig.MXColor.theme;
        _statusLB.textAlignment = .center
        return _statusLB
    }()
}
