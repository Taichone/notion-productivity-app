import SwiftUI
import DataLayer

@MainActor @Observable public final class TimerSettingViewModel {
    // Dependencies
    private let screenTimeClient: ScreenTimeClient
    private let timerSettingRepository: TimerSettingRepository
    
    // Timer settings
    public var focusTimeSec: Int {
        didSet { timerSettingRepository.focusTimeSec = focusTimeSec }
    }
    public var breakTimeSec: Int {
        didSet { timerSettingRepository.breakTimeSec = breakTimeSec }
    }
    public var breakEndSoundIsEnabled: Bool {
        didSet { timerSettingRepository.breakEndSoundIsEnabled = breakEndSoundIsEnabled }
    }
    public var manualBreakStartIsEnabled: Bool {
        didSet { timerSettingRepository.manualBreakStartIsEnabled = breakEndSoundIsEnabled }
    }
    public var focusColor: Color {
        didSet { timerSettingRepository.focusColorHex = focusColor.hexString }
    }
    public var breakColor: Color {
        didSet { timerSettingRepository.breakColorHex = breakColor.hexString }
    }
    
    // Screen Time settings
    public var appSelection: AppSelection
    public var isFamilyActivityPickerPresented = false
    
    public init(
        screenTimeClient: ScreenTimeClient,
        userDefaultsClient: UserDefaultsClient,
    ) {
        self.screenTimeClient = screenTimeClient
        self.appSelection = ScreenTimeService.familyActivitySelection
        self.timerSettingRepository = .init(userDefaultsClient)
        self.focusTimeSec = timerSettingRepository.focusTimeSec
        self.breakTimeSec = timerSettingRepository.breakTimeSec
        self.breakEndSoundIsEnabled = timerSettingRepository.breakEndSoundIsEnabled
        self.manualBreakStartIsEnabled = timerSettingRepository.manualBreakStartIsEnabled
        self.focusColor = .init(hex: timerSettingRepository.focusColorHex)
        self.breakColor = .init(hex: timerSettingRepository.breakColorHex)
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
