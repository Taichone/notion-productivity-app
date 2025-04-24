import SwiftUI
import DataLayer
import Domain

enum TimerSettingSheetType: String, Identifiable {
    case focusTimePicker
    case breakTimePicker
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .focusTimePicker:
            String(moduleLocalized: "focus-time-picker-title")
        case .breakTimePicker:
            String(moduleLocalized: "break-time-picker-title")
        }
    }
}

struct TimerSettingView: View {
    // Router
    @EnvironmentObject var router: NavigationRouter
    
    // ViewModel
    @State private var viewModel: TimerSettingViewModel
    @State private var sheetType: TimerSettingSheetType?
    
    init(
        screenTimeClient: ScreenTimeClient,
        userDefaultsClient: UserDefaultsClient
    ) {
        self.viewModel = .init(
            screenTimeClient: screenTimeClient,
            userDefaultsClient: userDefaultsClient
        )
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(String(moduleLocalized: "focus-time"))
                    Spacer()
                    Button {
                        sheetType = .focusTimePicker
                    } label: {
                        Text(viewModel.focusTimeString)
                    }
                }
                
                HStack {
                    Text(String(moduleLocalized: "break-time"))
                    Spacer()
                    Button {
                        sheetType = .breakTimePicker
                    } label: {
                        Text(viewModel.breakTimeString)
                    }
                }
            }
            
            Section {
                Toggle(isOn: $viewModel.breakEndSoundIsEnabled) {
                    Text(String(moduleLocalized: "enable-sound-at-break-end"))
                }
                Toggle(isOn: $viewModel.manualBreakStartIsEnabled) {
                    Text(String(moduleLocalized: "start-break-time-manually"))
                }
                ColorPicker(String(moduleLocalized: "focus-time-color"), selection: $viewModel.focusColor)
                ColorPicker(String(moduleLocalized: "break-time-color"), selection: $viewModel.breakColor)
            } header: {
                Text(String(moduleLocalized: "appearance-settings"))
            }
            
            Button {
                Task {
                    await viewModel.tryShowFamilyActivityPicker()
                }
            } label: {
                Text(String(moduleLocalized: "select-apps-to-restrict"))
            }
        }
        .navigationTitle(String(moduleLocalized: "timer-setting"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.items.append(.timer(
                        dependency: .init(
                            breakEndSoundIsEnabled: viewModel.breakEndSoundIsEnabled,
                            manualBreakStartIsEnabled: viewModel.manualBreakStartIsEnabled,
                            focusTimeSec: viewModel.focusTimeSec,
                            breakTimeSec: viewModel.breakTimeSec,
                            focusColor: viewModel.focusColor,
                            breakColor: viewModel.breakColor
                        )
                    ))
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
            }
        }
        .familyActivityPicker(
            isPresented: $viewModel.isFamilyActivityPickerPresented,
            selection: $viewModel.appSelection
        )
        .task {
            viewModel.stopAppRestriction()
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .focusTimePicker:
                TimePicker(sec: $viewModel.focusTimeSec, title: type.title)
                    .presentationDetents([.medium])
            case .breakTimePicker:
                TimePicker(sec: $viewModel.breakTimeSec, title: type.title)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    TimerSettingView(
        screenTimeClient: .testValue,
        userDefaultsClient: .testValue
    )
}
