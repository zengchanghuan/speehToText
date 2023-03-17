//
//  KeyCenter.swift
//  OpenLive
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

struct KeyCenter {
    
    static let kStoreAddressKey = "kStoreAddressKey"
    
    static let kAuthorizationBase64Key = "kAuthorizationBase64Key"
    
    //api domain: test-stt-api.agora.io（http://test-stt-api.agora.io:16003）
    //api staging domain: test-stt-api-staging.agora.io （https://test-stt-api-staging.agora.io）
    //before replacement：http://23.236.99.144:16003
    //temporary：https://stt-demo-staging.agora.io/api/
    //production environment:"https://api.agora.io"
    
    static var GatewayAddress:String =  "https://stt-demo-staging.agora.io/api/"
    
    static var AppId: String = "4135901d9c8b4f0cb09fbb51fd7508ff"

    // assign token to nil if you have not enabled app certificate
    static var Token: String? = ""
    
    // Customer ID
    static let customerKey = "916536139f094d2d90a440b074e79e17"
    // Customer Key
    static let customerSecret = "98a1f6e8c18b4f818df2cfb99db40c47"
    
    static var namesArray:[String] = [String]()
    
    
    static let wsURI = "wss://<endpoint>/has/asr/review/stream/api/v1/ws"
    
}
