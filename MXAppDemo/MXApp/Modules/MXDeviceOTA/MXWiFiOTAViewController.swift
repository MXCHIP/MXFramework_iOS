//
//  MXWiFiOTAViewController.swift
//  MXApp
//
//  Created by khazan on 2023/2/9.
//

import Foundation
import UIKit
import PinLayout

public class MXWiFiOTAViewController: MXBaseViewController {
    
    public override func gotoBack() {
        if self.status == 1 {
            let msgStr = MXAppConfig.mxLocalized(key:"mx_ota_wifi_back_des")
            let alert = MXAlertView(title: MXAppConfig.mxLocalized(key: "mx_tips"), message: msgStr, confirmButtonTitle: MXAppConfig.mxLocalized(key: "mx_confirm")) {
                self.endOTA()
            }
            alert.show()
        } else {
            endOTA()
        }
    }
    
    @objc func nextPage() {
        if self.status == 0 {
            self.startWiFiDeviceOTA()
        } else if self.status == 2 {
            self.endOTA()
        } else if self.status == 3 {
            self.startWiFiDeviceOTA()
        }
    }
    
    @objc func OTANotification(sender: Notification) -> Void {
        guard let userInfo = sender.userInfo else { return }
        if let data = userInfo["data"] as? [String: Any],
           let step = data["step"] as? Int,
           let taskIdStr = data["task_id"] as? String,
           let iotId = userInfo["device_id"] as? String {
            guard Int(taskIdStr) == self.otaInfo?.task_id,
                  iotId == self.deviceInfo?.iotId else {
                return
            }
            if step == -1 {
                self.OTAFailure()
            } else {
                let OTAPercentage = 100.0 - Double(step)
                if OTAPercentage < self.percentage {
                    self.percentage = OTAPercentage
                }
                self.viewWillLayoutSubviews()
            }
        }
    }
    
    @objc func OTAFinishNotification(sender: Notification) -> Void {
        guard let userInfo = sender.userInfo else { return }
        if let data = userInfo["data"] as? [String: Any],
           let iotId = userInfo["device_id"] as? String {
            guard iotId == self.deviceInfo?.iotId else { //只做iotId的校验
                return
            }
            self.OTASuccess()
        }
    }
    
    func endOTA() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func startWiFiDeviceOTA() -> Void {
        guard let productKey = self.deviceInfo?.productKey,
              let iotid = self.deviceInfo?.iotId,
              let task_id = self.otaInfo?.task_id
        else { return }
        
        MXAPI.OTA.startWiFiDevice(with: productKey, iotid: iotid, task_id: task_id) { data, message, code in
            if code == 0 {
                self.OTAOngoing()
            } else {
                self.OTAFailure()
            }
        }
    }
    
    func cancelWiFiDeviceOTA() -> Void {
        guard let productKey = self.deviceInfo?.productKey,
              let iotid = self.deviceInfo?.iotId,
              let task_id = self.otaInfo?.task_id
        else { return }
        
        MXAPI.OTA.cancelWiFiDevice(with: productKey, iotid: iotid, task_id: task_id) { data, message, code in
            if code == 0 {
                self.endOTA()
            } else {
                
            }
        }
    }
    
    func OTAOngoing() -> Void {
        self.status = 1
        self.contentLB.isHidden = true
        self.contentTitle.textColor = MXAppConfig.MXColor.title
        self.contentTitle.textAlignment = .center
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrading")
        self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_upgrading"), for: .normal)
        self.nextBtn.isEnabled = false
        
        self.startAnimation()
    }
    
    func OTASuccess() -> Void {
        self.status = 2
        self.contentLB.isHidden = true
        self.contentTitle.textColor = MXAppConfig.MXColor.title
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_success")
        self.contentTitle.textAlignment = .center
        self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_done"), for: .normal)
        self.nextBtn.isEnabled = true
        self.endAnimation()
    }
    
    func OTAFailure() -> Void {
        self.status = 3
        self.contentLB.isHidden = true
        self.contentTitle.textColor = MXAppConfig.MXColor.title
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_failed")
        self.contentTitle.textAlignment = .center
        self.nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_retry"), for: .normal)
        self.nextBtn.isEnabled = true
        self.endAnimation()
        
        let alert = MXAlertView(title: MXAppConfig.mxLocalized(key:"mx_upgrade_failed"), message: MXAppConfig.mxLocalized(key:"mx_upgrade_failed_desc_wifi"), confirmButtonTitle: MXAppConfig.mxLocalized(key:"mx_i_know")) {
            var params = [String : Any]()
            params["iotId"] = self.iotId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
        }
        alert.show()
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

    func endAnimation() -> Void
    {
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
        let timePercentage = (1 - sumTime / self.limiteTime) * 100
        if timePercentage < self.percentage {
            self.percentage = timePercentage
        }
        if sumTime > limiteTime {
            timeOut()
        }
        self.viewWillLayoutSubviews()
    }
    
    func timeOut() -> Void {
        OTAFailure()
    }
    
    func invalidateTimer() -> Void {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func loadRequestData() {
        MXDeviceManager.shard.requestDeviceInfo(iotId: self.iotId) { (info: MXDeviceInfo?) in
            if let device = info {
                self.deviceInfo = device
                self.showOTAInfo()
            }
        }
    }
    
    func showOTAInfo() -> Void {
        if let productImage = self.deviceInfo?.showImage{
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
        
        self.nameLB.text = self.deviceInfo?.showName
        
        self.desLB.text = MXAppConfig.mxLocalized(key:"mx_new_version") + ": V" + (self.otaInfo?.version ?? "")
        
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_version_log")
        
        self.contentLB.text = self.otaInfo?.remark
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MXAppConfig.mxLocalized(key:"mx_OTA")

        initSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OTANotification(sender:)), name: NSNotification.Name(rawValue: "WiFiOTAOngoing"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OTAFinishNotification(sender:)), name: NSNotification.Name(rawValue: "WiFiOTAFinish"), object: nil)
        
        loadRequestData()
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(self.bgView)
        bgView.backgroundColor = MXAppConfig.MXWhite.level1
        bgView.layer.cornerRadius = 16.0
        self.bgView.addSubview(self.iconView)
        iconView.backgroundColor = UIColor.clear
        iconView.contentMode = .scaleAspectFit
        nameLB.font = UIFont.mxSystemFont(ofSize: 14);
        nameLB.textColor = MXAppConfig.MXColor.title;
        nameLB.textAlignment = .center
        desLB.font = UIFont.mxSystemFont(ofSize: 14);
        desLB.textColor = MXAppConfig.MXColor.secondaryText
        desLB.textAlignment = .center
        contentTitle.font = UIFont.mxSystemFont(ofSize: 14);
        contentTitle.textColor = MXAppConfig.MXColor.secondaryText;
        contentTitle.textAlignment = .left
        contentLB.font = UIFont.mxSystemFont(ofSize: 14);
        contentLB.textColor = MXAppConfig.MXColor.secondaryText;
        contentLB.textAlignment = .left
        contentLB.isUserInteractionEnabled = false
        
        self.contentView.addSubview(self.bottomView)
        bottomView.backgroundColor = MXAppConfig.MXWhite.level1
        bottomView.layer.shadowColor = UIColor(hex: "003961", alpha: 0.08).cgColor
        bottomView.layer.shadowOffset = CGSize.zero
        bottomView.layer.shadowOpacity = 1
        bottomView.layer.shadowRadius = 8
        
        self.bottomView.addSubview(self.nextBtnBGView)
        nextBtnBGView.layer.cornerRadius = 25
        nextBtnBGView.layer.masksToBounds = true
        
        self.nextBtnBGView.addSubview(self.nextBtn)
        nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

        buttonLoadingView.backgroundColor = MXAppConfig.MXColor.theme
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextPage))
        buttonLoadingView.isUserInteractionEnabled = true
        buttonLoadingView.addGestureRecognizer(tap)
        
        if let productImage = self.deviceInfo?.showImage{
            self.iconView.sd_setImage(with: URL(string: productImage), completed: nil)
        }
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.text = self.deviceInfo?.showName
        
        self.bgView.addSubview(self.desLB)
        self.desLB.text = MXAppConfig.mxLocalized(key:"mx_new_version") + ": V" + (self.otaInfo?.version ?? "")
        
        self.bgView.addSubview(self.contentTitle)
        self.contentTitle.text = MXAppConfig.mxLocalized(key:"mx_upgrade_version_log")
        
        self.bgView.addSubview(self.contentLB)
        self.contentLB.text = self.otaInfo?.remark
        
        self.mxNavigationBar.backgroundColor = MXAppConfig.MXWhite.level1
        self.contentView.backgroundColor = MXAppConfig.MXBackgroundColor.level1
        self.bottomView.backgroundColor = MXAppConfig.MXWhite.level3
        self.bgView.backgroundColor = MXAppConfig.MXWhite.level3
        self.contentLB.backgroundColor = UIColor.clear
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
        self.buttonLoadingView.pin.left().top().bottom().right(percentage%)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let bgView : UIView = UIView(frame: .zero)
    let iconView = UIImageView(frame: .zero)
    let nameLB = UILabel(frame: .zero)
    let desLB = UILabel(frame: .zero)
    let contentTitle = UILabel(frame: .zero)
    let contentLB = UITextView(frame: .zero)
    let bottomView : UIView = UIView(frame: .zero)
    let nextBtnBGView = UIView(frame: .zero)
    let nextBtn : MXColorButton = {
        let _nextBtn = MXColorButton(type: .custom)
        _nextBtn.setTitle(MXAppConfig.mxLocalized(key:"mx_next"), for: .normal)
        _nextBtn.setBackgroundColor(color: MXAppConfig.MXColor.theme.withAlphaComponent(0.1), forState: .disabled)
        _nextBtn.setBackgroundColor(color: MXAppConfig.MXColor.theme, forState: .normal)
        return _nextBtn
    }()
    let buttonLoadingView = UIView(frame: .zero)
    
    var otaSteps = [String]()
    
    var iotId: String!
    var deviceInfo: MXDeviceInfo?
    var otaInfo: MXOTAInfo?
    /// OTA
    var status: Int = 0 //0未开始  1进行中   2成功  3失败

}

extension MXWiFiOTAViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.otaSteps.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) 
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


extension MXWiFiOTAViewController: MXURLRouterDelegate {
    
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXWiFiOTAViewController()
        controller.iotId = (params["iotId"] as? String) ?? ""
        controller.otaInfo  = params["info"] as? MXOTAInfo
        if let info = params["device"] as? MXDeviceInfo {
            controller.deviceInfo = info
        }
        return controller
    }
    
}
