//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import DataLayer
import Domain

struct HomeView: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.appServices) private var appServices
    @Environment(\.appRouter) private var appRouter
    
    init() {}
    
    var body: some View {
        NavigationStack(path: $appRouter.items) {
            List {
                Section(String(moduleLocalized: "record-display-header")) {
                    RecordDisplayView(notionService: appServices.notionService)
                }
                
                Section(String(moduleLocalized: "timer-button-header")) {
                    Button {
                        appRouter.items.append(.timerSetting)
                    } label: {
                        Text(String(moduleLocalized: "timer-navigation-phrase"))
                            .bold()
                    }
                }
            }
            .navigationDestination(for: AppRouter.Item.self) { item in
                switch item {
                case .setting:
                    SettingView(notionService: appServices.notionService)
                case .timerSetting:
                    TimerSettingView(screenTimeClient: appDependencies.screenTimeClient)
                case .timer(let dependency):
                    TimerView(dependency: dependency)
                case .timerRecord(let dependency):
                    RecordView(dependency: dependency, notionService: appServices.notionService)
                }
            }
            .navigationTitle(String(moduleLocalized: "home-view-navigation-title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appRouter.items.append(.setting)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}
