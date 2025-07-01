import SwiftUI
import DataLayer

@MainActor @Observable public final class TimerSettingViewModel {
    // Dependencies
    private let screenTimeService: ScreenTimeService
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
    public var isFamilyActivityPickerPresented = false
    public var appSelection: AppSelection {
        willSet {
            Task {
                await screenTimeService.setAppSelection(newValue)
            }
        }
    }
    
    public init(
        screenTimeService: ScreenTimeService,
        userDefaultsClient: UserDefaultsClient,
    ) {
        self.screenTimeService = screenTimeService
        self.timerSettingRepository = .init(userDefaultsClient)
        self.focusTimeSec = timerSettingRepository.focusTimeSec
        self.breakTimeSec = timerSettingRepository.breakTimeSec
        self.breakEndSoundIsEnabled = timerSettingRepository.breakEndSoundIsEnabled
        self.manualBreakStartIsEnabled = timerSettingRepository.manualBreakStartIsEnabled
        self.focusColor = .init(hex: timerSettingRepository.focusColorHex)
        self.breakColor = .init(hex: timerSettingRepository.breakColorHex)
        self.appSelection = .init()
    }
    
    // MARK: - Public Methods
    
    public func tryShowFamilyActivityPicker() async {
        do {
            try await screenTimeService.authorize()
            isFamilyActivityPickerPresented = true
        } catch {} // 認証するまで何度でも認証画面を開けるのでハンドリング不要
    }
    
    public func stopAppRestriction() async {
        await screenTimeService.stopAppRestriction()
    }
    
    // MARK: - Computed Properties
    
    public var focusTimeString: String {
        "\(focusTimeSec / 60):\(String(format: "%02d", focusTimeSec % 60))"
    }
    
    public var breakTimeString: String {
        "\(breakTimeSec / 60):\(String(format: "%02d", breakTimeSec % 60))"
    }
}
