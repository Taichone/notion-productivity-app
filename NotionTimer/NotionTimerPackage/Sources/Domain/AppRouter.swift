//
//  AppRouter.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/06.
//

import SwiftUI
import DataLayer
import Observation

@MainActor @Observable public final class AppRouter {
    public var items: [Item] = []
    
    nonisolated public init() {}
    
    public enum Item: Hashable {
        case setting
        case timerSetting
        case timer(dependency: TimerDependency)
        case timerRecord(dependency: RecordDependency)
    }
}

extension AppRouter {
    public struct TimerDependency: Hashable {
        public let isBreakEndSoundEnabled: Bool
        public let isManualBreakStartEnabled: Bool
        public let focusTimeSec: Int
        public let breakTimeSec: Int
        public let focusColor: Color
        public let breakColor: Color
        
        public init(
            isBreakEndSoundEnabled: Bool,
            isManualBreakStartEnabled: Bool,
            focusTimeSec: Int,
            breakTimeSec: Int,
            focusColor: Color,
            breakColor: Color
        ) {
            self.isBreakEndSoundEnabled = isBreakEndSoundEnabled
            self.isManualBreakStartEnabled = isManualBreakStartEnabled
            self.focusTimeSec = focusTimeSec
            self.breakTimeSec = breakTimeSec
            self.focusColor = focusColor
            self.breakColor = breakColor
        }
    }
    
    public struct RecordDependency: Hashable {
        public let resultFocusTimeSec: Int
        
        public init(resultFocusTimeSec: Int) {
            self.resultFocusTimeSec = resultFocusTimeSec
        }
    }
}

struct AppRouterKey: EnvironmentKey {
    static let defaultValue = AppRouter()
}

public extension EnvironmentValues {
    var appRouter: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
