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
    @Environment(\.appServices) private var appServices
    @Environment(\.appDependencies) private var appDependencies
    
    var body: some Scene {
        WindowGroup {
            RootView(
                notionService: appServices.notionService,
                screenTimeClient: appDependencies.screenTimeClient
            )
        }
    }
}

fileprivate struct PreferredLanguageSettingValidator {
    fileprivate let language = String(localized: "language")
}
