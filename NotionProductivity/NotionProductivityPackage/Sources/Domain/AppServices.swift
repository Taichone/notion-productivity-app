import DataLayer
import SwiftUI

public final class AppServices: Sendable {
    public let screenTimeService: ScreenTimeService
    public let notionService: NotionService

    public nonisolated init(appDependencies: AppDependencies) {
        screenTimeService = .init()
        notionService = .init(
            keychainClient: AppDependenciesKey.defaultValue.keychainClient,
            notionClient: AppDependenciesKey.defaultValue.notionAPIClient,
            notionAuthClient: AppDependenciesKey.defaultValue.notionAuthClient
        )
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
