//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import DataLayer
import SwiftUI

// TODO: Observable を積極検討
@MainActor @Observable public final class TimerViewModel {
    // Dependency
    let isManualBreakStartEnabled: Bool
    let focusTimeSec: Int
    let breakTimeSec: Int
    let screenTimeClient: ScreenTimeClient
    let appSelection: AppSelection?
    
    // Timer status
    var timer: Timer?
    public var timerMode: Mode
    public var maxTimeSec: Int = 0
    public var remainingTimeSec: Int = 0
    public var isRunning = false
    public var totalFocusTimeSec: Int = 0
    
    // UI related properties
    public var modeColor: Color {
        timerMode == .focusMode ? .mint : .pink
    }
    
    public var trimTo: CGFloat {
        timerMode == .breakMode ? CGFloat(1 - (CGFloat(remainingTimeSec) / CGFloat(maxTimeSec))) : 1
    }
    
    public var trimFrom: CGFloat {
        timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(remainingTimeSec) / CGFloat(maxTimeSec)))
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
        timerMode == .additionalFocusMode ? .mint : Color(.label)
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
        focusTimeSec: Int,
        breakTimeSec: Int,
        screenTimeClient: ScreenTimeClient,
        appSelection: AppSelection? = nil
    ) {
        self.isManualBreakStartEnabled = isManualBreakStartEnabled
        self.focusTimeSec = focusTimeSec
        self.breakTimeSec = breakTimeSec
        self.screenTimeClient = screenTimeClient
        self.appSelection = appSelection
        
        // 集中時間から開始
        timerMode = .focusMode
        maxTimeSec = focusTimeSec
        remainingTimeSec = focusTimeSec
    }
}

extension TimerViewModel {
    public func tapPlayButton() {
        isRunning ? stopTimer() : startTimer()
    }
    
    public func tapBreakStartButton() {
        endAdditionalFocusAndStartBreak()
    }
    
    public func terminate() {
        screenTimeClient.stopAppRestriction()
        stopTimer()
        changeToFocusMode()
    }
    
    public func tapFinish() {
        terminate()
    }
    
    public func onAppear() {
        guard let selection = appSelection else { return }
        screenTimeClient.startAppRestriction(selection)
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
            isManualBreakStartEnabled ? changeToAdditionalFocusMode() : changeToBreakMode()
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
            changeToFocusMode()
            startTimer()
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
                Task { await self?.tickInFocusMode() }
            }
        case .breakMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { await self?.tickInBreakMode() }
            }
        case .additionalFocusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { await self?.tickInAdditionalFocusMode() }
            }
        }
    }
}

extension TimerViewModel {
    public enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }
}
