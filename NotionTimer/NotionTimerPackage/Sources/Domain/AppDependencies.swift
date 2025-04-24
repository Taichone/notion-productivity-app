import DataLayer
import SwiftUI

public final class AppDependencies: Sendable {
    public let keychainClient: KeychainClient
    public let notionAPIClient: NotionAPIClient
    public let notionAuthClient: NotionAuthClient
    public let screenTimeClient: ScreenTimeClient
    public let userDefaultsClient: UserDefaultsClient

    public nonisolated init(
        keychainClient: KeychainClient = .liveValue,
        notionAPIClient: NotionAPIClient = .liveValue,
        notionAuthClient: NotionAuthClient = .liveValue,
        screenTimeClient: ScreenTimeClient = .liveValue,
        userDefaultsClient: UserDefaultsClient = .liveValue
    ) {
        self.keychainClient = keychainClient
        self.notionAPIClient = notionAPIClient
        self.notionAuthClient = notionAuthClient
        self.screenTimeClient = screenTimeClient
        self.userDefaultsClient = userDefaultsClient
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
