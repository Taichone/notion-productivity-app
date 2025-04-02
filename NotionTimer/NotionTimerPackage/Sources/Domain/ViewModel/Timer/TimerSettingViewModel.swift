import SwiftUI
import DataLayer
import Observation

@MainActor @Observable public final class TimerSettingViewModel {
    // Dependencies
    private let screenTimeClient: ScreenTimeClient
    
    // Timer settings
    public var focusTimeSec: Int = 1500
    public var breakTimeSec: Int = 300
    public var isBreakEndSoundEnabled: Bool = true
    public var isManualBreakStartEnabled: Bool = true
    
    // UI settings
    public var focusColor: Color = .mint
    public var breakColor: Color = .green
    
    // Screen Time settings
    public var appSelection: AppSelection
    public var isFamilyActivityPickerPresented = false
    
    public init(screenTimeClient: ScreenTimeClient) {
        self.screenTimeClient = screenTimeClient
        self.appSelection = ScreenTimeService.familyActivitySelection
    }
    
    // MARK: - Public Methods
    
    public func tryShowFamilyActivityPicker() async {
        do {
            try await screenTimeClient.authorize()
            isFamilyActivityPickerPresented = true
        } catch {} // 認証するまで何度でも認証画面を開けるのでハンドリング不要
    }
    
    public func stopAppRestriction() {
        screenTimeClient.stopAppRestriction()
    }
    
    // MARK: - Computed Properties
    
    public var focusTimeString: String {
        "\(focusTimeSec / 60):\(String(format: "%02d", focusTimeSec % 60))"
    }
    
    public var breakTimeString: String {
        "\(breakTimeSec / 60):\(String(format: "%02d", breakTimeSec % 60))"
    }
} 
