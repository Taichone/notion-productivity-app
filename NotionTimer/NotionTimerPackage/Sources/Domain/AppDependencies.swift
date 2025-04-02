//
//  AppDependencies.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/02.
//

import DataLayer
import SwiftUI

public final class AppDependencies: Sendable {
    public let keychainClient: KeychainClient
    public let notionAPIClient: NotionAPIClient
    public let notionAuthClient: NotionAuthClient
    public let screenTimeClient: ScreenTimeClient

    public nonisolated init(
        keychainClient: KeychainClient = .liveValue,
        notionAPIClient: NotionAPIClient = .liveValue,
        notionAuthClient: NotionAuthClient = .liveValue,
        screenTimeClient: ScreenTimeClient = .liveValue
    ) {
        self.keychainClient = keychainClient
        self.notionAPIClient = notionAPIClient
        self.notionAuthClient = notionAuthClient
        self.screenTimeClient = screenTimeClient
    }
}

struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies()
}

public extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
