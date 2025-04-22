//
//  UserDefaultsRepository.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/15.
//

import Foundation

public struct TimerSettingRepository: Sendable {
    private let userDefaultsClient: UserDefaultsClient
    
    public var focusTimeSec: Int {
        get { userDefaultsClient.int("focusTimeSec") }
        nonmutating set { userDefaultsClient.setInt(newValue, "focusTimeSec") }
    }

    public var breakTimeSec: Int {
        get { userDefaultsClient.int("breakTimeSec") }
        nonmutating set { userDefaultsClient.setInt(newValue, "breakTimeSec") }
    }

    public var breakEndSoundIsEnabled: Bool {
        get { userDefaultsClient.bool("breakEndSoundIsEnabled") }
        nonmutating set { userDefaultsClient.setBool(newValue, "breakEndSoundIsEnabled") }
    }

    public var manualBreakStartIsEnabled: Bool {
        get { userDefaultsClient.bool("manualBreakStartIsEnabled") }
        nonmutating set { userDefaultsClient.setBool(newValue, "manualBreakStartIsEnabled") }
    }

    public var focusColorHex: String {
        get { userDefaultsClient.string("focusColorHex") }
        nonmutating set { userDefaultsClient.setString(newValue, "focusColorHex") }
    }

    public var breakColorHex: String {
        get { userDefaultsClient.string("breakColorHex") }
        nonmutating set { userDefaultsClient.setString(newValue, "breakColorHex") }
    }
    
    public init(_ userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
    }
}
