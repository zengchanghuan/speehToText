//
//  RestfulManager.swift
//  APIExample
//
//  Created by FanPengpeng on 2022/3/21.
//  Copyright © 2022 Agora Corp. All rights reserved.
//

import UIKit
import SVProgressHUD

private let kTokenNamekey = "kTokenNamekey"
private let kTaskIDkey = "kTaskIDkey"

class RestfulManager: NSObject {
    
    private var timeOutClourse:(()->Void)?
    private let limitTime:TimeInterval = 600
    lazy var timer:Timer? = {
        let timer = Timer(timeInterval: 0.1, repeats: true) { t in
            self.timeOut()
        }
        RunLoop.main.add(timer, forMode: .default)
        timer.fireDate = Date.distantFuture
        return timer
    }()
    
    // Ensure that only one task can appear on the same channel at the same time for these two uids
    static let audioUid:UInt = 1000
    static let dataStreamUid:UInt = 2000
    
    private var taskId:String? {
        didSet{
            UserDefaults.standard.set(taskId, forKey: kTaskIDkey)
            UserDefaults.standard.synchronize()
        }
    }
    private var tokenName:String?{
        didSet{
            UserDefaults.standard.set(tokenName, forKey: kTokenNamekey)
            UserDefaults.standard.synchronize()
        }
    }
    private var expireDate:Date?
    
    static let shared = RestfulManager()
    private override init() {}
    
    // get token
    func getBuilderToken(_ channel:String,completion:((String)->Void)?) {
        if tokenName != nil && self.tokenIsExpired() == false {
            completion?(tokenName!)
            return
        }
        acquire(channel,completion: completion)
    }
    
    // retset
    private func reset(){
        taskId = nil
        tokenName = nil
        expireDate = nil
    }
    
    // Determine whether the token has expired
    private func tokenIsExpired() -> Bool {
        let isExpired = self.expireDate?.timeIntervalSinceNow ?? 0 <= 0
        return isExpired
    }
    
    // Get the latest token
    private func acquire(_ channel:String,completion:((String)->Void)?) {
        let Address = KeyCenter.GatewayAddress
        let AppId = KeyCenter.AppId
        let urlString = Address + "/v1/projects/"+AppId+"/rtsc/speech-to-text/builderTokens"
        guard let url = URL(string: urlString) else { return  }
        
//        print("url ==",url)
        
        let request = NSMutableURLRequest(url: url)
        configCommonHeader(request)
//        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        let params = "{\"instanceId\":\"\(channel)\"}"
        request.httpMethod = "POST"
        request.httpBody = params.data(using: .utf8)
        let httpTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error == nil {
                let json:[String:Any]? = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : Any]
                let tokenName:String = json?["tokenName"] as? String ?? ""
                let createTs:Int? = json?["createTs"] as? Int
                print("tokenName == ",tokenName,"json ===",json?.debugDescription ?? "" )
                self.tokenName = tokenName
                completion?(tokenName)
                if createTs != nil {
                    self.expireDate = Date(timeIntervalSince1970: TimeInterval(createTs! + 5 * 60))
                }
                
                self.showErrorAlert(json)

            }
        }
        httpTask.resume()
    }
    
    @objc private func timeOut(){
        stop { err in
            if err == nil {
                self.timeOutClourse?()
            }
        }
    }
    
    // Turn on speech-to-text
    func start(channelName:String,uid:String,token:String = "",channelType:String = "LIVE_TYPE", completion:((_ status:String,_ err:Error?,_ json:String?)->Void)?, timeOut:@escaping ()->Void) {
        
        let Address = KeyCenter.GatewayAddress
        let AppId = KeyCenter.AppId
        var language = LanguageManager.shared.currentSysLanguage().code
        if LanguageManager.shared.currentLanguageCode != ""{
            language = LanguageManager.shared.currentLanguageCode
        }
        
        reset()
        self.timeOutClourse = timeOut
        self.getBuilderToken(channelName, completion: { tokenName in
            let urlString = Address + "/v1/projects/"+AppId+"/rtsc/speech-to-text/tasks?builderToken=" + tokenName
            
            guard let url = URL(string: urlString) else { return  }
            let params = "{\"audio\": {\"subscribeSource\": \"AGORARTC\",\"agoraRtcConfig\": {\"channelName\": \"\(channelName)\",\"uid\": \"\(RestfulManager.audioUid)\",\"token\": \"\(token)\",\"channelType\": \"\(channelType)\",\"subscribeConfig\": {\"subscribeMode\": \"CHANNEL_MODE\"},\"maxIdleTime\": 60}},\"config\": {\"features\": [\"RECOGNIZE\"],\"recognizeConfig\": {\"language\": \"\(language)\",\"model\": \"Model\",\"connectionTimeout\": 60,\"output\": {\"destinations\": [\"AgoraRTCDataStream\"],\"agoraRTCDataStream\": {\"channelName\": \"\(channelName)\",\"uid\": \"\(RestfulManager.dataStreamUid)\",\"token\": \"\(token)\"}}}}}"

            print("url ==",url)
            print("params ===",params)
            
            let request = NSMutableURLRequest(url: url)
            self.configCommonHeader(request)
//            request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = params.data(using: .utf8)
            let httpTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error == nil {
                    let json:[String:Any]? = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : Any]
                    let taskId:String = json?["taskId"] as? String ?? ""
                    let status:String = json?["status"] as? String ?? ""
                    print("taskId == ",taskId,"status == ",status,"json ==",json ?? "")
                    self.taskId = taskId
                    DispatchQueue.main.async {
                        completion?(status,nil,json?.debugDescription)
                    }
                }else{
                    DispatchQueue.main.async {
                        completion?("",error,nil)
                    }
                }
                self.timer?.fireDate = Date(timeIntervalSinceNow: self.limitTime)
            }
            httpTask.resume()
        })
    }
    
    // Query speech-to-text status
    func query() {
        guard let tokenName = self.tokenName else {
            print("token is nil")
            return
        }
        
        guard let taskId = self.taskId else {
            print("taskId is nil")
            return
        }
        
        let Address = KeyCenter.GatewayAddress
        let AppId = KeyCenter.AppId
        
        let urlString = Address + "/v1/projects/"+AppId+"/rtsc/speech-to-text/tasks/" + taskId+"?builderToken=" + tokenName
        guard let url = URL(string: urlString) else { return  }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        let httpTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error == nil {
                let json:[String:Any]? = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : Any]
                let taskId:String = json?["taskId"] as? String ?? ""
                let status:String = json?["status"] as? String ?? ""
                print("taskId == ",taskId,"status = ",status)
                self.taskId = taskId
                
                self.showErrorAlert(json)
                
            }
        }
        httpTask.resume()
    }
    
    private func realStop(tokenName:String, taskId:String,completion:((_ err:Error?)->Void)?) {
        let Address = KeyCenter.GatewayAddress
        let AppId = KeyCenter.AppId
        let urlString = Address + "/v1/projects/"+AppId+"/rtsc/speech-to-text/tasks/" + taskId+"?builderToken=" + tokenName
        guard let url = URL(string: urlString) else { return  }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "DELETE"
        configCommonHeader(request)
//        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpTask = URLSession.shared.dataTask(with: request as URLRequest) {[weak self] data, response, error in
            if error == nil {
                let json:[String:Any]? = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : Any]
                print("json ==",json?.debugDescription ?? "")
                self?.taskId = taskId
                print("-------stoped-------")
                
                self?.showErrorAlert(json)
            }
            DispatchQueue.main.async {
                completion?(error)
            }
        }
        httpTask.resume()
    }
    
    // stop speech-to-text
    func stop(completion:((_ err:Error?)->Void)?) {
        self.timer?.fireDate = Date.distantFuture
        guard let tokenName = self.tokenName else {
            print("token is nil")
            return
        }
        guard let taskId = self.taskId else {
            print("taskId is nil")
            return
        }
        self.realStop(tokenName: tokenName, taskId: taskId, completion: completion)
    }
    
    func stopOldTask() {
        guard let tokenName = UserDefaults.standard.string(forKey: kTokenNamekey) else { return }
        guard let taskId = UserDefaults.standard.string(forKey: kTaskIDkey) else {return }
        self.realStop(tokenName: tokenName, taskId: taskId, completion: nil)
        
    }
    
    //Configure the general parameters of the request header
    func configCommonHeader(_ request : NSMutableURLRequest) {
        
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic " + getAuthorizationText(), forHTTPHeaderField: "Authorization")
        
    }
    
    func showErrorAlert(_ json:[String:Any]?){
        
        if let msg = json?["message"] as? String ,msg == "Invalid authentication credentials"{
            DispatchQueue.main.async {
                SVProgressHUD.showInfo(withStatus: "\(msg)")
            }
        }
    }
    
    //Get Authorization Base64 encoding
    func getAuthorizationText()-> String {
        
        if let storedAuthBase64Str = UserDefaults.standard.string(forKey: KeyCenter.kAuthorizationBase64Key) {
            
            return storedAuthBase64Str
            
        }else{
            
            let plainCredentials = KeyCenter.customerKey + ":" + KeyCenter.customerSecret
            let authData = plainCredentials.data(using: .utf8)
            
            guard let base64Credentials = authData?.base64EncodedString(options: .endLineWithLineFeed) else {
                print("Transfer to base64 failed")
                return ""
            }
            UserDefaults.standard.set(base64Credentials, forKey: KeyCenter.kAuthorizationBase64Key)
            UserDefaults.standard.synchronize()
        
            return base64Credentials
        }
        
    }
    
}


