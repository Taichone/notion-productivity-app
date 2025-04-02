//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import Foundation
import DataLayer

// TODO: Observable を積極検討
@MainActor
public final class TimerService: ObservableObject {
    // Dependency
    let isManualBreakStartEnabled: Bool
    let focusTimeSec: Int
    let breakTimeSec: Int
    let screenTimeClient: ScreenTimeClient
    let appSelection: AppSelection?
    
    // Timer status
    var timer: Timer?
    @Published public var timerMode: Mode
    @Published public var maxTimeSec: Int = 0
    @Published public var remainingTimeSec: Int = 0
    @Published public var isRunning = false
    @Published public var totalFocusTimeSec: Int = 0
    
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

extension TimerService {
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

extension TimerService {
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

extension TimerService {
    public enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }
}
