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
    let notionService: NotionService
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        List {
            Section (
                content: {
                    Button {
                        Task {
                            await notionService.releaseSelectedDatabase()
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
                            await notionService.releaseAccessToken()
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
