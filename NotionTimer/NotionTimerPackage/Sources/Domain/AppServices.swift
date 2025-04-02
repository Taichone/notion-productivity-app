//
//  AppServices.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/02.
//

import DataLayer
import SwiftUI

public final class AppServices: Sendable {
    public let screenTimeService: ScreenTimeService

    public nonisolated init(appDependencies: AppDependencies) {
        screenTimeService = .init()
    }
}

struct AppServicesKey: EnvironmentKey {
    static let defaultValue = AppServices(appDependencies: AppDependenciesKey.defaultValue)
}

public extension EnvironmentValues {
    var appServices: AppServices {
        get { self[AppServicesKey.self] }
        set { self[AppServicesKey.self] = newValue }
    }
}
