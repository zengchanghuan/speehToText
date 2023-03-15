//
//  ViewController.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/23.
//

import UIKit
import AgoraRtcKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var appIdTextField: UITextField!
    
    @IBOutlet weak var tokenTextFiled: UITextField!
    @IBOutlet weak var channelTextField: UITextField!
    @IBOutlet weak var languagesTextField: UITextField!
    @IBOutlet weak var aecSwitch: UISwitch!
    @IBOutlet weak var nsSwitch: UISwitch!
    @IBOutlet weak var agcSwitch: UISwitch!
    
    @IBOutlet weak var aecLabel: UILabel!
    @IBOutlet weak var ncLabel: UILabel!
    @IBOutlet weak var agcLabel: UILabel!
    
    @IBOutlet weak var channelTypeSegmentCtl: UISegmentedControl!
    
    @IBOutlet weak var languagesBtn: UIButton!
    
    
    var role:AgoraClientRole = .broadcaster
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.isHidden = true
        appIdTextField.isHidden = true
        tokenTextFiled.isHidden = true
        addressTextField.text = KeyCenter.GatewayAddress
        appIdTextField.text = KeyCenter.AppId
        tokenTextFiled.text = KeyCenter.Token
        aecSwitch.isOn = true
        nsSwitch.isOn = true
        agcSwitch.isOn = true
        // hide switches
        hideSwitches(true)
        // hide channelTypeSegmentContorl
        channelTypeSegmentCtl.isHidden = true
        
        handleCustomStyle()
        
    }
    
    private lazy var alertView: LanguageAlertView = {
        
        let view = LanguageAlertView(type: .none)
        view.didCellClosure = { [weak self] model in
            guard let tempModel = model else{
                AlertManager.hiddenView()
                return
            }
            if LanguageManager.shared.configLanguage(tempModel) == false{
                return
            }
            self?.setBtnValue()
        }
        return view
        
    }()
    
    func setBtnValue(){
        
        languagesBtn.setTitle(LanguageManager.shared.currentLanguageCode, for: .normal)
        languagesBtn.setTitleColor(UIColor.black, for: .normal)
        
        AlertManager.hiddenView()
    }
    
    func showBottomView() {
        AlertManager.show(view: alertView, alertPostion: .bottom)
    }
    
    func handleCustomStyle(){
        
        languagesTextField.isHidden = true
        languagesBtn.contentHorizontalAlignment = .left
        languagesBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        languagesBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        languagesBtn.setTitleColor(UIColor.lightGray, for: .normal)
        languagesBtn.layer.cornerRadius = 4//15
        languagesBtn.layer.borderWidth = 0.2
        languagesBtn.layer.borderColor = UIColor.lightGray.cgColor
        languagesBtn.layer.masksToBounds = true
        
    }
    
    func hideSwitches(_ hidden:Bool) {
        aecSwitch.isHidden = hidden
        nsSwitch.isHidden = hidden
        agcSwitch.isHidden = hidden
        aecLabel.isHidden = hidden
        ncLabel.isHidden = hidden
        agcLabel.isHidden = hidden
    }

    func getRoleAction(_ role: AgoraClientRole) -> UIAlertAction{
        return UIAlertAction(title: "\(role.description())", style: .default, handler: {[unowned self] action in
            self.role = role
            self.doJoin()
        })
    }
    
    func doJoin() {
        if let address = addressTextField.text {
            if !address.isEmpty {
                print("address == ",address)
                KeyCenter.GatewayAddress = address
                UserDefaults.standard.set(address, forKey: KeyCenter.kStoreAddressKey)
                UserDefaults.standard.synchronize()
            }
        }
        if let appId = appIdTextField.text {
            if !appId.isEmpty {
                print("appId == ",appId)
                KeyCenter.AppId = appId
            }
        }
        
        if let token = tokenTextFiled.text {
            if !token.isEmpty {
                print("token == ",token)
                KeyCenter.Token = token
            }
        }
        
        guard let channelName = channelTextField.text else {
            return
        }
        let newViewController = LiveStreamViewController()
        newViewController.title = channelName
        newViewController.configs = ["channelName":channelName, "role":self.role]
        newViewController.isAEC = self.aecSwitch.isOn
        newViewController.isNS = self.nsSwitch.isOn
        newViewController.isAGC = self.agcSwitch.isOn
        newViewController.channelType = channelTypeSegmentCtl.selectedSegmentIndex == 1 ? .COMMUNICATION_TYPE : .LIVE_TYPE
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    @IBAction func didClickJoinButton(_ sender: Any) {
        guard let _ = channelTextField.text else {return}
        //resign channel text field
        channelTextField.resignFirstResponder()
        
        //display role picker
        let alert = UIAlertController(title: "Pick Role", message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? UIAlertController.Style.alert : UIAlertController.Style.actionSheet)
        alert.addAction(getRoleAction(.broadcaster))
        alert.addAction(getRoleAction(.audience))
        alert.addCancelAction()
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func languageClicked(_ sender: Any) {
        
        print("click language button")
        showBottomView()
        
    }
    
    @IBAction func languageClear(_ sender: Any) {
        
        LanguageManager.shared.clearData()
        languagesBtn.setTitle("enterlanguages".L, for: .normal)
        languagesBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    @IBAction func aecValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func nsValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func aGcValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func channelTypeValueChanged(_ sender: UISegmentedControl) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.view.endEditing(true)
        if touch.tapCount >= 8 {
            addressTextField.isHidden = false
            appIdTextField.isHidden = false
            tokenTextFiled.isHidden = false
            self.hideSwitches(false)
        }
    }
}

