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
            PresenterView()
                .environmentObject(BaseCamView())
                .environmentObject(ViewSwitcher())
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // 初回起動時のみtrueを返す
        let value = UserDefaults.standard.object(forKey: "isFirstLaunch") as? Bool ?? true
        UserDefaults.standard.set(value, forKey: "isFirstLaunch")

        // 初回起動時のみ実行
        if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
            // デフォルトディレクトリのpathの生成
            let fileManager = FileManager.default
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            // pathの生成?
            let tmp = documentsURL.appendingPathComponent("tmp", isDirectory: true)
            let beforeDirectory = documentsURL.appendingPathComponent("before", isDirectory: true)
            let afterDirectory = documentsURL.appendingPathComponent("before", isDirectory: true)

            // ディレクトリの作成
            try? fileManager.createDirectory(at: beforeDirectory, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.createDirectory(at: afterDirectory, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.createDirectory(at: tmp, withIntermediateDirectories: true, attributes: nil)
        }


        return true
    }
}
