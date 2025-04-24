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
                screenTimeClient: appDependencies.screenTimeClient,
                userDefaultsClient: appDependencies.userDefaultsClient
            )
        }
    }
}

struct RootView: View {
    private let screenTimeClient: ScreenTimeClient
    private let notionService: NotionService
    private let userDefaultsClient: UserDefaultsClient
    
    @State private var viewModel: RootViewModel
    
    init(
        notionService: NotionService,
        screenTimeClient: ScreenTimeClient,
        userDefaultsClient: UserDefaultsClient
    ) {
        self.screenTimeClient = screenTimeClient
        self.userDefaultsClient = userDefaultsClient
        self.notionService = notionService
        self.viewModel = .init(notionService: notionService)
    }
    
    public var body: some View {
        Group {
            switch viewModel.authStatus {
            case .invalidToken:
                LoginView()
            case .invalidDatabase:
                NavigationStack {
                    DatabaseSelectionView(notionService: notionService)
                }
            case .complete:
                HomeView(
                    notionService: notionService,
                    screenTimeClient: screenTimeClient,
                    userDefaultsClient: userDefaultsClient
                )
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .onOpenURL(perform: { url in Task {
            await viewModel.onOpenURL(url)
        }})
        .animation(.default, value: viewModel.authStatus)
    }
}

#Preview {
    RootView(
        notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue
        ),
        screenTimeClient: .testValue,
        userDefaultsClient: .testValue
    )
}
