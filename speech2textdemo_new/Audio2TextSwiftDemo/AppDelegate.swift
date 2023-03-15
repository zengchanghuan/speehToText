//
//  AppDelegate.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let storedAddress = UserDefaults.standard.string(forKey: KeyCenter.kStoreAddressKey) {
            KeyCenter.GatewayAddress = storedAddress
        }
        RestfulManager.shared.stopOldTask()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        RestfulManager.shared.stop(completion: nil)
    }
}

