import SwiftUI
import DataLayer
import Domain

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @State private var viewModel: TimerViewModel
    
    init(dependency: Dependency, screenTimeService: ScreenTimeService) {
        self.viewModel = .init(
            isManualBreakStartEnabled: dependency.manualBreakStartIsEnabled,
            breakEndSoundIsEnabled: dependency.breakEndSoundIsEnabled,
            focusTimeSec: dependency.focusTimeSec,
            breakTimeSec: dependency.breakTimeSec,
            focusColor: dependency.focusColor,
            breakColor: dependency.breakColor,
            screenTimeService: screenTimeService
        )
    }
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                TimerCircle.background(
                    color: Color(.secondarySystemBackground),
                    strokeWidth: 80
                )
                
                TimerCircle(
                    trimFrom: viewModel.trimFrom,
                    trimTo: viewModel.trimTo,
                    color: viewModel.modeColor,
                    strokeWidth: 80
                )
                .animation(.smooth, value: viewModel.trimFrom)
                .animation(.smooth, value: viewModel.trimTo)
                .shadow(radius: 10)
            }
            
            Spacer()
            
            Button {
                viewModel.tapStopAlarmButton()
            } label: {
                Text(String(moduleLocalized: "tap-to-start-focus-mode"))
                    .padding()
                    .glassEffectIfAvailable()
            }
            .hidden(!viewModel.isAlarmPlaying)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.timerMode.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 確認アラートを挟む
                    viewModel.terminate()
                    dismiss()
                } label: {
                    HStack {
                        Text(String(moduleLocalized: "cancel"))
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 確認アラートを挟む
                    router.items.append(.timerRecord(dependency: .init(
                        resultFocusTimeSec: viewModel.totalFocusTimeSec
                    )))
                    viewModel.terminate()
                    
                } label: {
                    Text(String(moduleLocalized: "done"))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                if viewModel.timerMode == .additionalFocusMode {
                    HStack {
                        Text(String(moduleLocalized: "total-focus-time"))
                        Text(viewModel.totalFocusTimeString)
                    }
                } else {
                    HStack {
                        Text(String(moduleLocalized: "remaining-time"))
                        Text(viewModel.remainingTimeString)
                    }
                }
                
                Spacer()
                
                // Start Break Button
                Button {
                    ExternalOutput.tapticFeedback(style: .heavy)
                    viewModel.tapBreakStartButton()
                } label: {
                    Text(String(moduleLocalized: "start-break")).bold()
                }
                .hidden(viewModel.startBreakButtonDisabled)
                
                // Play Button
                Button {
                    ExternalOutput.tapticFeedback(style: .light)
                    viewModel.tapPlayButton()
                } label: {
                    Image(systemName: viewModel.timerButtonSystemName)
                }
            }
            .padding()
            .glassEffectIfAvailable()
            .padding()
        }
        .task {
            await viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .background {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    viewModel.modeColor.opacity(0.6),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

extension TimerView {
    struct Dependency: Hashable {
        let breakEndSoundIsEnabled: Bool
        let manualBreakStartIsEnabled: Bool
        let focusTimeSec: Int
        let breakTimeSec: Int
        let focusColor: Color
        let breakColor: Color
    }
}

extension TimerViewModel.Mode {
    var name: String {
        switch self {
            case .focusMode:
                String(moduleLocalized: "focus-mode")
            case .breakMode:
                String(moduleLocalized: "break-mode")
            case .additionalFocusMode:
                String(moduleLocalized: "additional-focus-mode")
        }
    }
}

#Preview {
    NavigationStack {
        TabView {
            Tab("Timer", systemImage: "timer") {
                TimerView(
                    viewModel: .init(
                        isManualBreakStartEnabled: true,
                        breakEndSoundIsEnabled: true,
                        focusTimeSec: 1,
                        breakTimeSec: 1,
                        focusColor: .mint,
                        breakColor: .blue,
                        screenTimeService: .init(screenTimeClient: .testValue),
                        timer: nil,
                        timerMode: .focusMode,
                        maxTimeSec: 1,
                        remainingTimeSec: 1,
                        isRunning: true,
                        totalFocusTimeSec: 0
                    )
                )
            }
            
            Tab("Settings", systemImage: "gear") {
                Text("")
            }
        }
    }
}
