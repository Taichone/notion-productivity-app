import SwiftUI
import DataLayer
import Domain

struct SettingView: View {
    @State private var viewModel: SettingViewModel
    @EnvironmentObject var router: NavigationRouter
    
    init(notionService: NotionService) {
        self.viewModel = .init(notionService: notionService)
    }
    
    var body: some View {
        List {
            Section (
                content: {
                    Button {
                        Task {
                            await viewModel.reselectDatabase()
                            router.items.removeAll()
                        }
                    } label: {
                        Text(String(moduleLocalized: "reselect-database"))
                    }
                },
                footer: {
                    Text(String(moduleLocalized: "reselect-database-description"))
                }
            )

            Section (
                content: {
                    Button {
                        Task {
                            await viewModel.logout()
                            router.items.removeAll()
                        }
                    } label: {
                        Text(String(moduleLocalized: "logout"))
                    }
                },
                footer: {
                    Text(String(moduleLocalized: "logout-description"))
                }
            )
        }
        .navigationTitle(String(moduleLocalized: "setting-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
