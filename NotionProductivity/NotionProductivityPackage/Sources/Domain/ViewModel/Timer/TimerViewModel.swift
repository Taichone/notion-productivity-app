import DataLayer
import SwiftUI
import AudioToolbox
import AVFoundation

@MainActor @Observable public final class TimerViewModel {
    // Dependency
    let isManualBreakStartEnabled: Bool
    let breakEndSoundIsEnabled: Bool
    let focusTimeSec: Int
    let breakTimeSec: Int
    let focusColor: Color
    let breakColor: Color
    let screenTimeService: ScreenTimeService
    
    // Timer States
    var timer: Timer?
    public var timerMode: Mode
    public var maxTimeSec: Int
    public var remainingTimeSec: Int
    public var isRunning: Bool
    public var totalFocusTimeSec: Int

    // Alarm States
    public var isAlarmPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?

    // UI Related Stetes
    public var modeColor: Color {
        timerMode == .focusMode ? focusColor : breakColor
    }
    public let trimTo: CGFloat = 1
    public var trimFrom: CGFloat {
        timerMode == .breakMode
        ? CGFloat(remainingTimeSec) / CGFloat(maxTimeSec)
        : CGFloat(1 - (CGFloat(remainingTimeSec) / CGFloat(maxTimeSec)))
    }
    public var remainingTimeString: String {
        "\(remainingTimeSec / 60):\(String(format: "%02d", remainingTimeSec % 60))"
    }
    public var totalFocusTimeString: String {
        "\(totalFocusTimeSec / 60):\(String(format: "%02d", totalFocusTimeSec % 60))"
    }
    public var timerButtonSystemName: String {
        isRunning ? "pause.fill" : "play.fill"
    }
    public var startBreakButtonDisabled: Bool {
        timerMode != .additionalFocusMode
    }
    public var totalFocusTimeDisplayColor: Color {
        timerMode == .additionalFocusMode ? .mint : .primary
    }
    public var timerModeName: String {
        switch timerMode {
        case .focusMode: "focus-mode"
        case .breakMode: "break-mode"
        case .additionalFocusMode: "additional-focus-mode"
        }
    }
    
    public init(
        isManualBreakStartEnabled: Bool,
        breakEndSoundIsEnabled: Bool,
        focusTimeSec: Int,
        breakTimeSec: Int,
        focusColor: Color,
        breakColor: Color,
        screenTimeService: ScreenTimeService,
        timer: Timer? = nil,
        timerMode: Mode = .focusMode,
        maxTimeSec: Int? = nil,
        remainingTimeSec: Int? = nil,
        isRunning: Bool = false,
        totalFocusTimeSec: Int = 0
    ) {
        self.isManualBreakStartEnabled = isManualBreakStartEnabled
        self.breakEndSoundIsEnabled = breakEndSoundIsEnabled
        self.focusTimeSec = focusTimeSec
        self.breakTimeSec = breakTimeSec
        self.focusColor = focusColor
        self.breakColor = breakColor
        
        self.timer = timer
        self.timerMode = timerMode
        self.maxTimeSec = maxTimeSec ?? focusTimeSec
        self.remainingTimeSec = remainingTimeSec ?? focusTimeSec
        self.isRunning = isRunning
        self.totalFocusTimeSec = totalFocusTimeSec
        self.screenTimeService = screenTimeService
        
        setupAudioSession()
    }
}

extension TimerViewModel {
    public func tapPlayButton() {
        isRunning ? stopTimer() : startTimer()
    }
    
    public func tapBreakStartButton() {
        endAdditionalFocusAndStartBreak()
    }
    
    public func tapStopAlarmButton() {
        stopAlarm()
        changeToFocusMode()
        startTimer()
    }
    
    public func terminate() {
        Task {
            await screenTimeService.stopAppRestriction()
            stopTimer()
            stopAlarm()
            changeToFocusMode()
        }
    }
    
    public func tapFinish() {
        terminate()
    }
    
    public func onAppear() async {
        await screenTimeService.startAppRestriction()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    public func onDisappear() {
        stopAlarm()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

extension TimerViewModel {
    func endAdditionalFocusAndStartBreak() {
        stopTimer()
        changeToBreakMode()
        startTimer()
    }
    
    func tickInFocusMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
            totalFocusTimeSec += 1
        } else {
            stopTimer()
            isManualBreakStartEnabled
            ? changeToAdditionalFocusMode()
            : changeToBreakMode()
            startTimer()
        }
    }
    
    func tickInAdditionalFocusMode() {
        totalFocusTimeSec += 1
    }
    
    func tickInBreakMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
        } else {
            stopTimer()
            if breakEndSoundIsEnabled {
                startBreakEndAlarm()
            } else {
                changeToFocusMode()
                startTimer()
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func changeToFocusMode() {
        timerMode = .focusMode
        maxTimeSec = focusTimeSec
        remainingTimeSec = focusTimeSec
    }
    
    func changeToAdditionalFocusMode() {
        timerMode = .additionalFocusMode
    }
    
    func changeToBreakMode() {
        timerMode = .breakMode
        maxTimeSec = breakTimeSec
        remainingTimeSec = breakTimeSec
    }
    
    func startTimer() {
        isRunning = true
        
        switch timerMode {
        case .focusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tickInFocusMode()
                }
            }
        case .breakMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tickInBreakMode()
                }
            }
        case .additionalFocusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tickInAdditionalFocusMode()
                }
            }
        }
    }
    
    // MARK: - Alarm Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("Failed to setup audio session: \(error)")
        }
    }
    
    private func startBreakEndAlarm() {
        guard !isAlarmPlaying else { return }
        isAlarmPlaying = true
        playBreakEndAlarm()
    }
    
    private func playBreakEndAlarm() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        AudioServicesPlaySystemSound(SystemSoundID(1005))
        
        Task{ @MainActor in
            try await Task.sleep(nanoseconds: 2_000_000_000)
            if self.isAlarmPlaying == true {
                self.playBreakEndAlarm()
            }
        }
    }
    
    private func stopAlarm() {
        isAlarmPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

public extension TimerViewModel {
    enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }
}
