//
//  SpeechWebSocketClient.swift
//  Audio2TextSwiftDemo
//
//  Created by ZengChanghuan on 2023/3/28.
//


import Foundation
import Starscream

class SpeechWebSocketClient: WebSocketDelegate {
    private var socket: WebSocket?
    
    private let apiKey = "gvzsHFMZq0iwoyj2WeCOR2axbgC4uAIZ"
    private let languageCode = "en"
    private let apiEndpoint = "wss://eu.rt.speechmatics.com/v2/"
    
    init() {
        connect()
    }
    
    func connect() {
        guard let url = URL(string: apiEndpoint + languageCode) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        
        socket?.connect()
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket did connect")
        sendPing()
        startRecognition()

    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket did disconnect: \(error?.localizedDescription ?? "unknown error")")
        
        // Attempt to reconnect after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.connect()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("WebSocket received message: \(text)")
        
        // Parse the response
        /*
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let message = json["message"] as? String else {
                  return
        }
        
        // Check if the message is RecognitionStarted
        if message == "RecognitionStarted" {
            guard let id = json["id"] as? String,
                  let languagePackInfo = json["language_pack_info"] as? [String: Any] else {
                      return
            }
            
            // Handle the RecognitionStarted message
            // You can access the session id and language pack info here
            print("Recognition started with session id: \(id)")
            print("Language pack info: \(languagePackInfo)")
        }
        */
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let messageType = json["message"] as? String else {
            return
        }

        switch messageType {
        case "RecognitionStarted":
            handleRecognitionStartedMessage(json)
        case "AddAudio":
            handleAddAudioMessage(json)
        case "AudioAdded":
            handleAudioAddedMessage(json)
        case "AddTranscript":
            handleAddTranscriptMessage(json)
        case "EndOfStream":
            handleEndOfStreamMessage(json)
        case "EndOfTranscript":
            handleEndOfTranscriptMessage(json)
        case "Error":
            handleErrorMessage(json)
        case "Warning":
            handleWarningMessage(json)
        case "Info":
            handleErrorMessage(json)
        default:
            break
        }


    }
    
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("WebSocket received data: \(data)")
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("WebSocket did connect: \(headers)")
            sendPing()
        case .disconnected(let reason, let code):
            print("WebSocket did disconnect: \(reason) with code: \(code)")
            
            // Attempt to reconnect after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.connect()
            }
        case .text(let string):
            print("WebSocket received text: \(string)")
        case .binary(let data):
            print("WebSocket received binary data: \(data)")
        case .ping(let data):
            print("WebSocket received ping: \(String(describing: data))")
        case .pong(let data):
            print("WebSocket received pong: \(String(describing: data))")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "unknown error")")
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        }
    }
    
    // MARK: - Ping
    
    private func sendPing() {
        socket?.write(ping: Data()) // Send an empty ping message
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { // Send a new ping after 60 seconds
            self.sendPing()
        }
    }
    
    func startRecognition() {
        let message : [String: Any] = [
            "message": "StartRecognition",
            "audio_format": [
                "type": "raw",
                "encoding": "pcm_f32le",
                "sample_rate": 16000
            ],
            "transcription_config": [
                "language": "en",
                "output_locale": "en-US",
                "additional_vocab": ["gnocchi", "bucatini", "bigoli"],
                "diarization": "speaker_change",
                "enable_partials": true,
                "punctuation_overrides": [
                    "permitted_marks": [",", "."]
                ]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            socket?.write(data: jsonData)
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
    }


    
    func handleAddAudioMessage(_ json: [String: Any]) {
        // Extract and handle the relevant fields from the AddAudio message
        guard let seqNo = json["seq_no"] as? Int else {
            return
        }
        // Do something with the seqNo, such as tracking the progress of the audio transmission
    }

    func handleAudioAddedMessage(_ json: [String: Any]) {
        // Extract and handle the relevant fields from the AudioAdded message
        guard let seqNo = json["seq_no"] as? Int else {
            return
        }
        // Do something with the seqNo, such as marking the corresponding audio data as successfully transmitted
    }
    
    func handleRecognitionStartedMessage(_ message: [String: Any]) {
        guard let sessionId = message["id"] as? String else {
            print("Error: Invalid RecognitionStarted message - no session ID")
            return
        }
        
        guard let languagePackInfo = message["language_pack_info"] as? [String: Any] else {
            print("Error: Invalid RecognitionStarted message - no language pack info")
            return
        }
        
        // Process the session ID and language pack info as needed
        print("Recognition session started with ID \(sessionId) and language pack info \(languagePackInfo)")
    }
    
    func handleAddTranscriptMessage(_ json: [String: Any]) {
        guard let metadata = json["metadata"] as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let startTime = metadata["start_time"] as? Double,
              let endTime = metadata["end_time"] as? Double else {
            return
        }
        
        // Determine the time range of this segment of audio
        let startTimestamp = Date(timeIntervalSince1970: startTime)
        let endTimestamp = Date(timeIntervalSince1970: endTime)
        
        // Extract the transcript from the AddTranscript message
        let transcript = metadata["transcript"] as? String ?? ""
        
        // Parse the results to get the individual words, punctuation symbols, and speaker changes
        for result in results {
            let type = result["type"] as? String ?? ""
            let content = result["content"] as? String ?? ""
            let startOffset = result["start_time"] as? Double ?? 0
            let endOffset = result["end_time"] as? Double ?? 0
            let start = startTimestamp.addingTimeInterval(startOffset)
            let end = startTimestamp.addingTimeInterval(endOffset)
            let confidence = result["confidence"] as? Double ?? 0
            
            // Handle different types of results
            switch type {
            case "word":
                let alternatives = result["alternatives"] as? [[String: Any]] ?? []
                for alternative in alternatives {
                    let altContent = alternative["content"] as? String ?? ""
                    let altConfidence = alternative["confidence"] as? Double ?? 0
                    // Do something with the word and its alternatives
                }
            case "punctuation":
                let isEOS = result["is_eos"] as? Bool ?? false
                // Do something with the punctuation symbol and whether it's an end-of-sentence symbol
            case "speaker_change":
                // Do something with the speaker change
                print("speaker_change")
            default:
                break
            }
        }
    }

  
    func handleEndOfStreamMessage(_ json: [String: Any]) {
        // Extract and handle the relevant fields from the EndOfStream message
        guard let lastSeqNo = json["last_seq_no"] as? Int else {
            return
        }
        // Do something with the lastSeqNo, such as tracking the total number of audio chunks sent
        let endOfStreamMessage = ["message": "EndOfStream"]
        let jsonData = try! JSONSerialization.data(withJSONObject: endOfStreamMessage)
        socket?.write(data: jsonData)
    }

    func handleEndOfTranscriptMessage(_ json: [String: Any]) {
        // Extract and handle the relevant fields from the EndOfTranscript message
        // Disconnect from the API immediately, as there will be no more messages coming from the API
        let endOfTranscriptMessage = ["message": "EndOfTranscript"]
        let jsonData = try! JSONSerialization.data(withJSONObject: endOfTranscriptMessage)
        socket?.write(data: jsonData)
        socket?.disconnect()
    }
    
    func handleErrorMessage(_ json: [String: Any]) {
        guard let errorType = json["type"] as? String, let reason = json["reason"] as? String else {
            return
        }
        switch errorType {
        case "invalid_message":
            // Handle invalid_message error
            break
        case "invalid_model":
            // Handle invalid_model error
            break
        case "invalid_config":
            // Handle invalid_config error
            break
        case "invalid_audio_type":
            // Handle invalid_audio_type error
            break
        case "invalid_output_format":
            // Handle invalid_output_format error
            break
        case "not_authorised":
            // Handle not_authorised error
            break
        case "insufficient_funds":
            // Handle insufficient_funds error
            break
        case "not_allowed":
            // Handle not_allowed error
            break
        case "job_error":
            // Handle job_error error
            break
        case "data_error":
            // Handle data_error error
            break
        case "buffer_error":
            // Handle buffer_error error
            break
        case "protocol_error":
            // Handle protocol_error error
            break
        case "quota_exceeded":
            // Handle quota_exceeded error
            break
        case "timelimit_exceeded":
            // Handle timelimit_exceeded error
            break
        case "unknown_error":
            // Handle unknown_error error
            break
        default:
            break
        }
        // Terminate the transcription and close the connection
    }

    func handleWarningMessage(_ json: [String: Any]) {
        guard let warningType = json["type"] as? String, let reason = json["reason"] as? String else {
            return
        }
        // Log the warning message for client-side logging
    }

    func handleInfoMessage(_ json: [String: Any]) {
        guard let infoType = json["type"] as? String, let reason = json["reason"] as? String else {
            return
        }
        // Log the info message for client-side logging
    }
    
    func sendAddAudio(audioData: Data, seqNo: Int) {
        // Create a dictionary with the necessary fields for the AddAudio message
        let message = ["message": "AddAudio", "audio_data": audioData.base64EncodedString(), "seq_no": seqNo] as [String : Any]
        
        // Convert the dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) else {
            print("Error: Failed to serialize AddAudio message to JSON")
            return
        }
        
        // Send the JSON data as a binary message over the WebSocket
//        socket?.sendBinaryData(jsonData)
        
        socket?.write(data: jsonData)

    }



}

