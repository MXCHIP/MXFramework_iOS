//
//  MXLaunchedPage.swift
//  MXApp
//
//  Created by Khazan on 2021/8/10.
//

import Foundation
import UIKit

public class MXLaunchedPage: UIViewController {

    @objc func signInButtonAction(sender: UIButton) -> Void {
        let url = "com.mxchip.bta/page/account/input"
        MXURLRouter.open(url: url, params: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
    }
    
    func initSubviews() -> Void {
        
        if let bundlePath = Bundle.main.path(forResource: "signInBG", ofType: "png") {
            let image = UIImage(contentsOfFile: bundlePath)
            let bgImageView = UIImageView(image: image)
            self.view.addSubview(bgImageView)
            bgImageView.pin.all()
            bgImageView.contentMode = .scaleAspectFill
            bgImageView.clipsToBounds = true
        }
        
        self.view.addSubview(signInBtn)
        signInBtn.setBackgroundColor(color: .white, forState: .normal)
        signInBtn.setBackgroundColor(color: .white, forState: .disabled)
        signInBtn.setTitleColor(MXAppConfig.MXColor.theme, for: .normal)
        signInBtn.setTitle(MXAppConfig.mxLocalized(key: "mx_login"), for: UIControl.State.normal)
        signInBtn.addTarget(self, action: #selector(signInButtonAction(sender:)), for: UIControl.Event.touchUpInside)

        self.view.addSubview(nameLabel)
        nameLabel.text = MXAppConfig.mxLocalized(key: "mx_app_name")
        nameLabel.textColor = .white
        nameLabel.font = UIFont.mxSystemFont(ofSize: 32)
        
        self.view.addSubview(logoImageView)
        
    }
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        signInBtn.pin.bottom(176 + self.view.pin.safeArea.bottom).hCenter().width(295).height(50)
        nameLabel.pin.above(of: signInBtn).marginBottom(218).left(40).sizeToFit()
        logoImageView.pin.above(of: nameLabel, aligned: .left).marginBottom(16).width(60).height(60)
    }
    let signInBtn = MXColorButton()
    let nameLabel = UILabel()
    let logoImageView = UIImageView(image: UIImage(named: "Logo60"))
    
}

