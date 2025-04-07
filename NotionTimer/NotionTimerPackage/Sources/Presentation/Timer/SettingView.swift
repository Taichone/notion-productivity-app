//
//  SettingView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/02.
//

import SwiftUI
import DataLayer
import Domain

struct SettingView: View {
    @State private var viewModel: SettingViewModel
    @Environment(\.appRouter) private var appRouter
    
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
                            appRouter.items.removeAll()
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
                            appRouter.items.removeAll()
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
