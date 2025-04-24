import SwiftUI
import DataLayer
import Domain

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @State private var viewModel: TimerViewModel
    
    init(dependency: Dependency) {
        self.viewModel = .init(
            isManualBreakStartEnabled: dependency.manualBreakStartIsEnabled,
            focusTimeSec: dependency.focusTimeSec,
            breakTimeSec: dependency.breakTimeSec,
            focusColor: dependency.focusColor,
            breakColor: dependency.breakColor,
            screenTimeClient: ScreenTimeClient.liveValue
        )
    }
    
    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.timerMode.name)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "remaining-time"))
                    Spacer()
                    Text(viewModel.remainingTimeString)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "total-focus-time"))
                    Spacer()
                    Text(viewModel.totalFocusTimeString)
                }
            }
            .padding()
            .background {
                GlassmorphismRoundedRectangle()
            }
            
            Spacer()
            
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
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
                
                Button {
                    ExternalOutput.tapticFeedback(style: .heavy)
                    viewModel.tapBreakStartButton()
                } label: {
                    ZStack {
                        TimerCenterCircle(
                            color: viewModel.breakColor,
                            strokeWidth: 80
                        )
                        Text(String(moduleLocalized: "start-break")).bold()
                            .foregroundStyle(Color(.label))
                            .shadow(
                                color: Color(.systemBackground),
                                radius: 5
                            )
                    }
                }
                .hidden(viewModel.startBreakButtonDisabled)
            }
            
            Spacer()
            
            Button {
                ExternalOutput.tapticFeedback(style: .light)
                viewModel.tapPlayButton()
            } label: {
                Image(systemName: viewModel.timerButtonSystemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String(moduleLocalized: "timer"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 確認アラートを挟む
                    viewModel.terminate()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
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
        .onAppear {
            viewModel.onAppear()
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
        TimerView(
            viewModel: .init(
                isManualBreakStartEnabled: true,
                focusTimeSec: 60,
                breakTimeSec: 60,
                focusColor: .red,
                breakColor: .blue,
                screenTimeClient: .liveValue,
                appSelection: nil,
                timer: nil,
                timerMode: .additionalFocusMode,
                maxTimeSec: 60,
                remainingTimeSec: 0,
                isRunning: true,
                totalFocusTimeSec: 0
            )
        )
    }
}
