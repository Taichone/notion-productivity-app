//
//  ScreenTimeClient.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/19.
//

import FamilyControls
import ManagedSettings

extension FamilyActivitySelection: @retroactive @unchecked Sendable {}
extension ManagedSettingsStore: @retroactive @unchecked Sendable {}

public typealias AppSelection = FamilyActivitySelection

protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}

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
    public static let familyActivitySelection = FamilyActivitySelection() // FamilyActivityPicker 用
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
