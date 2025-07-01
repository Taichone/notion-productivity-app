//
//  Copyright © 2025 Taichone. All rights reserved.
//
     

import SwiftUI
import DataLayer
import Domain

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showingNotionWebView = false
    
    init(notionService: NotionService) {
        self.viewModel = .init(notionService: notionService)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.notionAccessTokenStatus == .selected {
                    Section(
                        content: {
                            NavigationLink {
                                DatabaseSelectionView(notionService: viewModel.notionService)
                            } label: {
                                Text(String(moduleLocalized: "reselect-database"))
                            }
                        },
                        footer: {
                            Text(String(moduleLocalized: "reselect-database-description"))
                        }
                    )
                    Section(
                        content: {
                            Button {
                                Task {
                                    // TODO: アラートを表示
                                    await viewModel.logout()
                                }
                            } label: {
                                Text(String(moduleLocalized: "logout"))
                            }
                        },
                        footer: {
                            Text(String(moduleLocalized: "logout-description"))
                        }
                    )
                } else {
                    Section(
                        content: {
                            Button {
                                showingNotionWebView = true
                            } label: {
                                Text(String(moduleLocalized: "connect-your-notion"))
                            }
                        },
                        footer: {
                            Text(String(moduleLocalized: "connect-your-notion-description"))
                        }
                    )
                }
            }
            .navigationTitle(String(moduleLocalized: "setting-view-navigation-title"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchNotionStatus()
            }
            .sheet(isPresented: $showingNotionWebView) {
                NotionWebView(notionService: viewModel.notionService) {
                    await viewModel.fetchNotionStatus()
                    showingNotionWebView = false
                }
            }
        }
    }

}

#Preview {
    NavigationStack {
        SettingsView(
            notionService: .init(
                keychainClient: .testValue,
                notionClient: .testValue,
                notionAuthClient: .testValue
            )
        )
    }
}
