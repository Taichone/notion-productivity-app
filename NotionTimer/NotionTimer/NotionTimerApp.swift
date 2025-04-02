//
//  NotionTimerApp.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/10.
//

import SwiftUI
import Presentation

@main
struct NotionTimerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

fileprivate struct PreferredLanguageSettingValidator {
    fileprivate let language = String(localized: "language")
}
