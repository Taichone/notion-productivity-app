import Foundation

public struct TimerSettingRepository: Sendable {
    private struct Keys {
        static let focusTimeSec = "focusTimeSec"
        static let breakTimeSec = "breakTimeSec"
        static let breakEndSoundIsEnabled = "breakEndSoundIsEnabled"
        static let manualBreakStartIsEnabled = "manualBreakStartIsEnabled"
        static let focusColorHex = "focusColorHex"
        static let breakColorHex = "breakColorHex"
    }
    
    private let userDefaultsClient: UserDefaultsClient
    
    public var focusTimeSec: Int {
        get { userDefaultsClient.int(Keys.focusTimeSec) }
        nonmutating set { userDefaultsClient.setInt(newValue, Keys.focusTimeSec) }
    }

    public var breakTimeSec: Int {
        get { userDefaultsClient.int(Keys.breakTimeSec) }
        nonmutating set { userDefaultsClient.setInt(newValue, Keys.breakTimeSec) }
    }

    public var breakEndSoundIsEnabled: Bool {
        get { userDefaultsClient.bool(Keys.breakEndSoundIsEnabled) }
        nonmutating set { userDefaultsClient.setBool(newValue, Keys.breakEndSoundIsEnabled) }
    }

    public var manualBreakStartIsEnabled: Bool {
        get { userDefaultsClient.bool(Keys.manualBreakStartIsEnabled) }
        nonmutating set { userDefaultsClient.setBool(newValue, Keys.manualBreakStartIsEnabled) }
    }

    public var focusColorHex: String {
        get { userDefaultsClient.string(Keys.focusColorHex) }
        nonmutating set { userDefaultsClient.setString(newValue, Keys.focusColorHex) }
    }

    public var breakColorHex: String {
        get { userDefaultsClient.string(Keys.breakColorHex) }
        nonmutating set { userDefaultsClient.setString(newValue, Keys.breakColorHex) }
    }
    
    public init(_ userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
        self.registerDefaults()
    }
    
    private func registerDefaults() {
        self.userDefaultsClient.registerDefaults([
            Keys.focusTimeSec: 25 * 60,
            Keys.breakTimeSec: 5 * 60,
            Keys.breakEndSoundIsEnabled: true,
            Keys.manualBreakStartIsEnabled: true,
            Keys.focusColorHex: "#19BF9B",
            Keys.breakColorHex: "#B3E808"
        ])
    }
}
