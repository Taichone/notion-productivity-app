//
//  RecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI
import DataLayer
import Domain

struct RecordView: View {
    @State private var viewModel: RecordViewModel
    @Environment(\.appRouter) private var appRouter
    
    init(dependency: AppRouter.RecordDependency, notionService: NotionService) {
        self.viewModel = .init(
            notionService: notionService, 
            resultFocusTimeSec: dependency.resultFocusTimeSec
        )
    }
    
    var body: some View {
        ZStack {
            List(selection: $viewModel.selectedTags) {
                Group {
                    Section (
                        content: {
                            TextEditor(text: $viewModel.description)
                                .frame(height: 100)
                        },
                        header: {
                            Text(String(moduleLocalized: "record-description"))
                        },
                        footer: {
                            Text(String(moduleLocalized: "record-description-description"))
                        }
                    )
                }
                
                Section (
                    content: {
                        ForEach(viewModel.tags) { tag in
                            Text(tag.name)
                                .tag(tag)
                                .listRowBackground(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .listRowBackground,
                                            .listRowBackground,
                                            tag.color.color
                                        ]),
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                    },
                    header: {
                        Text(String(moduleLocalized: "tag"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "tag-description"))
                    }
                )
            }
            .environment(\.editMode, .constant(.active))
            
            CommonLoadingView()
                .hidden(!viewModel.isLoading)
        }
        .navigationTitle(String(moduleLocalized: "timer-record-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await viewModel.fetchDatabaseTags()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.fetchDatabaseTags() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await viewModel.record()
                            appRouter.items.removeAll() // HomeView に戻る
                        } catch {
                            debugPrint(error.localizedDescription) // TODO: ハンドリング
                        }
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

#Preview {
    RecordView(
        dependency: AppRouter.RecordDependency(resultFocusTimeSec: 3661),
        notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue
        )
    )
}
