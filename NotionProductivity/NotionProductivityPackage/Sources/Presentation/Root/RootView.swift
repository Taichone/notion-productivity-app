import SwiftUI
import DataLayer
import Domain

public struct RootScene: Scene {
    @Environment(\.appServices) private var appServices
    @Environment(\.appDependencies) private var appDependencies
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            RootView(
                notionService: appServices.notionService,
                screenTimeService: appServices.screenTimeService,
                userDefaultsClient: appDependencies.userDefaultsClient
            )
        }
    }
}

struct RootView: View {
    private let screenTimeService: ScreenTimeService
    private let notionService: NotionService
    private let userDefaultsClient: UserDefaultsClient
    
    init(
        notionService: NotionService,
        screenTimeService: ScreenTimeService,
        userDefaultsClient: UserDefaultsClient
    ) {
        self.screenTimeService = screenTimeService
        self.userDefaultsClient = userDefaultsClient
        self.notionService = notionService
    }
    
    public var body: some View {
        Group {
            TabView {
                Tab("Notepad", systemImage: "note.text") {
                    Text("Notepad")
                }
                
                Tab("Habits", systemImage: "checkmark.circle") {
                    Text("Habits")
                }
                
                Tab("Timer", systemImage: "timer") {
                    TimerSettingView(
                        notionService: notionService,
                        screenTimeService: screenTimeService,
                        userDefaultsClient: userDefaultsClient
                    )
                }
                
                Tab("Records", systemImage: "list.bullet") {
                    List {
                        Section(String(moduleLocalized: "timer-record-section-title")) {
                            RecordDisplayView(notionService: notionService)
                                .frame(height: 400)
                        }
                    }
                }
                
                Tab("Settings", systemImage: "gearshape") {
                    ZStack {
                        SettingsView(notionService: notionService)
                    }
                }
            }
        }
        .task {
            await onAppear()
        }
    }
    
    private func updateNotionStatus() async {
        await notionService.updateAccessTokenStatus()
        await notionService.updateTimerRecordingDatabaseStatus()
    }
    
    private func onAppear() async {
        await updateNotionStatus()
    }
}

#Preview {
    RootView(
        notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue
        ),
        screenTimeService: .init(
            screenTimeClient: .testValue
        ),
        userDefaultsClient: .testValue
    )
}
