//
//  AgoraWebSocketManager.swift
//  Audio2TextSwiftDemo
//
//  Created by ZengChanghuan on 2023/3/15.
//

import Foundation
import Starscream



class AgoraWebSocketManager: WebSocketDelegate {
    
    static let shared = AgoraWebSocketManager()
    
    private var websocket: WebSocket!
    
    private init() {
        // 创建WebSocket实例
        let urlString = "wss://audio-ai.ximalaya.com/has/asr/review/stream/api/v1/ws"
        var request = URLRequest(url: URL(string: urlString)!)
        
        // 添加Token到请求头
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2ODAzMTkxOTcsImlhdCI6MTY3NzcyNzE5Nywic3ViIjoidGVzdF9hZ29yYSJ9.NtKvY1TQ4cDEFLZK_u_xD84mxz4QAFp3cGj5S1xlxlU"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        websocket = WebSocket(request: request)
        
        // 设置代理
        websocket.delegate = self
    }
    
    func connect() {
        websocket.connect()
    }
    
    func disconnect() {
        websocket.disconnect()
    }
    
    func send(message: String) {
        websocket.write(string: message)
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("websocket 已连接：\(headers)")
        case .disconnected(let reason, let closeCode):
            print("websocket 断开连接，原因：\(reason)，代码：\(closeCode)")
        case .text(let text):
            print("接收到文本消息: \(text)")
        case .binary(let data):
            print("接收到二进制消息: \(data)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("websocket 已取消")
        case .error(let error):
            print("发生错误: \(String(describing: error))")
        }
    }
    
    

}
