import SwiftUI
import DataLayer
import Domain

final class NavigationRouter: ObservableObject {
    @MainActor @Published var items: [Item] = []
    
    init() {}

    enum Item: Hashable {
        case timer(dependency: TimerView.Dependency)
        case timerRecord(dependency: RecordView.Dependency)
    }
}

struct TimerSettingView: View {
    @State private var viewModel: TimerSettingViewModel
    @State private var sheetType: TimerSettingSheetType?
    @StateObject private var router: NavigationRouter = .init()
    private let notionService: NotionService
    private let screenTimeService: ScreenTimeService
    private let userDefaultsClient: UserDefaultsClient

    init(
        notionService: NotionService,
        screenTimeService: ScreenTimeService,
        userDefaultsClient: UserDefaultsClient
    ) {
        self.screenTimeService = screenTimeService
        self.userDefaultsClient = userDefaultsClient
        self.notionService = notionService
        self.viewModel = .init(
            screenTimeService: screenTimeService,
            userDefaultsClient: userDefaultsClient
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.items) {
            List {
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
                } header: {
                    Text(String(moduleLocalized: "timer-time-settings"))
                }
                
                Section {
                    Toggle(isOn: $viewModel.breakEndSoundIsEnabled) {
                        Text(String(moduleLocalized: "enable-alarm-at-break-end"))
                    }
                    Toggle(isOn: $viewModel.manualBreakStartIsEnabled) {
                        Text(String(moduleLocalized: "start-break-time-manually"))
                    }
                    ColorPicker(String(moduleLocalized: "focus-time-color"), selection: $viewModel.focusColor)
                    ColorPicker(String(moduleLocalized: "break-time-color"), selection: $viewModel.breakColor)
                } header: {
                    Text(String(moduleLocalized: "timer-personalization-settings"))
                }

                Section {
                    Button {
                        Task {
                            await viewModel.tryShowFamilyActivityPicker()
                        }
                    } label: {
                        Text(String(moduleLocalized: "select-apps-to-restrict"))
                    }
                } header: {
                    Text(String(moduleLocalized: "screentime-settings"))
                } footer: {
                    Text(String(moduleLocalized: "screentime-settings-description"))
                }
            }
            .navigationTitle(String(moduleLocalized: "timer-setting"))
            .navigationBarTitleDisplayMode(.inline)
            .familyActivityPicker(
                isPresented: $viewModel.isFamilyActivityPickerPresented,
                selection: $viewModel.appSelection
            )
            .task {
                await viewModel.stopAppRestriction()
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
            .safeAreaInset(edge: .bottom) {
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
                    Text(String(moduleLocalized: "timer-navigation-phrase"))
                        .bold()
                        .padding()
                        .glassEffectIfAvailable()
                        .padding()
                }
            }
            .navigationDestination(for: NavigationRouter.Item.self) { item in
                switch item {
                case .timer(let dependency):
                    TimerView(dependency: dependency, screenTimeService: screenTimeService)
                        .environmentObject(router)
                case .timerRecord(let dependency):
                    RecordView(dependency: dependency, notionService: notionService)
                        .environmentObject(router)
                }
            }
            .background {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        .gray.opacity(0.6),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }
}

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
