//
//  WebSocketClient.swift
//  Audio2TextSwiftDemo
//
//  Created by ZengChanghuan on 2023/3/25.
//

import Starscream
class WebSocketClient: WebSocketDelegate {
    let socket: WebSocket
    let authToken = "gvzsHFMZq0iwoyj2WeCOR2axbgC4uAIZ"
    let languageCode = "en" // Replace with the desired ISO language code

    init() {
        let request = URLRequest(url: URL(string: "wss://eu.rt.speechmatics.com/v2/\(languageCode)")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("Connected: \(headers)")
            sendAuthMessage()
        case .disconnected(let reason, let code):
            print("Disconnected: \(reason) with code: \(code)")
        case .text(let text):
            print("Received text: \(text)")
        case .binary(let data):
            print("Received data: \(data)")
        case .pong:
            print("Pong received")
        case .ping:
            print("Ping received")
        case .error(let error):
            print("Error: \(String(describing: error) )")
        case .viabilityChanged(let viable):
            print("Network viability changed: \(viable)")
        case .reconnectSuggested(let shouldReconnect):
            print("Reconnect suggested: \(shouldReconnect)")
        case .cancelled:
            print("Cancelled")
        }
    }

    func sendAuthMessage() {
        let authMessage = [
            "action": "auth",
            "auth_token": authToken
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: authMessage, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            socket.write(string: jsonString)
        }
    }

    func startPingPong() {
        // Send ping every 20 seconds
        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
            self.socket.write(ping: Data())
        }
    }
}
