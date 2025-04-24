import FamilyControls
import ManagedSettings

extension FamilyActivitySelection: @retroactive @unchecked Sendable {}
extension ManagedSettingsStore: @retroactive @unchecked Sendable {}

public typealias AppSelection = FamilyActivitySelection

public struct ScreenTimeClient: DependencyClient {
    public var authorize: @Sendable () async throws -> Void
    public var startAppRestriction: @Sendable (AppSelection) -> Void
    public var stopAppRestriction: @Sendable () -> Void
    
    public static let liveValue = Self(
        authorize: authorize,
        startAppRestriction: startAppRestriction,
        stopAppRestriction: stopAppRestriction
    )
    
    public static let testValue = Self(
        authorize: {},
        startAppRestriction: { _ in },
        stopAppRestriction: {}
    )
}

extension ScreenTimeClient {
    static let store = ManagedSettingsStore()
    
    static func authorize() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    
    static func startAppRestriction(selection: AppSelection) {
        store.application.denyAppRemoval = true
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.applications = selection.applicationTokens
    }

    static func stopAppRestriction() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.clearAllSettings()
    }
}
