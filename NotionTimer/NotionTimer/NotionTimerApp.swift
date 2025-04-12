//
//  NotionTimerApp.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/10.
//

import SwiftUI
import Presentation
import Domain

@main
struct NotionTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        RootScene()
    }
}

fileprivate struct PreferredLanguageSettingValidator {
    fileprivate let language = String(localized: "language")
}
