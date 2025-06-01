import Testing
import SwiftUI
@testable import DataLayer
@testable import Domain

@MainActor
struct TimerViewModelTests {
    func makeViewModel(isManualBreakStartEnabled: Bool = true) -> TimerViewModel {
        return .init(
            isManualBreakStartEnabled: isManualBreakStartEnabled,
            focusTimeSec: 0,
            breakTimeSec: 0,
            focusColor: .blue,
            breakColor: .green,
            screenTimeClient: .testValue
        )
    }
    
    @Test func 集中時かつ手動休憩がtrueのとき_残り時間が0になると追加集中モードに移行すること() {
        let vm = makeViewModel(isManualBreakStartEnabled: true)
        vm.remainingTimeSec = 0
        vm.tickInFocusMode()
        
        #expect(vm.timerMode == .additionalFocusMode)
    }

    @Test func 集中時かつ手動休憩がfalseのとき_残り時間が0になると休憩に移行すること() async throws {
        let vm = makeViewModel(isManualBreakStartEnabled: false)
        vm.remainingTimeSec = 0
        vm.tickInFocusMode()
        #expect(vm.timerMode == .breakMode)
    }
    
    @Test func 休憩時_残り時間が0になると集中に移行すること() async throws {
        let vm = makeViewModel()
        vm.remainingTimeSec = 0
        vm.tickInBreakMode()
        
        #expect(vm.timerMode == .focusMode)
    }
}
