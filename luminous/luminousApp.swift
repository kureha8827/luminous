//
//  luminousApp.swift
//  luminous
//
//  Created by kureha8827 on 2024/03/15.
//

import SwiftUI

@main
struct luminousApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            BeginView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // 初回起動時のみtrueを返す
        let value = UserDefaults.standard.object(forKey: "isFirstLaunch") as? Bool ?? true
        UserDefaults.standard.set(value, forKey: "isFirstLaunch")

        return true
    }
}
