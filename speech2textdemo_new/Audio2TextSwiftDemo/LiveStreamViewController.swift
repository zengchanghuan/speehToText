//
//  LiveStreamViewController.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/23.
//
//

import UIKit
import AGEVideoLayout
import AgoraRtcKit

private let UserHeadCellId = "UserHeadCellId"
private let RemoteCellId = "RemoteCellId"
private let LocalCellId = "LocalCellId"


class TextItem: NSObject {
    var icon = ""
    var name = ""
    var uid:UInt = 0
    var text = ""
}

class UserModel: NSObject {
    var uid:UInt = 0
    var icon = ""
    var name = ""
    var role:AgoraClientRole?
}

enum ChannelType:String {
    case LIVE_TYPE,COMMUNICATION_TYPE
}

class LiveStreamViewController: BaseViewController, AgoraAudioDataFrameProtocol {
    let speechWebSocketClient = SpeechWebSocketClient()
    var seqNo = 0

    var fileHandle: FileHandle?

    func onPlaybackAudioFrame(_ frame: AgoraAudioFrame) -> Bool {
        return true
    }
    
    func onMixedAudioFrame(_ frame: AgoraAudioFrame) -> Bool {
        return true
    }
    
    func onPlaybackAudioFrame(beforeMixing frame: AgoraAudioFrame, uid: UInt) -> Bool {
        return true
    }
    
    func isMultipleChannelFrameWanted() -> Bool {
        return true
    }
    
    func onPlaybackAudioFrame(beforeMixingEx frame: AgoraAudioFrame, channelId: String, uid: UInt) -> Bool {
        print("onPlaybackAudioFrame(beforeMixingEx:) called with frame: \(frame), channelId: \(channelId), uid: \(uid)")
        // 在这里添加您的实现代码
        return true // 按需修改返回值
    }

    func getObservedAudioFramePosition() -> AgoraAudioFramePosition {
        print("getObservedAudioFramePosition called")
        // 在这里添加您的实现代码
        return .record // 按需修改返回值
    }

    func onRecord(_ frame: AgoraAudioFrame) -> Bool {
           // 获取音频数据的指针
           guard let audioData = frame.buffer else {
               print("Error: Failed to access audio data buffer.")
               return false
           }

           // 确保音频格式是 pcm_s16le，即每个样本占用2字节
           guard frame.bytesPerSample == 2 else {
               print("Error: Unsupported audio format. Expecting pcm_s16le (2 bytes per sample).")
               return false
           }

           // 计算音频数据的大小
           let dataSize = Int(frame.samplesPerChannel * frame.channels * frame.bytesPerSample)

           // 将音频数据复制到一个 Int16 数组中
           let audioBuffer = UnsafeMutableBufferPointer<Int16>.allocate(capacity: dataSize / 2)
           audioData.assumingMemoryBound(to: Int16.self).assign(from: audioBuffer.baseAddress!, count: dataSize / 2)

           // 处理音频数据
           processAudioData(audioBuffer)

           // 释放分配的内存
           audioBuffer.deallocate()

           return true
       }
    
    func processAudioData(_ audioData: UnsafeMutableBufferPointer<Int16>) {
        // 在这里处理音频数据

          // 将 UnsafeMutableBufferPointer<Int16> 转换为 Data 类型
          let audioDataBytes = Data(bytes: audioData.baseAddress!, count: audioData.count * MemoryLayout<Int16>.size)

          // 设置序列号
//          let seqNo = 0 // 或者使用递增的序列号

          // 调用 sendAddAudio 方法
        speechWebSocketClient.sendAddAudio(audioData: audioDataBytes, seqNo: seqNo)
        
    }
    func convertAudioFrameToData(frame: AgoraAudioFrame) -> Data? {
        guard let buffer = frame.buffer else {
            return nil
        }
        let count = Int(frame.samplesPerChannel * frame.channels * frame.bytesPerSample)
        let data = Data(bytes: buffer, count: count)
        return data
    }

    /*
    private func convertToPCM(data: UnsafeMutableRawPointer?, size: Int) -> Data {
         let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true)
         let audioBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: 16000)!
         let audioBufferPointer = audioBuffer.int16ChannelData!
         let dataPointer = data?.assumingMemoryBound(to: Int16.self)
         for i in 0..<audioBuffer.frameCapacity {
             audioBufferPointer[0][Int(i)] = dataPointer![Int(i)]
         }
         audioBuffer.frameLength = audioBuffer.frameCapacity
        let pcmData = audioBuffer.int16ChannelData!.withMemoryRebound(to: UInt8.self, capacity: Int(audioBuffer.frameLength) * Int(format!.streamDescription.pointee.mBytesPerFrame)) {
            return Data(bytes: $0, count: Int(audioBuffer.frameLength) * Int(format!.streamDescription.pointee.mBytesPerFrame))
         }
         return pcmData
     }
     
     private func sendAudioDataToSpeechmatics(_ data: String) {
         let bytesPerFrame = Int(frame.samplesPerChannel) * Int(frame.channels) * Int(frame.bytesPerSample)
         let audioData = frame.buffer!.assumingMemoryBound(to: UInt8.self)
         let audioDataBuffer = UnsafeBufferPointer(start: audioData, count: bytesPerFrame)
         let audioDataArray = Array(audioDataBuffer)
         let audioDataNSData = Data(bytes: audioDataArray)

         speechWebSocketClient.write(data: audioDataNSData)
         
     }
      */
      func getPlaybackAudioParams() -> AgoraAudioParam {
          let audioParam = AgoraAudioParam()
          // 在这里设置播放音频参数
          return audioParam
      }
      
      func getMixedAudioParams() -> AgoraAudioParam {
          print("getMixedAudioParams called")
          let audioParam = AgoraAudioParam()
          return audioParam
      }

      func getRecordAudioParams() -> AgoraAudioParam {
          print("getRecordAudioParams called")
          let audioParam = AgoraAudioParam()
          return audioParam
      }
    
    // user list
    var usersArray = [UserModel]()
    var headCollectionView:UICollectionView?
    
    // text list
    var textItemsArray = [TextItem]()
    var tableView : UITableView?
    
    var txtViews:[Audio2TextView] = [Audio2TextView]()
    
    let manager = RestfulManager.shared
    var channelName:String?
    var channelType: ChannelType = .LIVE_TYPE
    var uid:UInt?
    
    var remoteUid: UInt?
    var agoraKit: AgoraRtcEngineKit!
    var role: AgoraClientRole = .broadcaster
    var isUltraLowLatencyOn: Bool = false
    
    // AAA
    var isAEC = false
    var isNS = false
    var isAGC = false
    
    // indicate if current instance has joined channel
    var isJoined: Bool = false
    
    var isStarted = false
    
    private var startDate:Date?
    private var hasRecord = false
    
    // 文字存储的文件名
    var fileName:String?
    var realTimeText = ""
    var finalText = ""
    var currentFinalText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let seqNo = 0 // 或者使用递增的序列号

        // set up agora instance when view loadedlet config = AgoraRtcEngineConfig()
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area.rawValue
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // get channel name from configs
        guard let channelName = configs["channelName"] as? String,
            let role = configs["role"] as? AgoraClientRole else {return}
        
        // make this room live broadcasting room
        agoraKit.setChannelProfile(.liveBroadcasting)
        if !isAEC {
            agoraKit.setParameters("{\"che.audio.enable.aec\":false}")  //Turn off echo cancellation
        }else{
            agoraKit.setParameters("{\"che.audio.enable.aec\":true}")
        }
        if !isNS {
            agoraKit.setParameters("{\"che.audio.enable.ns\":false}")   //Turn off noise reduction
        }else{
            agoraKit.setParameters("{\"che.audio.enable.ns\":true}")
        }
        if !isAGC {
            agoraKit.setParameters("{\"che.audio.enable.agc\":false}")  //Turn off gain
        }else{
            agoraKit.setParameters("{\"che.audio.enable.agc\":true}") 
        }
        print("====isAEC:\(isAEC), isNS:\(isNS), isACG:\(isAGC)")
        updateClientRole(role)
        
        agoraKit.enableAudio()
        
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // start joining channel
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. If app certificate is turned on at dashboard, token is needed
        // when joining channel. The channel name and uid used to calculate
        // the token has to match the ones used for channel join
        let option = AgoraRtcChannelMediaOptions()
        let result = agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelName, info: nil, uid: 0, options: option)
        if result != 0 {
            // Usually happens with invalid parameters
            // Error code description can be found at:
            // en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            // cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
        } else {
            setupAudioFrameParameters()

        }
        
        // UI
        addBgImgView()
        setUpAudio2TextButton()
        addSettledTextView()
    }
    
    func setupAudioFrameParameters() {
        let audioConfiguration = AgoraAudioRawFrameOperationMode(rawValue: AgoraAudioRawFrameOperationMode.readWrite.rawValue)
        agoraKit.setRecordingAudioFrameParametersWithSampleRate(44100, channel: 1, mode: audioConfiguration!, samplesPerCall: 1024)
        agoraKit.setPlaybackAudioFrameParametersWithSampleRate(44100, channel: 1, mode: audioConfiguration!, samplesPerCall: 1024)
        agoraKit.setMixedAudioFrameParametersWithSampleRate(44100, samplesPerCall: 1024)
        
        agoraKit.setAudioDataFrame(self)
    }
    // MARK: logo
    func addBgImgView() {
        view.backgroundColor = .white
        
        let logoImgView = UIImageView()
        view.addSubview(logoImgView)
        logoImgView.image = UIImage(named: "logo")
        logoImgView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(120)
            make.width.equalTo(120)
            make.height.equalTo(48)
        }
        /*
        let imgView = UIImageView()
        view.addSubview(imgView)
        imgView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "voice", ofType: "gif") ?? "")
        imgView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(logoImgView.snp.bottom).offset(50)
            make.width.height.equalTo(100)
        }
         */
    }
    
    // MARK: display text
    func addSettledTextView() {
        let coverView = UIView(frame: view.bounds)
        view.addSubview(coverView)
        
        for i in 0...3 {
            let textView = Audio2TextView()
            textView.iconImgView.image = UIImage(named: "head\(i)")
            if KeyCenter.namesArray.count > i {
                textView.nameLabel.text = KeyCenter.namesArray[i]
            }
            textView.isHidden = true
            txtViews.append(textView)
            let height:CGFloat = 110
            let topMargin:CGFloat = view.bounds.height - height * 4 - 30
            textView.frame = CGRect(x: 0, y: topMargin + CGFloat(i) * height, width: view.bounds.width, height: height)
            view.addSubview(textView)
        }
        
        let topSpace:CGFloat = view.bounds.height - 110 * 4 - 60
        let languageLab = UILabel()
        languageLab.font = UIFont.systemFont(ofSize: 13)
        languageLab.textColor = UIColor.black
        view.addSubview(languageLab)
        languageLab.backgroundColor = UIColor.clear
        languageLab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(topSpace)
            make.width.equalTo(180)
            make.height.equalTo(20)
        }
        var currentLanValue = LanguageManager.shared.currentSysLanguage().displayName
        if LanguageManager.shared.currentLanguage != ""{
            currentLanValue = LanguageManager.shared.currentLanguage
        }
        languageLab.text = "currentlanguage".L + ": " + currentLanValue
    }
    
    // MARK: Avatar list
    // Add avatar list
    func addUserListCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let height:CGFloat = 60
        headCollectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: height), collectionViewLayout: layout)
        //Register a cell
        headCollectionView!.register(UserHeadCell.self, forCellWithReuseIdentifier: UserHeadCellId)
        headCollectionView!.delegate = self;
        headCollectionView!.dataSource = self;
        headCollectionView!.backgroundColor = UIColor.white
        //Set the width and height of each cell
        layout.itemSize = CGSize(width: 100, height: 70)
        self.view.addSubview(headCollectionView!)
    }
    
    // new user joined
    func addUser(_ user: UserModel) {
        DispatchQueue.main.async {
            var i = 0
            for textView in self.txtViews {
                if textView.uid == 0 || textView.uid == user.uid {
                    textView.uid = Int64(user.uid)
//                    textView.nameLabel.text = user.name
                    if KeyCenter.namesArray.count > i {
                        textView.nameLabel.text = "\(KeyCenter.namesArray[i])(\(user.uid))"
                    }else{
                        textView.nameLabel.text = user.name
                    }
                    textView.isHidden = false
                    break
                }
                i += 1
            }
        }
    }
    
    // user leave
    func deleteUserWithUid(_ uid:UInt) {
        DispatchQueue.main.async {
            for textView in self.txtViews {
                if textView.uid == Int64(uid) {
                    textView.uid = 0
                    textView.isHidden = true
                    textView.nameLabel.text = ""
                    textView.resultTextLabel.text = ""
                    return
                }
            }
        }
    }
    
    // MARK: text table view
    // add text table view
    func addTextTableView() {
        let height:CGFloat = 400
        tableView = UITableView(frame: CGRect(x: 0, y: view.bounds.size.height - height, width: view.bounds.size.width, height:height))
        tableView!.rowHeight = UITableView.automaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.4)
        tableView!.transform = CGAffineTransform(scaleX: -1, y: 1)
        tableView!.separatorStyle = .none
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.register(RemoteTextCell.self, forCellReuseIdentifier: RemoteCellId)
        tableView!.register(LocalTextCell.self, forCellReuseIdentifier: LocalCellId)
        view.addSubview(tableView!)
    }
    
    func addNewTextItem(_ item: TextItem) {
        self.textItemsArray.append(item)
        self.tableView?.reloadData()
        self.tableView?.scrollToRow(at: IndexPath(row: self.textItemsArray.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    // MARK: switch button
    func setUpAudio2TextButton() {
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.setTitle("Start", for: .normal)
        button.setTitle("Stop", for: .selected)
        view.addSubview(button)
        button.addTarget(self, action: #selector(didClickButton), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    // Click the button action
    @objc func didClickButton(button:UIButton) {
        
        if isJoined == false {
            return
        }
        
        button.isEnabled = false
        if button.isSelected {
            // stop
            manager.stop { error in
                button.isEnabled = true
                button.isSelected = false
                self.isStarted = false
                self.finalText.append(self.currentFinalText)
                self.writeText()
            }
        }else{
            // start
            guard let channel = channelName else { return }
            guard let uid = self.uid else { return }
            manager.start(channelName:channel , uid: String(uid), channelType: self.channelType.rawValue) { status, err, jsonString in
                print("status == ",status,"error == ",err?.localizedDescription ?? "")
                button.isEnabled = true
                if status == "STARTED" {
                    button.isSelected = true
                    self.isStarted = true
                    self.resetStartConfig()
                }else{
                    self.showError(josn: jsonString ?? "")
                }
            } timeOut: {
                button.isEnabled = true
                button.isSelected = false
                self.isStarted = false
                self.showAlert(title: "Time out", message: "Automatic stop transcription")
            }
        }
    }
    
    func showError(josn:String) {
        let alert = UIAlertController(title: "Failed, Please try again later.", message: "\(josn)", preferredStyle: .alert)
        alert.addCancelAction()
        present(alert, animated: true, completion: nil)
    }
    
    /// make myself a broadcaster
    func becomeBroadcaster() {
        guard let resolution = GlobalSettings.shared.getSetting(key: "resolution")?.selectedOption().value as? CGSize,
        let fps = GlobalSettings.shared.getSetting(key: "fps")?.selectedOption().value as? AgoraVideoFrameRate,
        let orientation = GlobalSettings.shared.getSetting(key: "orientation")?.selectedOption().value as? AgoraVideoOutputOrientationMode else {
            LogUtils.log(message: "invalid video configurations, failed to become broadcaster", level: .error)
            return
        }
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: resolution,
                                                                             frameRate: fps,
                                                                             bitrate: AgoraVideoBitrateStandard,
                                                                             orientationMode: orientation))
        
        agoraKit.enableLocalAudio(true)
        
        agoraKit.setClientRole(.broadcaster, options: nil)
    }
    
    /// make myself an audience
    func becomeAudience() {
        // unbind view
        agoraKit.setupLocalVideo(nil)
        // You have to provide client role options if set to audience
        let options = AgoraClientRoleOptions()
        options.audienceLatencyLevel = isUltraLowLatencyOn ? .ultraLowLatency : .lowLatency
        agoraKit.setClientRole(.audience, options: options)
    }
    
    fileprivate func updateClientRole(_ role:AgoraClientRole) {
        self.role = role
        if(role == .broadcaster) {
            becomeBroadcaster()
        } else {
            becomeAudience()
        }
    }
    
 
    fileprivate func updateUltraLowLatency(_ enabled:Bool) {
        if(self.role == .audience) {
            self.isUltraLowLatencyOn = enabled
            updateClientRole(.audience)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            // leave channel when exiting the view
            // deregister packet processing
//            AgoraCustomEncryption.deregisterPacketProcessing(agoraKit)
            if isJoined {
                agoraKit.leaveChannel { (stats) -> Void in
                    LogUtils.log(message: "left channel, duration: \(stats.duration)", level: .info)
                }
                if self.isStarted {
                    manager.stop(completion: nil)
                    self.writeText()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.tapCount >= 3 {
            writeText()
            let vc = STTChannelSTableViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func writeText() {
        guard let channel = self.channelName, let fileName = self.fileName else { return  }
        if self.realTimeText.count > 0 {
            STTFilesManager.appendTextToFile(withText: self.realTimeText, channel: channel, fileName: fileName + "realtime")
            self.realTimeText = ""
        }
        if self.finalText.count > 0 {
            STTFilesManager.appendTextToFile(withText: self.finalText, channel: channel, fileName: fileName + "final")
            self.finalText = ""
        }
    }
    
    func resetStartConfig() {
        guard let channel = channelName else { return }
        // 清空原有数据
        TextStreamDataParser.clear()
        // 创建存储文件名
        fileName = STTFilesManager.createFileName(forChannel: channel)
        finalText = ""
        realTimeText = ""
        
        startDate = Date()
        hasRecord = false
        
        for textView in txtViews {
            textView.text = ""
        }
    }
}


extension LiveStreamViewController: AgoraRtcEngineDelegate {
    /// callback when warning occured for agora sdk, warning can usually be ignored, still it's nice to check out
    /// what is happening
    /// Warning code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// @param warningCode warning code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        LogUtils.log(message: "warning: \(warningCode.description)", level: .warning)
    }
    
    /// callback when error occured for agora sdk, you are recommended to display the error descriptions on demand
    /// to let user know something wrong is happening
    /// Error code description can be found at:
    /// en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// @param errorCode error code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        LogUtils.log(message: "error: \(errorCode)", level: .error)
        self.showAlert(title: "Error", message: "Error \(errorCode.description) occur")
    }
    
    /// callback when the local user joins a specified channel.
    /// @param channel
    /// @param uid uid of local user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        isJoined = true
        LogUtils.log(message: "Join \(channel) with uid \(uid) elapsed \(elapsed)ms,timestamp:\(Date().timeIntervalSince1970)", level: .info)
        self.channelName = channel
        self.uid = uid
        
        // Add to avatar list
        if self.role == .broadcaster {
            let user = UserModel()
            user.uid = uid
            user.name = "transcription:self"
            user.role = self.role
            addUser(user)
        }
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "remote user join: \(uid) \(elapsed)ms, timestamp:\(Date().timeIntervalSince1970)", level: .info)
        
        //record remote uid
        remoteUid = uid
        
        // Add to avatar list
        // Two virtual uids are not displayed
        if uid != RestfulManager.audioUid && uid != RestfulManager.dataStreamUid {
            let user = UserModel()
            user.uid = uid
            user.name = "transcription:\(uid)"
            user.role = .broadcaster
            addUser(user)
        }
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        LogUtils.log(message: "remote user left: \(uid) reason \(reason)", level: .info)
        
        //clear remote uid
        if(remoteUid == uid){
            remoteUid = nil
        }
        
        // Delete user avatar
        deleteUserWithUid(uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        print("uid == ",uid,"streamId ==",streamId,"data ==",data)
        let text:Text? = try? Text.parse(from: data)
        if text == nil || text?.uid == nil {
            return
        }
        let dataFormat = "HH:mm:ss"
        let (retStr,retConfinece,wholeText,finalLength,currentFinalText) = TextStreamDataParser.createStringWithText(text!) { finalText,finalTextConfidence in
            self.finalText.append("\(Date().getFormattedDate(format:dataFormat )) \(text!.uid):\(finalText)\n")
            self.finalText.append("\(Date().getFormattedDate(format:dataFormat )) \(text!.uid):\(finalTextConfidence)\n")
        }
        print("retStr ==",retStr)
        if retStr.isEmpty {
            return
        }
        for txtView in self.txtViews {
            if txtView.uid == text!.uid {
                self.realTimeText.append("\(Date().getFormattedDate(format: dataFormat)) \(text!.uid):\(retStr)\n")
                self.realTimeText.append("\(Date().getFormattedDate(format: dataFormat)) \(text!.uid):\(retConfinece)\n")
                self.currentFinalText = "\(Date().getFormattedDate(format: dataFormat)) \(text!.uid):\(currentFinalText)\n"
                txtView.setText(wholeText, finalLength: finalLength)
//                txtView.setText(retStr, finalLength: currentFinalText.count)
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        print("didOccurStreamMessageErrorFromUid -- ",error)
    }
}


extension LiveStreamViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userModel = usersArray[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserHeadCellId, for: indexPath)as! UserHeadCell
        cell.setIcon("", name: userModel.name, isBroadcastor: userModel.role == .broadcaster)
        return cell
    }
}


extension LiveStreamViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.textItemsArray[indexPath.row]
        var cell:TextTableViewCell
        if item.uid == self.uid {
            cell = tableView.dequeueReusableCell(withIdentifier: LocalCellId, for: indexPath) as! TextTableViewCell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: RemoteCellId, for: indexPath) as! TextTableViewCell
        }
        cell.setUid(item.uid,name: item.name, text: item.text)
        return cell
    }
    
}


extension LiveStreamViewController {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRecord audioFrame: AgoraAudioFrame) -> Bool {
        print("Recorded audio frame: \(audioFrame)")
        return true
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, willPlayback audioFrame: AgoraAudioFrame) -> Bool {
        print("Playback audio frame: \(audioFrame)")
        return true
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, willMixedPlayback audioFrame: AgoraAudioFrame) -> Bool {
        print("Mixed playback audio frame: \(audioFrame)")
        return true
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, willPlaybackEx audioFrame: AgoraAudioFrame, uid: UInt) -> Bool {
        print("Playback audio frame for uid: \(uid), frame: \(audioFrame)")
        return true
    }
}
